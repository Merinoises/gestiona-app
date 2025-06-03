import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/models/login_response.dart';
import 'package:gestiona_app/models/usuario.dart';

class AuthService extends GetxService {
  final usuario = Rxn<Usuario>();
  final autenticando = false.obs;

  final _storage = GetStorage();
  final _http = GetConnect();

  @override
  void onInit() {
    _http.baseUrl = Environment.apiUrl;
    _http.timeout = const Duration(seconds: 10);
    super.onInit();
  }

  static String? get token => GetStorage().read<String>('token');
  static Future<void> deleteToken() async => GetStorage().remove('token');

  Future<dynamic> login(String email, String password) async {
    autenticando.value = true;
    try {
      final resp = await _http.post(
        '/login',
        jsonEncode({'email': email, 'password': password}),
        headers: {'Content-type': 'application/json'},
      );
      final status = resp.statusCode;
      if (status == 200 && resp.bodyString != null) {
        final loginResp = loginResponseFromJson(resp.bodyString!);
        usuario.value = loginResp.usuario;
        await _storage.write('token', loginResp.token);
        return true;
      }
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

  Future<bool> isLoggedIn() async {
    final token = await _storage.read('token');

    if (token != null) {
      final resp = await _http.get(
        '/login/renew',
        headers: {'Content-Type': 'application/json', 'x-token': token},
      );

      if (resp.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(
          resp.body as Map<String, dynamic>,
        );
        usuario.value = loginResponse.usuario;

        await _guardarToken(loginResponse.token);

        return true;
      } else {
        logout();
        return false;
      }
    } else {
      return false;
    }
  }

  Future _guardarToken(String token) async {
    return await _storage.write('token', token);
  }

  Future<void> logout() async {
    usuario.value = null;
    await _storage.remove('token');
  }
}
