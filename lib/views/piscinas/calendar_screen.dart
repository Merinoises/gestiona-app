import 'package:flutter/material.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioScreen extends StatefulWidget {
  final Pool pool;

  const CalendarioScreen({super.key, required this.pool});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  // Valor que guardará la fecha del día seleccionado:
  DateTime _selectedDay = DateTime.now();
  // Mes que se está mostrando actualmente en la cabecera:
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

  /// Devuelve la lista de TimeRange que aplican para [day]:
  /// - Primero busca SpecialSchedule que coincida exactamente con [day].
  /// - Si no hay excepciones, busca todas las WeeklySchedule cuyo weekday matchee.
  /// - Si no encuentra nada, devuelve lista vacía.
  List<TimeRange> _horariosParaDia(DateTime day) {
    // 1) Buscar excepciones puntuales:
    final excepciones = widget.pool.specialSchedules
        .where((ex) =>
            ex.date.year == day.year &&
            ex.date.month == day.month &&
            ex.date.day == day.day)
        .map((ex) => ex.timeRange)
        .toList();
    if (excepciones.isNotEmpty) {
      return excepciones;
    }
    // 2) Si no hay excepción, buscar reglas semanales:
    final List<TimeRange> resultado = [];
    for (final ws in widget.pool.weeklySchedules) {
      if (ws.weekdays.contains(day.weekday)) {
        resultado.add(ws.timeRange);
      }
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final horariosHoy = _horariosParaDia(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              // Rango de fechas: desde enero de 2020 hasta diciembre de 2030 (ajusta a tus necesidades)
              firstDay: DateTime(DateTime.now().year, 6, 1),
              lastDay: DateTime(DateTime.now().year, 10, 30),
              focusedDay: _focusedDay,

              calendarFormat: _calendarFormat,
              availableCalendarFormats: {
                CalendarFormat.month: 'Mes',
                CalendarFormat.week: 'Semana',
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },

              startingDayOfWeek: StartingDayOfWeek.monday,

              enabledDayPredicate: (day) => _tieneHorarioEseDia(day),

              // Mapa de eventos si quieres mostrar marcadores (aquí vacío)
              eventLoader: (day) {
                return <
                  String
                >[]; // si tuvieras un Map<DateTime, List<Event>>, devuélvelo aquí
              },

              // Configuración de estilos (opcional)
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepOrange,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                disabledTextStyle: TextStyle(color: Colors.grey),
                disabledDecoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),

              // Día seleccionado
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },

              // Cuando el usuario selecciona un día
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },

              // Cuando cambia el mes (al avanzar/agregar flechas)
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },

              // Configurar idioma (opcional, requerir intl y localización en MaterialApp)
              locale: 'es_ES',
            ),

            const SizedBox(height: 20),

            // ---------------------------------------------------
            //  Aquí mostramos la información de horarios para _selectedDay:
            // ---------------------------------------------------
            if (!_tieneHorarioEseDia(_selectedDay))
              // No hay ningún horario: la piscina cierra
              const Text(
                'Piscina cerrada hoy',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              )
            else
              // Hay uno o más TimeRange, los listamos:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horario de apertura - Día ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Para cada TimeRange, mostramos un Text
                  ...horariosHoy.map((tr) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          tr.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      )),
                ],
              ),

            // ---------------------------------------------------
          ],
        ),
      ),
    );
  }
}
