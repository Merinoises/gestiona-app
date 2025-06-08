import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Representa un intervalo horario (hours:minutes) dentro de un mismo día.
/// Ejemplo: 08:00–20:00.
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end});

  /// Convierte un TimeOfDay a “minutos desde medianoche”.
  int _totalMin(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Comprueba si [time] cae dentro de este rango (inclusive).
  bool contains(TimeOfDay time) {
    final int tStart = _totalMin(start);
    final int tEnd = _totalMin(end);
    final int tCheck = _totalMin(time);

    // Si el rango cruza medianoche (p. ej.: start=22:00, end=03:00):
    if (tStart <= tEnd) {
      return tCheck >= tStart && tCheck <= tEnd;
    } else {
      // Caso cruzado: hora >= start (hasta 23:59) O hora <= end (a partir de 00:00)
      return tCheck >= tStart || tCheck <= tEnd;
    }
  }

  @override
  String toString() {
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return '${fmt(start)} a ${fmt(end)}';
  }

  /// Para serializar a JSON (p. ej. enviar este rango al backend)
  Map<String, dynamic> toJson() {
    return {
      'startHour': start.hour,
      'startMinute': start.minute,
      'endHour': end.hour,
      'endMinute': end.minute,
    };
  }

  /// Construye un TimeRange a partir del JSON:
  /// {
  ///   "startHour": 8,
  ///   "startMinute": 0,
  ///   "endHour": 20,
  ///   "endMinute": 0
  /// }
  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: TimeOfDay(
        hour: json['startHour'] as int,
        minute: json['startMinute'] as int,
      ),
      end: TimeOfDay(
        hour: json['endHour'] as int,
        minute: json['endMinute'] as int,
      ),
    );
  }
}

/// Regla de horario recurrente para ciertos días de la semana.
/// Ejemplo: lunes–jueves de 08:00 a 20:00.
class WeeklySchedule {
  /// Lista de enteros 1..7 (1=lunes, …,7=domingo)
  final List<int> weekdays;
  final TimeRange timeRange;
  final DateTime? validoDesde;
  final DateTime? validoHasta;

  WeeklySchedule({
    required this.weekdays,
    required this.timeRange,
    this.validoDesde,
    this.validoHasta,
  });

  /// Comprueba si [dateTime] cae dentro de este horario semanal.
  bool isValidFor(DateTime dateTime) {
    final int wd = dateTime.weekday; // 1=lunes,…,7=domingo
    if (!weekdays.contains(wd)) return false;
    final checkTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    return timeRange.contains(checkTime);
  }

  @override
  String toString() {
    String dias = weekdays
        .map((d) {
          switch (d) {
            case DateTime.monday:
              return 'Lun';
            case DateTime.tuesday:
              return 'Mar';
            case DateTime.wednesday:
              return 'Mié';
            case DateTime.thursday:
              return 'Jue';
            case DateTime.friday:
              return 'Vie';
            case DateTime.saturday:
              return 'Sáb';
            case DateTime.sunday:
              return 'Dom';
            default:
              return '';
          }
        })
        .join(',');
    return '$dias: $timeRange';
  }

  /// Para serializar a JSON:
  /// {
  ///   "weekdays": [1,2,3,4],
  ///   "timeRange": { "startHour": 8, "startMinute": 0, "endHour": 20, "endMinute": 0 }
  /// }
  Map<String, dynamic> toJson() {
    return {'weekdays': weekdays, 'timeRange': timeRange.toJson()};
  }

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) {
    return WeeklySchedule(
      weekdays: List<int>.from(json['weekdays'] as List),
      timeRange: TimeRange.fromJson(json['timeRange'] as Map<String, dynamic>),
    );
  }
}

/// Excepción puntual para una fecha concreta.
/// Ejemplo: 25/12/2025 de 10:00 a 16:00 (Navidad).
class SpecialSchedule {
  final DateTime date; // Considerar solo año/mes/día (hora = 00:00)
  final TimeRange timeRange;

  SpecialSchedule({required this.date, required this.timeRange});

  bool isValidFor(DateTime dateTime) {
    if (date.year != dateTime.year ||
        date.month != dateTime.month ||
        date.day != dateTime.day) {
      return false;
    }
    final checkTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    return timeRange.contains(checkTime);
  }

  @override
  String toString() {
    final f =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
    return '[$f] $timeRange';
  }

  /// Para serializar a JSON:
  /// {
  ///   "date": "2025-12-25T00:00:00.000Z",
  ///   "timeRange": { "startHour": 10, "startMinute": 0, "endHour": 16, "endMinute": 0 }
  /// }
  Map<String, dynamic> toJson() {
    return {
      'date': DateFormat('yyyy-MM-dd').format(date),
      'timeRange': timeRange.toJson(),
    };
  }

  factory SpecialSchedule.fromJson(Map<String, dynamic> json) {
    // parseamos sólo la parte fecha, luego normalizamos a medianoche LOCAL
    final raw = json['date'] as String;               // e.g. "2025-06-18"
    final d = DateTime.parse(raw);                    // 2025-06-18 00:00:00.000 (local)
    final localDate = DateTime(d.year, d.month, d.day);
    return SpecialSchedule(
      date: localDate,
      timeRange: TimeRange.fromJson(json['timeRange']),
    );
  }
}

/// Modelo de una Piscina, ahora con horarios asociados.
class Pool {
  final String? id;
  final String nombre;
  final String ubicacion;
  final DateTime? fechaApertura;

  /// Reglas semanales (p. ej. lunes–jueves 08:00–20:00, viernes–sábado 08:00–22:00, etc.).
  final List<WeeklySchedule> weeklySchedules;

  /// Excepciones puntuales (p. ej. 25/12 horario especial, 01/01 cerrado).
  final List<SpecialSchedule> specialSchedules;

  Pool({
    this.id,
    required this.nombre,
    required this.ubicacion,
    this.fechaApertura,
    List<WeeklySchedule>? weeklySchedules,
    List<SpecialSchedule>? specialSchedules,
  }) : weeklySchedules = weeklySchedules ?? [],
       specialSchedules = specialSchedules ?? [];

  /// Comprueba si la piscina está “abierta” en [dateTime].
  bool isOpenAt(DateTime dateTime) {
    // 1) Verificar excepciones puntuales primero.
    for (final ex in specialSchedules) {
      if (ex.isValidFor(dateTime)) {
        return true;
      }
      // Si la fecha coincide pero la hora NO entra en el rango, devolvemos false:
      if (ex.date.year == dateTime.year &&
          ex.date.month == dateTime.month &&
          ex.date.day == dateTime.day) {
        return false;
      }
    }
    // 2) Si no hay excepción, revisar horarios semanales.
    for (final regla in weeklySchedules) {
      if (regla.isValidFor(dateTime)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    return 'Pool {id: $id, nombre: $nombre, ubicacion: $ubicacion}\n'
        'Weekly:\n${weeklySchedules.join('\n')}\n'
        'Special:\n${specialSchedules.join('\n')}';
  }

  /// Serializa a JSON para enviar al backend:
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'ubicacion': ubicacion,
      'weeklySchedules': weeklySchedules.map((ws) => ws.toJson()).toList(),
      'specialSchedules': specialSchedules.map((ss) => ss.toJson()).toList(),
    };

    // Sólo incluir "fechaApertura" si no es null
    if (fechaApertura != null) {
      map['fechaApertura'] = fechaApertura!.toIso8601String();
    }

    // Si el campo 'id' se debe enviar (p.ej. en PUT), lo añadimos.
    if (id != null) {
      map['_id'] = id;
    }
    return map;
  }

  /// Construye un Pool desde JSON (respuesta de la API).
  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json['_id'] as String?,
      nombre: json['nombre'] as String,
      ubicacion: json['ubicacion'] as String,
      fechaApertura: json['fechaApertura'] != null
          ? DateTime.parse(json['fechaApertura'] as String).toLocal()
          : null,
      weeklySchedules: (json['weeklySchedules'] as List<dynamic>? ?? [])
          .map((w) => WeeklySchedule.fromJson(w as Map<String, dynamic>))
          .toList(),
      specialSchedules: (json['specialSchedules'] as List<dynamic>? ?? [])
          .map((s) => SpecialSchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
