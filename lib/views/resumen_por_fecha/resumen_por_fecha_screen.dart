import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ResumenPorFechaScreen extends StatefulWidget {
  const ResumenPorFechaScreen({super.key});

  @override
  State<ResumenPorFechaScreen> createState() => _ResumenPorFechaScreenState();
}

class _ResumenPorFechaScreenState extends State<ResumenPorFechaScreen> {
  final PoolController poolCtrl = Get.find<PoolController>();
  final SocorristasController socoCtrl = Get.find<SocorristasController>();

  DateTime fechaHoy = DateTime.now();
  DateTime? fechaSeleccionada;

  Future<void> _pickDate() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,

      initialDate: fechaSeleccionada,
      firstDate: DateTime(DateTime.now().year, 6, 1),
      lastDate: DateTime(DateTime.now().year, 12, 31),
      locale: const Locale('es', 'ES'),
    );
    if (nuevaFecha != null && nuevaFecha != fechaSeleccionada) {
      setState(() {
        fechaSeleccionada = nuevaFecha;
      });
      // aquí, si quisieras filtrar tu lista de pools por la fecha, lo harías:
      // poolCtrl.filterByDate(fechaSeleccionada);
    }
  }

  @override
  void initState() {
    super.initState();
    fechaSeleccionada = DateTime(fechaHoy.year, fechaHoy.month, fechaHoy.day);
  }

  @override
  Widget build(BuildContext context) {
    final List<Pool> pools = poolCtrl.pools;

    final List<Pool> visiblePools = pools.where((p) {
      if (p.fechaApertura == null) return true;
      // Normalizamos ambos a fecha sin hora
      final apertura = DateTime(
        p.fechaApertura!.year,
        p.fechaApertura!.month,
        p.fechaApertura!.day,
      );
      return !fechaSeleccionada!.isBefore(apertura);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resumen por fecha',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, // Punto de inicio del degradado
              end: Alignment.bottomRight, // Punto final del degradado
              colors: [
                Color.fromARGB(255, 255, 255, 255), // Color inicial
                Color.fromARGB(255, 255, 188, 188), // Color final
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      'Selecciona una fecha:  ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat(
                                  'dd/MM/yy',
                                ).format(fechaSeleccionada!),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: visiblePools.length,
                    itemBuilder: (context, index) {
                      final pool = visiblePools[index];
                      final horarios = _horariosDePoolParaFecha(
                        pool,
                        fechaSeleccionada!,
                      );
                      final mensajesError = _horarioNoCubiertoMensajes(
                        horarios,
                        pool,
                      );
                      final haySocorristas = socoCtrl.socorristas.any(
                        (soc) => soc.turnos.any(
                          (turno) =>
                              turno.pool.id == pool.id &&
                              _isSameDate(turno.start, fechaSeleccionada!),
                        ),
                      );

                      // Cadena de texto para el subtitle:
                      final horarioTexto = horarios.isEmpty
                          ? 'Cerrado'
                          : horarios.map((tr) => tr.toString()).join('  •  ');

                      return ExpansionTile(
                        leading: const FaIcon(FontAwesomeIcons.waterLadder),
                        title: Text(
                          pool.nombre,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 47, 33, 243),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'Horario: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              horarioTexto,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        trailing: (horarios.isNotEmpty && !haySocorristas)
                            ? const Icon(Icons.warning, color: Colors.red)
                            : mensajesError.isNotEmpty
                            ? const Icon(
                                Icons.error,
                                color: Color.fromARGB(255, 101, 36, 223),
                              )
                            : null,
                        children: _buildTurnosForPool(pool, mensajesError),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Widget> _buildTurnosForPool(Pool pool, List<String> mensajesError) {
    final List<Widget> tiles = [];

    tiles.addAll(
      mensajesError
          .map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.triangleExclamation),
                  SizedBox(width: 12,),
                  Expanded(
                    child: Text(
                      m,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );

    for (final soc in socoCtrl.socorristas) {
      for (final turno in soc.turnos) {
        // turno.poolId enlaza con pool.id,
        // y turno.horaInicio/turno.horaFin son TimeOfDay o DateTime
        if (turno.pool.id == pool.id &&
            _isSameDate(turno.start, fechaSeleccionada!)) {
          final String start = DateFormat.Hm().format(turno.start);
          final String end = DateFormat.Hm().format(turno.end);

          tiles.add(
            ListTile(
              leading: Text('🛟', style: TextStyle(fontSize: 20)),
              title: Text(
                soc.nombre,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$start - $end'),
            ),
          );
        }
      }
    }

    if (tiles.isEmpty) {
      tiles.add(
        const ListTile(
          title: Text('No hay socorristas asignados para esta fecha'),
          leading: Icon(Icons.info_outline),
        ),
      );
    }

    return tiles;
  }

  /// Devuelve los TimeRange válidos para [pool] en [date] según specialSchedules
  /// y weeklySchedules. Si está cerrado, la lista queda vacía.
  List<TimeRange> _horariosDePoolParaFecha(Pool pool, DateTime date) {
    // 1) Primero las excepciones puntuales
    final specials = pool.specialSchedules
        .where(
          (ss) =>
              ss.date.year == date.year &&
              ss.date.month == date.month &&
              ss.date.day == date.day,
        )
        .toList();

    // Si hay excepciones puntuales
    if (specials.isNotEmpty) {
      // Tomamos solo las que "abren"
      final abiertos = specials
          .where(
            (ss) => ss.isValidFor(
              DateTime(
                date.year,
                date.month,
                date.day,
                ss.timeRange.start.hour,
                ss.timeRange.start.minute,
              ),
            ),
          )
          .toList();

      // Si al menos uno abre, devolvemos todos esos timeRanges
      if (abiertos.isNotEmpty) {
        return abiertos.map((ss) => ss.timeRange).toList();
      }
      // Si la fecha coincide pero ninguno abre → cerrado
      return [];
    }

    // 2) Si no hay specials, miramos weeklySchedules
    final wd = date.weekday; // 1=Lun…7=Dom
    final weekly = pool.weeklySchedules.where((ws) {
      // primero el día de semana
      if (!ws.weekdays.contains(wd)) return false;
      // opcional: si ws.validoDesde/hasta != null podrías filtrar por fechas
      final desdeOk =
          ws.validoDesde == null ||
          !date.isBefore(
            DateTime(
              ws.validoDesde!.year,
              ws.validoDesde!.month,
              ws.validoDesde!.day,
            ),
          );
      final hastaOk =
          ws.validoHasta == null ||
          !date.isAfter(
            DateTime(
              ws.validoHasta!.year,
              ws.validoHasta!.month,
              ws.validoHasta!.day,
            ),
          );
      return desdeOk && hastaOk;
    }).toList();

    // Si hay reglas semanales, devolvemos sus rangos
    if (weekly.isNotEmpty) {
      return weekly.map((ws) => ws.timeRange).toList();
    }

    // 3) No hay nada → cerrado
    return [];
  }

  List<String> _horarioNoCubiertoMensajes(
    List<TimeRange> horariosPool,
    Pool pool,
  ) {
    List<String> mensajesDeError = [];

    List<TimeRange> turnosDelDia = [];

    final AuxMethods aux = AuxMethods();

    for (final soc in socoCtrl.socorristas) {
      for (final turno in soc.turnos) {
        if (turno.pool.id == pool.id &&
            _isSameDate(turno.start, fechaSeleccionada!)) {
          for (final horario in horariosPool) {
            if (!horario.contains(
              TimeOfDay(hour: turno.start.hour, minute: turno.start.minute),
            )) {
              mensajesDeError.add(
                '${aux.capitalize(soc.nombre)} empieza antes del horario establecido.',
              );
            }
            if (!horario.contains(
              TimeOfDay(hour: turno.end.hour, minute: turno.end.minute),
            )) {
              mensajesDeError.add(
                '${aux.capitalize(soc.nombre)} termina después del horario establecido.',
              );
            }
          }
          turnosDelDia.add(
            TimeRange(
              start: TimeOfDay(
                hour: turno.start.hour,
                minute: turno.start.minute,
              ),
              end: TimeOfDay(hour: turno.end.hour, minute: turno.end.minute),
            ),
          );
        }
      }
    }
    if (turnosDelDia.isEmpty) {
      return mensajesDeError;
    }

    List<TimeRange> turnosUnificados = _mergeTimeRanges(turnosDelDia);

    for (final horario in horariosPool) {
      List<TimeRange> gaps = _calculateGaps(horario, turnosUnificados);
      if (gaps.isNotEmpty) {
        mensajesDeError.add(
          'Faltan socorristas para cubrir completamente el horario de la piscina.',
        );
      }
    }

    return mensajesDeError;
  }

  List<TimeRange> _mergeTimeRanges(List<TimeRange> ranges) {
    if (ranges.isEmpty) return [];

    ranges.sort((a, b) => _compareTimeOfDay(a.start, b.start));
    List<TimeRange> result = [ranges.first];

    for (int i = 1; i < ranges.length; i++) {
      TimeRange last = result.last;
      TimeRange current = ranges[i];

      if (_overlapsOrAdjacent(last, current)) {
        result[result.length - 1] = TimeRange(
          start: last.start,
          end: _maxTimeOfDay(last.end, current.end),
        );
      } else {
        result.add(current);
      }
    }

    return result;
  }

  bool _overlapsOrAdjacent(TimeRange a, TimeRange b) {
    return !_isBefore(a.end, b.start);
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    return (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
  }

  bool _isBefore(TimeOfDay a, TimeOfDay b) {
    return _compareTimeOfDay(a, b) < 0;
  }

  TimeOfDay _maxTimeOfDay(TimeOfDay a, TimeOfDay b) {
    return _compareTimeOfDay(a, b) >= 0 ? a : b;
  }

  List<TimeRange> _calculateGaps(TimeRange horario, List<TimeRange> turnos) {
    List<TimeRange> gaps = [];

    TimeOfDay current = horario.start;

    for (final turno in turnos) {
      if (_isBefore(current, turno.start)) {
        gaps.add(TimeRange(start: current, end: turno.start));
      }
      if (_compareTimeOfDay(turno.end, current) > 0) {
        current = turno.end;
      }
    }

    if (_isBefore(current, horario.end)) {
      gaps.add(TimeRange(start: current, end: horario.end));
    }

    return gaps;
  }
}
