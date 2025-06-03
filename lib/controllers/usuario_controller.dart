// usuario_controller.dart

import 'package:get/get.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/turno.dart';
import 'package:gestiona_app/models/usuario.dart';

/// Controlador que mantiene el estado del usuario que está usando la app.
/// Usa GetX para que, al cambiar cualquier dato de [usuario], la UI reaccione automáticamente.
class UsuarioController extends GetxController {
  /// El usuario actual. Si no hay nadie logueado, será `null`.
  final Rxn<Usuario> usuario = Rxn<Usuario>();

  /// Lista de todas las piscinas (necesaria para reconstruir turnos al actualizar usuario desde JSON).
  final RxList<Pool> allPools = <Pool>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Aquí podrías, por ejemplo, cargar las piscinas iniciales
    // o escuchar a algún servicio externo (AuthService) para poblar `usuario`.
  }

  /// Indica si hay un usuario logueado en este momento.
  bool get isLoggedIn => usuario.value != null;

  /// Devuelve el Usuario “raw” si existe, o lanza excepción si no hay ninguno.
  Usuario get user {
    final u = usuario.value;
    if (u == null) throw Exception('No hay usuario logueado');
    return u;
  }

  /// Asigna un nuevo Usuario (p. ej. tras hacer login).
  /// [u] ya debe venir con todos sus campos (incluyendo turnos reconstruidos).
  void setUsuario(Usuario u) {
    usuario.value = u;
  }

  /// Limpia el usuario (p. ej. en logout).
  void clearUsuario() {
    usuario.value = null;
  }

  /// Actualiza la lista de piscinas (por ejemplo, después de _cargarTodasLasPiscinas).
  /// Esto es necesario si luego quieres reconstruir turnos desde JSON.
  void setPools(List<Pool> pools) {
    allPools.assignAll(pools);
  }

  /// Actualiza el usuario a partir de JSON (por ejemplo, cuando renuevas token).
  /// Necesita [allPools] ya cargadas para poder reconstruir los turnos.
  void updateUsuarioFromJson(Map<String, dynamic> json) {
    // Asegurarnos de que allPools no esté vacío
    if (allPools.isEmpty) {
      throw Exception('Debe llamar a setPools(...) antes de reconstruir Usuario desde JSON');
    }
    final nuevo = Usuario.fromJson(json, allPools);
    usuario.value = nuevo;
  }

  /// Cambia la tarifa horaria del usuario (solo si NO es admin).
  /// Si es admin, lanza excepción.
  void updateTarifa(double nuevaTarifa) {
    final u = user;
    if (u.isAdmin) {
      throw Exception('No se puede actualizar tarifa de un administrador');
    }
    usuario.value = u.copyWith(tarifaHoraria: nuevaTarifa);
  }

  /// Agrega un turno nuevo al usuario (y notifica a la UI).
  /// [turno] debe contener el objeto Pool completo.
  void addTurno(Turno turno) {
    final u = user;
    if (u.isAdmin) {
      throw Exception('Un administrador no tiene turnos');
    }
    final nuevaLista = List<Turno>.from(u.turnos)..add(turno);
    usuario.value = u.copyWith(turnos: nuevaLista);
  }

  /// Elimina un turno por su índice en la lista.
  void removeTurnoAt(int index) {
    final u = user;
    if (u.isAdmin) {
      throw Exception('Un administrador no tiene turnos');
    }
    if (index < 0 || index >= u.turnos.length) {
      throw Exception('Índice de turno inválido');
    }
    final nuevaLista = List<Turno>.from(u.turnos)..removeAt(index);
    usuario.value = u.copyWith(turnos: nuevaLista);
  }

  /// Reemplaza un turno existente en [index] por [turnoActualizado].
  void updateTurnoAt(int index, Turno turnoActualizado) {
    final u = user;
    if (u.isAdmin) {
      throw Exception('Un administrador no tiene turnos');
    }
    if (index < 0 || index >= u.turnos.length) {
      throw Exception('Índice de turno inválido');
    }
    final nuevaLista = List<Turno>.from(u.turnos);
    nuevaLista[index] = turnoActualizado;
    usuario.value = u.copyWith(turnos: nuevaLista);
  }

  /// Devuelve la lista de turnos actuales (vacía si es admin o no hay usuario).
  List<Turno> get turnos {
    final u = usuario.value;
    if (u == null) return [];
    return List.unmodifiable(u.turnos);
  }

  /// Total de horas trabajadas en [anyo] y [mes], o Duration.zero si es admin o no hay usuario.
  Duration totalHorasEnMes(int anyo, int mes) {
    final u = usuario.value;
    if (u == null || u.isAdmin) return Duration.zero;
    return u.totalHorasEnMes(anyo, mes);
  }

  /// Importe a pagar en [anyo]-[mes], o 0.0 si es admin o no hay usuario.
  double importeAPagarEnMes(int anyo, int mes) {
    final u = usuario.value;
    if (u == null || u.isAdmin) return 0.0;
    return u.importeAPagarEnMes(anyo, mes);
  }

  /// Ejemplo de método que podrías llamar desde UI para modificar
  /// el nombre del usuario (si tu API lo permite).
  void updateNombre(String nuevoNombre) {
    final u = user;
    usuario.value = u.copyWith(nombre: nuevoNombre);
  }

  @override
  void onClose() {
    // Si necesitas limpiar algo, lo harías aquí.
    super.onClose();
  }
}

