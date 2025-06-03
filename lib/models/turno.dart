import 'pool.dart';

/// Cada turno asignado a un socorrista.
/// - pool: la piscina donde trabaja.
/// - start/end: DateTime exactos de inicio y fin (pueden incluir minutos).
class Turno {
  final Pool pool;
  final DateTime start;
  final DateTime end;

  Turno({
    required this.pool,
    required this.start,
    required this.end,
  });

  /// Duración de este turno (puede ser, p. ej., 8h30m, 6h15m, etc.).
  Duration get duracion => end.difference(start);

  @override
  String toString() {
    final hIni = start.hour.toString().padLeft(2, '0');
    final mIni = start.minute.toString().padLeft(2, '0');
    final hFin = end.hour.toString().padLeft(2, '0');
    final mFin = end.minute.toString().padLeft(2, '0');
    final hTot = duracion.inHours;
    final mTot = duracion.inMinutes.remainder(60);
    return '${pool.nombre}: $hIni:$mIni – $hFin:$mFin ($hTot h $mTot m)';
  }

  /// Para serializar a JSON:
  /// {
  ///   "poolId": "<id de la piscina>",
  ///   "start": "2025-06-01T08:00:00.000Z",
  ///   "end":   "2025-06-01T16:30:00.000Z"
  /// }
  Map<String, dynamic> toJson() {
    return {
      'poolId': pool.id,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  /// Reconstruye un Turno desde JSON. Necesita la lista completa de Pools para enlazar poolId → Pool.
  factory Turno.fromJson(
    Map<String, dynamic> json,
    List<Pool> allPools,
  ) {
    final pid = json['poolId'] as String;
    final poolMatch = allPools.firstWhere(
      (p) => p.id == pid,
      orElse: () => throw Exception('Pool no encontrado: $pid'),
    );
    return Turno(
      pool: poolMatch,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }
}
