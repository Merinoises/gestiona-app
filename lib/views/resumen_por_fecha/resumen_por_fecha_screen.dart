import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/usuario.dart';
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
                            : null,
                        children: _buildTurnosForPool(context, pool),
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

  List<Widget> _buildTurnosForPool(BuildContext context, Pool pool) {
    final List<Widget> tiles = [];

    for (final soc in socoCtrl.socorristas) {
      for (final turno in soc.turnos) {
        // Asume que turno.fecha es DateTime,
        // turno.poolId enlaza con pool.id,
        // y turno.horaInicio/turno.horaFin son TimeOfDay o DateTime
        if (turno.pool.id == pool.id &&
            _isSameDate(turno.start, fechaSeleccionada!)) {
          final String start = DateFormat.Hm().format(turno.start);
          final String end = DateFormat.Hm().format(turno.end);

          tiles.add(
            ListTile(
              leading: FaIcon(FontAwesomeIcons.lifeRing),
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
}
