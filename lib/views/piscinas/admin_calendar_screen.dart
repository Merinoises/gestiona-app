import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/turno.dart';
import 'package:gestiona_app/models/usuario.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:gestiona_app/widgets/admin/turnos/editar_o_eliminar_turno.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendarioScreen extends StatefulWidget {
  final Pool pool;

  const AdminCalendarioScreen({super.key, required this.pool});

  @override
  State<AdminCalendarioScreen> createState() => _AdminCalendarioScreenState();
}

class _AdminCalendarioScreenState extends State<AdminCalendarioScreen> {
  // Valor que guardará la fecha del día seleccionado:
  DateTime _selectedDay = DateTime.now();
  // Mes que se está mostrando actualmente en la cabecera:
  DateTime _focusedDay = DateTime.now();
  late int _currentMonth;

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
        .where(
          (ex) =>
              ex.date.year == day.year &&
              ex.date.month == day.month &&
              ex.date.day == day.day,
        )
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

  void mostrarSelectorHorarioSocorrista(
    BuildContext context,
    Pool pool,
    DateTime fechaDia,
  ) {
    final AuxMethods auxMethods = AuxMethods();
    final formKey = GlobalKey<FormState>();

    final SocorristasController socorristasCtrl =
        Get.find<SocorristasController>();
    Rx<TimeOfDay?> horaInicio = socorristasCtrl.horaInicioTurno;
    Rx<TimeOfDay?> horaFinal = socorristasCtrl.horaFinalTurno;
    Rx<String> mensajeError = socorristasCtrl.mensajeError;
    Rx<Usuario?> socorristaSeleccionado =
        socorristasCtrl.socorristaSeleccionado;

    horaInicio.value = null;
    horaFinal.value = null;
    mensajeError.value = '';
    socorristaSeleccionado.value = null;

    List<Usuario> listaSocorristas = socorristasCtrl.socorristas;

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors
            .transparent, // opcional: para que el degradado sea visible en los bordes
        contentPadding: EdgeInsets
            .zero, // para que el contenido ocupe todo el espacio disponible dentro del AlertDialog
        content: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topLeft, // Punto de inicio del degradado
              end: Alignment.bottomRight, // Punto final del degradado
              colors: [
                Color.fromARGB(255, 255, 255, 255), // Color inicial
                Color.fromARGB(255, 191, 237, 255), // Color final
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CREAR HORARIO DE SOCORRISTA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Text(
                  'Selección de socorrista',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: DropdownButtonFormField<Usuario>(
                    decoration: InputDecoration(
                      labelText: 'Socorrista',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: listaSocorristas.map((Usuario s) {
                      return DropdownMenuItem<Usuario>(
                        value: s,
                        child: Text(s.nombre),
                      );
                    }).toList(),
                    value: socorristaSeleccionado.value,
                    hint: const Text('Selecciona un socorrista'),
                    onChanged: (socorrista) {
                      socorristaSeleccionado.value = socorrista;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Debes elegir un socorrista';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Horas de inicio y finalización',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              horaInicio.value = await auxMethods
                                  .pickHoraInicio(context);
                            },
                            child: Text('Hora inicial'),
                          ),
                          horaInicio.value != null
                              ? SizedBox(height: 10)
                              : SizedBox.shrink(),
                          horaInicio.value != null
                              ? Text(
                                  horaInicio.value!.format(context),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),

                      SizedBox(width: 10),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              horaFinal.value = await auxMethods
                                  .pickHoraFinalizacion(context);
                            },
                            child: Text('Hora final'),
                          ),
                          horaFinal.value != null
                              ? SizedBox(height: 10)
                              : SizedBox.shrink(),
                          horaFinal.value != null
                              ? Text(
                                  horaFinal.value!.format(context),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Obx(
                  () => ElevatedButton(
                    onPressed: socorristasCtrl.loading.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              // Si el dropdown no está seleccionado, no continua
                              return;
                            }
                            if (horaInicio.value == null ||
                                horaFinal.value == null) {
                              mensajeError.value =
                                  'Escoja la hora de inicio y finalización';
                              return;
                            }
                            // Convertimos la hora de inicio y fin a minutos para comparar con facilidad:
                            final int newStartMin =
                                horaInicio.value!.hour * 60 +
                                horaInicio.value!.minute;
                            final int newEndMin =
                                horaFinal.value!.hour * 60 +
                                horaFinal.value!.minute;
                            if (newStartMin > newEndMin) {
                              mensajeError.value =
                                  'La hora de finalización ha de ser posterior a la de inicio';
                              return;
                            }

                            final fechaYHoraInicio = DateTime(
                              fechaDia.year,
                              fechaDia.month,
                              fechaDia.day,
                              horaInicio.value!.hour,
                              horaInicio.value!.minute,
                            );
                            final fechaYHoraFinal = DateTime(
                              fechaDia.year,
                              fechaDia.month,
                              fechaDia.day,
                              horaFinal.value!.hour,
                              horaFinal.value!.minute,
                            );
                            Turno nuevoTurno = Turno(
                              id: '',
                              pool: pool,
                              start: fechaYHoraInicio,
                              end: fechaYHoraFinal,
                            );
                            socorristasCtrl.loading.value = true;
                            final String? resp = await socorristasCtrl
                                .asignarHorarioEnPiscina(
                                  nuevoTurno,
                                  socorristaSeleccionado.value!,
                                );
                            if (resp == null) {
                              Get.back();
                              socorristasCtrl.loading.value = false;
                              final index = listaSocorristas.indexWhere(
                                (u) => u.id == socorristaSeleccionado.value!.id,
                              );
                              final Usuario socorristaModificado =
                                  listaSocorristas[index];
                              setState(() {
                                return;
                              });
                              Get.snackbar(
                                'Turno agregado a ${socorristaModificado.nombre}',
                                'Añadido el turno $nuevoTurno',
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.white,
                              );
                            } else {
                              Get.back();
                              socorristasCtrl.loading.value = false;
                              Get.snackbar('Error', resp);
                            }
                          },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue[400]),
                    ),
                    child: socorristasCtrl.loading.value
                        ? Center(child: CircularProgressIndicator())
                        : Text(
                            'Guardar horario',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 8),
                Obx(
                  () => mensajeError.value != ''
                      ? Text(
                          mensajeError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<Turno>> mostrarTurnosDelDia(
    DateTime dia,
    Pool pool,
    List<Usuario> socorristas,
  ) {
    final Map<String, List<Turno>> listaDeTurnosPorSocorrista = {};

    for (var socorrista in socorristas) {
      //0) Filtramos por piscina
      final turnosPorPiscina = socorrista.turnos.where(
        (turno) => turno.pool.id == pool.id,
      );
      // 1) Filtramos solo los turnos de este socorrista que coinciden en misma fecha:
      final turnosDelDia = turnosPorPiscina.where(
        (turno) => isSameDay(turno.start, dia),
      );

      // Si no hay ninguno, pasamos al siguiente socorrista:
      if (turnosDelDia.isEmpty) continue;

      // 2) Insertamos directamente en el mapa usando putIfAbsent:
      final lista = listaDeTurnosPorSocorrista.putIfAbsent(
        socorrista.nombre,
        () => [],
      );
      lista.addAll(turnosDelDia);
    }

    return listaDeTurnosPorSocorrista;
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _currentMonth = _focusedDay.month;
  }

  @override
  Widget build(BuildContext context) {
    final AuxMethods auxMethods = AuxMethods();
    final horariosHoy = _horariosParaDia(_selectedDay);
    final socorristasCtrl = Get.find<SocorristasController>();
    final List<Usuario> socorristas = socorristasCtrl.socorristas;
    final Set<DateTime> diasConTurno = {};
    final Map<String, List<Turno>> turnosPorSocorrista = mostrarTurnosDelDia(
      _selectedDay,
      widget.pool,
      socorristas,
    );

    for (var socorrista in socorristas) {
      for (var turno in socorrista.turnos) {
        // Solo agregamos si el turno es de esta piscina (p. ej., comparando pool.id)
        if (turno.pool.id == widget.pool.id) {
          final soloFecha = DateTime(
            turno.start.year,
            turno.start.month,
            turno.start.day,
          );
          diasConTurno.add(soloFecha);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendario ${widget.pool.nombre}',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SafeArea(
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

                  calendarBuilders: CalendarBuilders(
                    todayBuilder: (context, date, focusedDate) {
                      return Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors
                              .blue
                              .shade300, // azul pálido o el tono que prefieras
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: const TextStyle(
                            color:
                                Colors.white, // texto en blanco para contraste
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, date, focusedDate) {
                      final soloFecha = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );
                      // 1) Si la piscina NO abre, devolvemos null/disabled:
                      if (!_tieneHorarioEseDia(date)) return null;

                      // 2) Si está abierto y NO está en diasConTurno => lo pintamos de rojo pálido:
                      if (!diasConTurno.contains(soloFecha)) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100, // rojo pálido
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: Colors
                                  .red
                                  .shade800, // texto en rojo más oscuro
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      // 3) En caso contrario (abierto y con turno), devolvemos null:
                      return null;
                    },
                  ),

                  startingDayOfWeek: StartingDayOfWeek.monday,

                  enabledDayPredicate: (day) =>
                      _tieneHorarioEseDia(day) || auxMethods.isToday(day),

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
                    disabledTextStyle: TextStyle(color: Colors.black87),
                    disabledDecoration: BoxDecoration(
                      color: Colors.grey[350],
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
                    setState(() {
                      _focusedDay = focusedDay;
                      _currentMonth = _focusedDay.month;
                    });
                  },

                  // Configurar idioma (opcional, requerir intl y localización en MaterialApp)
                  locale: 'es_ES',
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 6),
                            const Text('Hoy'),
                          ],
                        ),

                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.deepOrange,
                            ),
                            const SizedBox(width: 6),
                            const Text('Seleccionado'),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.red.shade100,
                            ),
                            const SizedBox(width: 6),
                            const Text('Sin socorristas'),
                          ],
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: Colors.grey[350],
                            ),
                            const SizedBox(width: 6),
                            const Text('Cerrada'),
                          ],
                        ),
                      ],
                    ),
                  ],
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Horario de apertura - Día ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Para cada TimeRange, mostramos un Text
                      ...horariosHoy.map(
                        (tr) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            tr.toString(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Divider(),
                      SizedBox(height: 4),
                      Text(
                        'Socorristas asignados:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      turnosPorSocorrista.isEmpty
                          ? Text('No hay socorristas asignados')
                          : Flexible(
                              fit: FlexFit.loose,
                              child: ListView.builder(
                                itemCount: turnosPorSocorrista.length,
                                shrinkWrap: true,

                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (ctxt, index) {
                                  final entries = turnosPorSocorrista.entries
                                      .toList();
                                  final nombreSocorrista = entries[index].key;
                                  final listaDeTurnos = entries[index].value;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '\t🛟 ${auxMethods.capitalize(nombreSocorrista)}:',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            47,
                                            3,
                                            244,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: listaDeTurnos.length,
                                          itemBuilder: (ctx, i) => GestureDetector(
                                            onTap: () async {
                                              await Get.dialog(
                                                EditarOEliminarTurno(
                                                  turno: listaDeTurnos[i],
                                                  nombreSocorrista:
                                                      nombreSocorrista,
                                                  pool: widget.pool,
                                                ),
                                              );
                                              setState(() {
                                                return;
                                              });
                                            },
                                            child: Text(
                                              '\t\t${listaDeTurnos[i].stringSoloHoras()}',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                    ],
                                  );
                                },
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          mostrarSelectorHorarioSocorrista(
                            context,
                            widget.pool,
                            _selectedDay,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: Colors.lightBlue[300],
                            ),
                            SizedBox(width: 5),
                            Text('Añadir socorrista'),
                          ],
                        ),
                      ),
                    ],
                  ),
                Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '🌊🏊 Horas mes de ${auxMethods.nombreMes(_currentMonth)}: ${socorristasCtrl.totalHorasEnPiscinaMes(piscina: widget.pool, anyo: _focusedDay.year, mes: _currentMonth)}',
                  ),
                ),

                Divider(),

                // ---------------------------------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}
