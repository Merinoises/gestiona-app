// socorrista_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/models/turno.dart';
import 'package:get/get.dart';
import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/models/usuario.dart';

class SocorristasController extends GetxController {
  final RxList<Usuario> socorristas = <Usuario>[].obs;
  final RxBool loading = false.obs;

  //-------Seleccion turno-----------
  var horaInicioTurno = Rx<TimeOfDay?>(null);
  var horaFinalTurno = Rx<TimeOfDay?>(null);
  var mensajeError = ''.obs;
  var socorristaSeleccionado = Rx<Usuario?>(null);
  //--------------------------------

  final GetConnect _http = GetConnect();

  @override
  void onInit() {
    super.onInit();
    _http.baseUrl = Environment.apiUrl;
    _http.timeout = const Duration(seconds: 10);

    loadSocorristas();
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fmtHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String? getIdByNombre(String nombreBuscado) {
    // Buscar por nombre sin distinguir mayúsculas/minúsculas
    final usuario = socorristas.firstWhereOrNull(
      (u) => u.nombre.toLowerCase() == nombreBuscado.toLowerCase(),
    );
    return usuario?.id;
  }

  Usuario? getSocorristaByNombre(String nombreBuscado) {
    // Buscar por nombre sin distinguir mayúsculas/minúsculas
    final usuario = socorristas.firstWhereOrNull(
      (u) => u.nombre.toLowerCase() == nombreBuscado.toLowerCase(),
    );
    return usuario;
  }

  /// Obtiene todos los usuarios cuyo campo isAdmin == false
  Future<void> loadSocorristas() async {
    try {
      loading.value = true;
      // Puedes llamar directamente a '/usuarios/socorristas' si tu backend lo soporta.
      final resp = await _http.get('/socorristas');

      if (resp.statusCode == 200 && resp.body != null) {
        final List<dynamic> data = resp.body as List<dynamic>;
        final poolCtrl = Get.find<PoolController>();
        socorristas.value = data
            .map(
              (u) =>
                  Usuario.fromJson(u as Map<String, dynamic>, poolCtrl.pools),
            )
            .toList();
      } else {
        socorristas.clear();
      }
    } catch (e) {
      socorristas.clear();
    } finally {
      loading.value = false;
    }
  }

  /// Si deseas dar de alta un nuevo socorrista:
  Future<String?> createSocorrista(Usuario nuevoSocorrista) async {
    try {
      loading.value = true;
      final body = nuevoSocorrista.toJson()
        ..['isAdmin'] = false; // asegurar que sea socorrista
      final resp = await _http.post(
        '/crear-usuario',
        jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      loading.value = false;
      if (resp.statusCode == 200 && resp.body != null) {
        final poolCtrl = Get.find<PoolController>();
        final creado = Usuario.fromJson(
          resp.body['usuario'] as Map<String, dynamic>,
          poolCtrl.pools,
        );
        socorristas.add(creado);
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

  /// Editar un socorrista (por ej. cambiar su nombre o datos)
  Future<String?> updateSocorrista(Usuario socorrista) async {
    try {
      final body = socorrista.toJson();
      // Aseguramos que no suba a admin por error
      body['isAdmin'] = false;
      final resp = await _http.put(
        '/usuarios/${socorrista.id}',
        jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (resp.statusCode == 200 && resp.body != null) {
        final poolCtrl = Get.find<PoolController>();
        final actualizado = Usuario.fromJson(
          resp.body as Map<String, dynamic>,
          poolCtrl.pools,
        );
        final idx = socorristas.indexWhere((u) => u.id == actualizado.id);
        if (idx >= 0) {
          socorristas[idx] = actualizado;
          socorristas.refresh();
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

  /// Eliminar un socorrista
  Future<String?> deleteSocorrista(String id) async {
    try {
      final resp = await _http.delete(
        '/usuarios/$id',
        headers: {'Content-Type': 'application/json'},
      );
      if (resp.statusCode == 200) {
        socorristas.removeWhere((u) => u.id == id);
        socorristas.refresh();
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

  Future<String?> asignarHorarioEnPiscina(
    Turno nuevoTurno,
    Usuario socorrista,
  ) async {
    // 0) Comprueba solapamientos con cualquier turno existente
    for (final turnoExistente in socorrista.turnos) {
      // sólo nos importan los turnos del mismo día
      if (isSameDay(turnoExistente.start, nuevoTurno.start)) {
        final inicioN = nuevoTurno.start;
        final finN = nuevoTurno.end;
        final inicioE = turnoExistente.start;
        final finE = turnoExistente.end;
        // se solapan si: inicioN < finE && inicioE < finN
        if (inicioN.isBefore(finE) && inicioE.isBefore(finN)) {
          return '❌ El socorrista ya tiene un turno en ${turnoExistente.pool.nombre} '
              'de ${_fmtHora(inicioE)} a ${_fmtHora(finE)}';
        }
      }
    }
    try {
      loading.value = true;
      final body = nuevoTurno.toJson();
      final resp = await _http.put(
        '/socorrista/establecer-turno/${socorrista.id}',
        jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      loading.value = false;
      if (resp.statusCode == 200) {
        final poolCtrl = Get.find<PoolController>();
        final socorristaActualizado = Usuario.fromJson(
          resp.body as Map<String, dynamic>,
          poolCtrl.pools,
        );
        final index = socorristas.indexWhere(
          (u) => u.id == socorristaActualizado.id,
        );
        if (index >= 0) {
          socorristas[index] = socorristaActualizado;
          socorristas.refresh();
          if (socorristaSeleccionado.value?.id == socorristaActualizado.id) {
            socorristaSeleccionado.value = socorristaActualizado;
          }
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

  /// Elimina un turno concreto de un socorrista en el backend,
  /// usando su userId y el turnoId, y actualiza el listado local.
  /// Retorna null si todo va bien, o un mensaje de error.
  Future<String?> eliminarTurnoDeSocorrista(
    String userId,
    String turnoId,
  ) async {
    try {
      loading.value = true;
      // 1) Llamamos al endpoint DELETE /socorrista/:userId/turnos/:turnoId
      final resp = await _http.delete(
        '/socorrista/$userId/turnos/$turnoId',
        headers: {'Content-Type': 'application/json'},
      );
      loading.value = false;
      // 2) Si todo OK, el backend nos devuelve el usuario actualizado:
      if (resp.statusCode == 200 && resp.body != null) {
        final poolCtrl = Get.find<PoolController>();
        final socorristaActualizado = Usuario.fromJson(
          resp.body as Map<String, dynamic>,
          poolCtrl.pools,
        );

        // 3) Reemplazamos en nuestro listado de socorristas
        final idx = socorristas.indexWhere((u) => u.id == userId);
        if (idx >= 0) {
          final actualizado = socorristaActualizado;
          socorristas[idx] = actualizado;
          socorristas.refresh();

          if (socorristaSeleccionado.value?.id == userId) {
            socorristaSeleccionado.value = actualizado;
          }
        }
        return null;
      } else {
        // 4) Si hay error, extraemos mensaje
        final msg = (resp.body != null && resp.body is Map)
            ? (resp.body as Map)['msg'] ?? 'Error ${resp.statusCode}'
            : 'Error ${resp.statusCode}';
        return msg.toString();
      }
    } catch (e) {
      return 'Error de red: $e';
    }
  }

  /// Actualiza un turno concreto de un socorrista en el backend,
  /// usando su userId y el turnoId, y actualiza el listado local.
  /// Retorna null si todo va bien, o un mensaje de error.
  Future<String?> actualizarTurnoDeSocorrista(
    String userId,
    String turnoId,
    Turno nuevoTurno,
  ) async {
    final socorrista = socorristas.firstWhere((u) => u.id == userId);
    for (final tExist in socorrista.turnos) {
      if (tExist.id == turnoId) continue; // ignoramos el que estamos editando
      if (isSameDay(tExist.start, nuevoTurno.start)) {
        final iN = nuevoTurno.start, fN = nuevoTurno.end;
        final iE = tExist.start, fE = tExist.end;
        if (iN.isBefore(fE) && iE.isBefore(fN)) {
          return '❌ Este cambio chocaría con el turno de '
              '${tExist.pool.nombre} de ${_fmtHora(iE)} a ${_fmtHora(fE)}';
        }
      }
    }

    try {
      // 1) Llamamos al endpoint PUT /socorrista/:userId/turnos/:turnoId
      final body = nuevoTurno.toJson();
      final resp = await _http.put(
        '/socorrista/$userId/turnos/$turnoId',
        jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      // 2) Si todo OK, el backend devuelve el usuario actualizado
      if (resp.statusCode == 200 && resp.body != null) {
        final poolCtrl = Get.find<PoolController>();
        final socorristaActualizado = Usuario.fromJson(
          resp.body as Map<String, dynamic>,
          poolCtrl.pools,
        );

        // 3) Reemplazamos en nuestro listado de socorristas
        final idx = socorristas.indexWhere((u) => u.id == userId);
        if (idx >= 0) {
          final actualizado = socorristaActualizado;
          socorristas[idx] = socorristaActualizado;
          socorristas.refresh();
          if (socorristaSeleccionado.value?.id == userId) {
            socorristaSeleccionado.value = actualizado;
          }
        }
        return null;
      } else {
        // 4) Si hay error, extraemos mensaje
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
