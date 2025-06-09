// pool_controller.dart

import 'dart:convert';

import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:get/get.dart';
import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/models/pool.dart';

class PoolController extends GetxController {
  /// Lista reactiva de piscinas cargadas
  final RxList<Pool> pools = <Pool>[].obs;

  /// Indicador de carga (true si estamos obteniendo datos)
  final RxBool loading = false.obs;

  /// Cliente HTTP para comunicarnos con la API
  final GetConnect _http = GetConnect();

  @override
  void onInit() {
    super.onInit();
    _http.baseUrl = Environment.apiUrl;
    _http.timeout = const Duration(seconds: 10);

    // Cargar piscinas al inicializar el controlador
    loadPools();
  }

  /// Obtiene todas las piscinas desde GET /pools
  Future<void> loadPools() async {
    try {
      loading.value = true;
      final resp = await _http.get('/pools');

      if (resp.statusCode == 200 && resp.body != null) {
        // Se espera que resp.body sea List<dynamic> de JSON de Pool
        final List<dynamic> data = resp.body as List<dynamic>;
        pools.value = data
            .map((p) => Pool.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        // En caso de código distinto o body nulo, limpiar lista
        pools.clear();
      }
    } catch (e) {
      // Si falla la petición, vaciamos lista (o podrías mantener la previa)
      pools.clear();
    } finally {
      loading.value = false;
    }
  }

  /// Devuelve una piscina por su ID, o null si no existe
  Pool? getPoolById(String id) {
    try {
      return pools.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Crea una nueva piscina en el backend con POST /pools
  /// Devuelve null si tuvo éxito, o String con mensaje de error.
  Future<String?> createPool(Pool pool) async {
    try {
      final body = pool.toJson()
        ..remove('_id'); // no enviamos el _id al crear
      final resp = await _http.post(
        '/pools',
        jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (resp.statusCode == 201 && resp.body != null) {
        // Re-construir el Pool recién creado y agregarlo a la lista
        final newPool = Pool.fromJson(resp.body['pool'] as Map<String, dynamic>);
        pools.add(newPool);
        return null;
      } else {
        // Intentar leer mensaje de error
        final msg = (resp.body != null && resp.body is Map)
            ? (resp.body as Map)['msg'] ?? 'Error ${resp.statusCode}'
            : 'Error ${resp.statusCode}';
        return msg.toString();
      }
    } catch (e) {
      return 'Error de red: $e';
    }
  }

  /// Actualiza una piscina existente con PUT /pools/:id
  /// Devuelve null si tuvo éxito, o String con mensaje de error.
  Future<String?> updatePool(Pool pool) async {
    try {
      final body = pool.toJson();
      final resp = await _http.put(
        '/pools/${pool.id}',
        jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (resp.statusCode == 200 && resp.body != null) {
        // Reemplazar en la lista local el objeto actualizado
        final updated = Pool.fromJson(resp.body as Map<String, dynamic>);
        final index = pools.indexWhere((p) => p.id == updated.id);
        if (index >= 0) {
          pools[index] = updated;
        }
        return null;
      } else {
        final msg = (resp.body != null && resp.body is Map)
            ? (resp.body as Map)['msg'] ?? 'Error ${resp.statusCode}'
            : 'Error ${resp.statusCode}';
        return msg.toString();
      }
    } catch (e) {
      return 'Error de red: $e';
    }
  }

  /// Elimina una piscina con DELETE /pools/:id
  /// Devuelve null si tuvo éxito, o String con mensaje de error.
  Future<String?> deletePool(String id) async {
    try {
      loading.value = true;
      final resp = await _http.delete(
        '/pools/$id',
        headers: {'Content-Type': 'application/json'},
      );
      loading.value = false;
      if (resp.statusCode == 200) {
        // Remover de la lista local
        pools.removeWhere((p) => p.id == id);
        await Get.find<SocorristasController>().loadSocorristas();
        return null;
      } else {
        final msg = (resp.body != null && resp.body is Map)
            ? (resp.body as Map)['msg'] ?? 'Error ${resp.statusCode}'
            : 'Error ${resp.statusCode}';
        return msg.toString();
      }
    } catch (e) {
      return 'Error de red: $e';
    }
  }
}
