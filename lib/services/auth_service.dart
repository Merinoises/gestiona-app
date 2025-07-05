// auth_service.dart

import 'dart:convert';

import 'package:gestiona_app/services/fcm-service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/models/login_response.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/usuario.dart';

class AuthService extends GetxService {
  /// Usuario logueado en este momento (si hay alguno).
  final usuario = Rxn<Usuario>();

  /// Indicador de “estoy haciendo login/renovando token”.
  final autenticando = false.obs;

  final _storage = GetStorage();
  final _http = GetConnect();
  final _fcm = Get.find<FcmService>();

  /// Lista de todas las piscinas, necesaria para reconstruir Turno.fromJson(...)
  final RxList<Pool> pools = <Pool>[].obs;

  @override
  void onInit() {
    _http.baseUrl = Environment.apiUrl;
    _http.timeout = const Duration(seconds: 10);

    // Cargar piscinas UNA VEZ al iniciar el servicio.
    ever<bool>(autenticando, (_) {
      // (opcional) podrías reaccionar a cambios en autenticando,
      // pero en realidad queremos cargar piscinas en init.
    });
    _cargarTodasLasPiscinas();
    super.onInit();
  }

  /// Carga la lista de piscinas desde el endpoint /pools y las guarda en [pools].
  Future<void> _cargarTodasLasPiscinas() async {
    try {
      final resp = await _http.get('/pools');
      if (resp.statusCode == 200 && resp.body != null) {
        // Se espera que `resp.body` sea una List<dynamic> JSON de piscinas
        final List<dynamic> listaJson = resp.body as List<dynamic>;
        pools.value = listaJson
            .map((p) => Pool.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        // Si falla, puedes manejarlo aquí (por ejemplo intentar recargar más tarde)
        // En este ejemplo, dejaremos la lista vacía y confiaremos en que haya
        // un usuario admin o que no se intente reconstruir turnos sin pools.
        pools.clear();
      }
    } catch (e) {
      // Error de red o parsing: dejamos `pools` vacío
      pools.clear();
    }
  }

  /// Obtener el token almacenado (o null si no existe).
  static String? get token => GetStorage().read<String>('token');

  /// Eliminar token (logout a nivel local).
  static Future<void> deleteToken() async => GetStorage().remove('token');

  /// Realiza el login en backend. Devuelve true si tuvo éxito, o String con mensaje de error.
  Future<dynamic> login(String nombre, String password) async {
    autenticando.value = true;
    try {
      // Antes de parsear el LoginResponse, asegurarnos de que `pools` está cargado.
      if (pools.isEmpty) {
        await _cargarTodasLasPiscinas();
      }

      final resp = await _http.post(
        '/login',
        jsonEncode({'nombre': nombre, 'password': password}),
        headers: {'Content-type': 'application/json'},
      );

      final status = resp.statusCode;
      if (status == 200 && resp.bodyString != null) {
        // Ahora pasamos `pools` como segundo parámetro:
        final loginResp = loginResponseFromJson(
          resp.bodyString!,
          pools, // lista de Pool necesaria para reconstruir Usuario.turnos
        );

        usuario.value = loginResp.usuario;
        await _storage.write('token', loginResp.token);
        //Manejamos aquí el FCM token para notificaciones push
        await _fcm.requestPermission();
        await _fcm.registerToken();
        return true;
      }

      // Si status != 200, tratar de obtener mensaje de servidor
      final reason = resp.statusText ?? 'Error desconocido';
      String serverMsg = '';
      if (resp.bodyString != null) {
        try {
          final m = jsonDecode(resp.bodyString!) as Map<String, dynamic>;
          serverMsg = m['msg'] ?? '';
        } catch (_) {}
      }
      return serverMsg.isNotEmpty ? serverMsg : 'Error $status: $reason';
    } catch (e) {
      return 'Error de red: $e';
    } finally {
      autenticando.value = false;
    }
  }

  /// Verifica si el usuario ya está logueado (token válido), tratando de renovar.
  Future<bool> isLoggedIn() async {
    final tokenAlmacenado = await _storage.read('token');

    if (tokenAlmacenado != null) {
      // Asegurarnos de tener las piscinas cargadas antes de reconstruir el usuario.
      if (pools.isEmpty) {
        await _cargarTodasLasPiscinas();
      }

      final resp = await _http.get(
        '/login/renew',
        headers: {
          'Content-Type': 'application/json',
          'x-token': tokenAlmacenado,
        },
      );

      if (resp.statusCode == 200 && resp.body != null) {
        // parsear con la lista de pools cargada
        final loginResponse = LoginResponse.fromJson(
          resp.body as Map<String, dynamic>,
          pools,
        );

        usuario.value = loginResponse.usuario;
        await _guardarToken(loginResponse.token);
        //Manejamos aquí el FCM token para notificaciones push
        await _fcm.requestPermission();
        await _fcm.registerToken();
        return true;
      } else {
        // Si no se renovó bien, forzamos logout local
        logout();
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> _guardarToken(String token) async {
    return await _storage.write('token', token);
  }

  Future<void> logout() async {
    usuario.value = null;
    await _storage.remove('token');
  }
}
