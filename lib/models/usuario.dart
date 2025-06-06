import 'package:gestiona_app/models/pool.dart';

import 'turno.dart';

/// Usuarios de la app (pueden ser admins o socorristas).
class Usuario {
  final String? id;
  final String nombre;
  final String? password;
  final DateTime? createdAt;

  /// Si true → este usuario es administrador (no tiene turnos ni tarifas).
  final bool isAdmin;

  /// €/hora para el socorrista. Si isAdmin == true, queda en null.

  /// Lista de turnos asignados (solo para socorristas).
  final List<Turno> turnos;

  Usuario({
    this.id,
    required this.nombre,
    this.password,
    this.createdAt,
    required this.isAdmin,
    List<Turno>? turnos,
  }) : turnos = turnos ?? [];

  /// Crea un Usuario a partir de JSON de la API. Necesita allPools para reconstruir turnos.
  factory Usuario.fromJson(Map<String, dynamic> json, List<Pool> allPools) {
    final bool rolAdmin = (json['isAdmin'] as bool?) ?? false;

    // Reconstruir lista de turnos:
    final List<Turno> listaTurnos = (json['turnos'] as List<dynamic>? ?? [])
        .map((t) => Turno.fromJson(t as Map<String, dynamic>, allPools))
        .toList();

    return Usuario(
      id: json['_id'] as String?,
      nombre: json['nombre'] as String,
      password: json['password'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isAdmin: rolAdmin,
      turnos: listaTurnos,
    );
  }

  /// Convierte este Usuario a JSON para enviar a la API:
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'isAdmin': isAdmin,
      if (password != null) 'password': password!,
    };
    if (turnos.isNotEmpty) {
      map['turnos'] = turnos.map((t) => t.toJson()).toList();
    }
    if (id != null) {
      map['_id'] = id;
    }
    if (createdAt != null) {
      map['createdAt'] = createdAt!.toIso8601String();
    }
    return map;
  }

  /// Crear una copia modificada (útil para actualizaciones en UI).
  Usuario copyWith({
    String? id,
    String? nombre,
    String? password,
    DateTime? createdAt,
    bool? isAdmin,
    List<Turno>? turnos,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      turnos: turnos ?? List<Turno>.from(this.turnos),
    );
  }

  @override
  String toString() {
    return 'Usuario {id: $id, nombre: $nombre, isAdmin: $isAdmin';
  }

  /// Acumula todas las duraciones de los turnos cuyo start.year == [anyo] y start.month == [mes].
  Duration totalHorasEnMes(int anyo, int mes) {
    Duration total = Duration.zero;
    for (final turno in turnos) {
      if (turno.start.year == anyo && turno.start.month == mes) {
        total += turno.duracion;
      }
    }
    return total;
  }

  // Calcula el importe a pagar en ese [anyo]-[mes], a razón de 9 €/hora,
  /// teniendo en cuenta también los minutos parciales.
  double importeAPagarEnMes(int anyo, int mes) {
    // 1) Obtenemos la duración total de los turnos en ese mes:
    final Duration totalDuracion = totalHorasEnMes(anyo, mes);

    // 2) Convertimos la duración a minutos (enteros) y luego a horas en doble:
    final double horasExactas = totalDuracion.inMinutes / 60.0;

    // 3) A 9 €/hora:
    return horasExactas * 9.0;
  }

  double importeTotalTurnos() {
    // 1) Sumamos la duración de todos los turnos:
    Duration duracionTotal = Duration.zero;
    for (final turno in turnos) {
      duracionTotal += turno.duracion;
    }
    // 2) Convertimos a horas en valor con decimales:
    final double horasExactas = duracionTotal.inMinutes / 60.0;
    // 3) A 9 €/hora:
    return horasExactas * 9.0;
  }
}
