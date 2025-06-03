import 'package:gestiona_app/models/pool.dart';

import 'turno.dart';

/// Usuarios de la app (pueden ser admins o socorristas).
class Usuario {
  final String? id;
  final String nombre;
  final String? password;
  final DateTime? createdAt;

  /// Si true → este usuario es administrador (no tiene turnos ni tarifas).
  /// Si false → es socorrista y debe tener tarifaHoraria y turnos.
  final bool isAdmin;

  /// €/hora para el socorrista. Si isAdmin == true, queda en null.
  final double? tarifaHoraria;

  /// Lista de turnos asignados (solo para socorristas).
  final List<Turno> turnos;

  Usuario({
    this.id,
    required this.nombre,
    required this.password,
    this.createdAt,
    this.isAdmin = false,
    this.tarifaHoraria,
    List<Turno>? turnos,
  }) : turnos = turnos ?? [];

  /// Crea un Usuario a partir de JSON de la API. Necesita allPools para reconstruir turnos.
  factory Usuario.fromJson(
    Map<String, dynamic> json,
    List<Pool> allPools,
  ) {
    final bool rolAdmin = (json['isAdmin'] as bool?) ?? false;
    final double? tarifa = (json['tarifaHoraria'] as num?)?.toDouble();

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
      tarifaHoraria: tarifa,
      turnos: listaTurnos,
    );
  }

  /// Convierte este Usuario a JSON para enviar a la API:
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'isAdmin': isAdmin,
      if (password != null)       'password': password!,
      if (tarifaHoraria != null)  'tarifaHoraria': tarifaHoraria!,
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
    double? tarifaHoraria,
    List<Turno>? turnos,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      tarifaHoraria: tarifaHoraria ?? this.tarifaHoraria,
      turnos: turnos ?? List<Turno>.from(this.turnos),
    );
  }

  @override
  String toString() {
    return 'Usuario {id: $id, nombre: $nombre, isAdmin: $isAdmin, '
        'tarifa: $tarifaHoraria, turnos: ${turnos.length}}';
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

  /// Calcula el importe a pagar en ese [anyo]-[mes], en función de tarifaHoraria.
  double importeAPagarEnMes(int anyo, int mes) {
    if (isAdmin || tarifaHoraria == null) return 0.0;
    final duracionTotal = totalHorasEnMes(anyo, mes);
    final horasDecimal = duracionTotal.inMinutes / 60.0;
    return horasDecimal * tarifaHoraria!;
  }
}
