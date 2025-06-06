import 'package:intl/intl.dart';
import 'pool.dart';

/// Cada turno asignado a un socorrista.
/// - id: identificador único del subdocumento en MongoDB.
/// - pool: la piscina donde trabaja.
/// - start/end: DateTime exactos de inicio y fin (pueden incluir minutos).
class Turno {
  final String id;
  final Pool pool;
  final DateTime start;
  final DateTime end;

  Turno({
    required this.id,
    required this.pool,
    required this.start,
    required this.end,
  });

  /// Duración de este turno (p. ej., 8h30m, 6h15m, etc.).
  Duration get duracion => end.difference(start);

  @override
  String toString() {
    final hIni = start.hour.toString().padLeft(2, '0');
    final mIni = start.minute.toString().padLeft(2, '0');
    final hFin = end.hour.toString().padLeft(2, '0');
    final mFin = end.minute.toString().padLeft(2, '0');
    final hTot = duracion.inHours;
    final mTot = duracion.inMinutes.remainder(60);
    return '[$id] ${pool.nombre}: $hIni:$mIni – $hFin:$mFin ($hTot h $mTot m)';
  }

  String stringSoloHoras() {
    final hIni = start.hour.toString().padLeft(2, '0');
    final mIni = start.minute.toString().padLeft(2, '0');
    final hFin = end.hour.toString().padLeft(2, '0');
    final mFin = end.minute.toString().padLeft(2, '0');
    final hTot = duracion.inHours;
    final mTot = duracion.inMinutes.remainder(60);
    return '🕒 $hIni:$mIni – $hFin:$mFin ($hTot h $mTot m)';
  }

  /// Devuelve una cadena con el formato:
  /// "dd/MM/yyyy - DíaDeLaSemana - Horario: HH:mm a HH:mm"
  String fechaYHoraDetallada() {
    // 1) Formato de fecha "dd/MM/yyyy"
    final String fechaFormateada = DateFormat('dd/MM/yyyy').format(start);

    // 2) Día de la semana en español (por ejemplo, "viernes")
    //    y capitalizamos la primera letra para obtener "Viernes"
    final String diaSemanaMinus = DateFormat('EEEE', 'es_ES').format(start);
    final String diaSemana = diaSemanaMinus[0].toUpperCase() +
        diaSemanaMinus.substring(1);

    // 3) Horas de inicio y fin en "HH:mm"
    final String horaInicio =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final String horaFin =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    // 4) Construimos el string final
    return '$fechaFormateada - $diaSemana - Horario: $horaInicio a $horaFin';
  }

  /// Para serializar a JSON (solo campos necesarios al crear o actualizar):
  /// {
  ///   "poolId": "<id de la piscina>",
  ///   "start": "2025-06-01T08:00:00.000Z",
  ///   "end":   "2025-06-01T16:30:00.000Z"
  /// }
  Map<String, dynamic> toJson() {
    return {
      'poolId': pool.id,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
    };
  }

  /// Reconstruye un Turno desde JSON recibido del servidor.
  /// Necesita la lista completa de Pools para enlazar poolId → Pool.
  factory Turno.fromJson(
    Map<String, dynamic> json,
    List<Pool> allPools,
  ) {
    // 1) Capturamos el _id del subdocumento
    final String turnoId = json['_id'] as String;

    // 2) Encontramos el Pool correspondiente
    final String pid = json['poolId'] as String;
    final poolMatch = allPools.firstWhere(
      (p) => p.id == pid,
      orElse: () => throw Exception('Pool no encontrado: $pid'),
    );

    // 3) Parseamos las fechas y las convertimos a hora local
    final DateTime startLocal =
        DateTime.parse(json['start'] as String).toLocal();
    final DateTime endLocal = DateTime.parse(json['end'] as String).toLocal();

    return Turno(
      id: turnoId,
      pool: poolMatch,
      start: startLocal,
      end: endLocal,
    );
  }
}
