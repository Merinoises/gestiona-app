import 'package:flutter/material.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class SocoCalendarioScreen extends StatefulWidget {
  final Pool pool;
  const SocoCalendarioScreen({super.key, required this.pool});

  @override
  State<SocoCalendarioScreen> createState() => _SocoCalendarioScreenState();
}

class _SocoCalendarioScreenState extends State<SocoCalendarioScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  bool _tieneHorarioEseDia(DateTime day) {
    final fechaApertura = widget.pool.fechaApertura;
    if (fechaApertura != null && day.isBefore(fechaApertura)) {
      return false;
    }

    // 1) ¿Hay alguna excepción puntual para esa fecha?
    for (final ex in widget.pool.specialSchedules) {
      if (ex.date.year == day.year &&
          ex.date.month == day.month &&
          ex.date.day == day.day) {
        // Si existe SpecialSchedule para ese día → ¡está abierto, al menos en algún tramo!
        return true;
      }
    }
    // 2) ¿Hay alguna regla semanal que incluya el weekday de 'day'?
    for (final ws in widget.pool.weeklySchedules) {
      if (ws.weekdays.contains(day.weekday)) {
        // Si la regla semanal cubre ese weekday → abre en algún horario ese día.
        return true;
      }
    }
    // Si ni en specialSchedules ni en weeklySchedules hay nada → permanece cerrado.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final usuario = authService.usuario.value!;
    // Filtrar solo los turnos de ESTE usuario y ESTA piscina:
    final misTurnosEnPool = usuario.turnos
        .where((t) => t.pool.id == widget.pool.id)
        .toList();
    // Crear set de fechas con turno
    final diasConTurno = misTurnosEnPool
        .map((t) => DateTime(t.start.year, t.start.month, t.start.day))
        .toSet();

    // Map<String,List<Turno>> para el día seleccionado, pero solo este usuario:
    final turnosHoy = misTurnosEnPool
        .where((t) => isSameDay(t.start, _selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.pool.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(DateTime.now().year, 6, 1),
              lastDay: DateTime(DateTime.now().year, 10, 30),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onFormatChanged: (f) => setState(() => _calendarFormat = f),
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              onDaySelected: (d, f) {
                setState(() {
                  _selectedDay = d;
                  _focusedDay = f;
                });
              },
              enabledDayPredicate: (d) => _tieneHorarioEseDia(d),
              locale: 'es_ES',

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, date, focusedDate) {
                  final dayKey = DateTime(date.year, date.month, date.day);
                  // cerrado
                  if (!_tieneHorarioEseDia(date)) {
                    return null; // usa disabledDecoration
                  }
                  // abierto + tiene turno
                  if (diasConTurno.contains(dayKey)) {
                    return Container(
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade300,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  // abierto + sin turno
                  return Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('${date.day}'),
                  );
                },
                todayBuilder: (ctx, date, _) {
                  return Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),

              calendarStyle: CalendarStyle(
                disabledDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                disabledTextStyle: TextStyle(color: Colors.black38),
                markerDecoration: BoxDecoration(), // no usamos marcadores
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Turnos del día ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (turnosHoy.isEmpty) Text('No tienes turnos asignados'),
            ...turnosHoy.map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  t.fechaYHoraDetallada(),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
