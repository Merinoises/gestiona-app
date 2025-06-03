import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/widgets/add_pool/days_selector.dart';
import 'package:get/get.dart';

class AddPoolController extends GetxController {
  var nombre = ''.obs;
  var ubicacion = ''.obs;
  var fechaApertura = DateTime(DateTime.now().year, 6, 1).obs;
  var horaInicio = Rx<TimeOfDay?>(null);
  var horaFinal = Rx<TimeOfDay?>(null);
  List<bool> selectedDays = List.filled(7, false);
  RxList<WeeklySchedule> listaHorarios = <WeeklySchedule>[].obs;
  var mensajeError = ''.obs;

  void mostrarSelectorHorario(BuildContext context) {
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
                  'CREAR HORARIO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Text(
                  'Seleccionar días de la semana',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                DaysSelector(selectedDays: selectedDays),
                SizedBox(height: 20),
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
                            onPressed: () => pickHoraInicio(context),
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
                            onPressed: () => pickHoraFinal(context),
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
                ElevatedButton(
                  onPressed: () {
                    final List<int> daysOfTheWeek = [];
                    for (int i = 0; i < selectedDays.length; i++) {
                      if (selectedDays[i]) {
                        daysOfTheWeek.add(i + 1);
                      }
                    }
                    if (daysOfTheWeek.isEmpty) {
                      mensajeError.value =
                          'Escoja al menos un día de la semana';
                      return;
                    }
                    if (horaInicio.value == null || horaFinal.value == null) {
                      mensajeError.value =
                          'Escoja la hora de inicio y finalización';
                      return;
                    }
                    // Convertimos la hora de inicio y fin a minutos para comparar con facilidad:
                    final int newStartMin =
                        horaInicio.value!.hour * 60 + horaInicio.value!.minute;
                    final int newEndMin =
                        horaFinal.value!.hour * 60 + horaFinal.value!.minute;
                    if (newStartMin > newEndMin) {
                      mensajeError.value =
                          'La hora de finalización ha de ser mayor que la de inicio';
                      return;
                    }

                    for (WeeklySchedule horario in listaHorarios) {
                      // 1) Comprobar si comparten al menos un día de la semana:
                      bool diasCoinciden = horario.weekdays.any(
                        (dia) => daysOfTheWeek.contains(dia),
                      );
                      if (!diasCoinciden) continue;

                      // 2) Si comparten día, comprobamos solapamiento de horas
                      final int existingStartMin =
                          horario.timeRange.start.hour * 60 +
                          horario.timeRange.start.minute;
                      final int existingEndMin =
                          horario.timeRange.end.hour * 60 +
                          horario.timeRange.end.minute;

                      // Dos intervalos [A_inicio, A_fin) y [B_inicio, B_fin) se solapan
                      // si y solo si: A_inicio < B_fin  &&  B_inicio < A_fin
                      if (newStartMin < existingEndMin &&
                          existingStartMin < newEndMin) {
                        mensajeError.value =
                            'El horario que quieres establecer se solapa con otro horario existente';
                        return;
                      }
                    }

                    WeeklySchedule nuevoHorario = WeeklySchedule(
                      weekdays: daysOfTheWeek,
                      timeRange: TimeRange(
                        start: horaInicio.value!,
                        end: horaFinal.value!,
                      ),
                    );

                    listaHorarios.add(nuevoHorario);
                    selectedDays = List.filled(7, false);
                    horaInicio.value = null;
                    horaFinal.value = null;
                    mensajeError.value = '';
                    Get.back();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue[400]),
                  ),
                  child: Text(
                    'Guardar horario',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Obx(() {
                  return mensajeError.value != ''
                      ? Text(
                          mensajeError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickFechaApertura(BuildContext context) async {
    final int currentYear = DateTime.now().year;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(currentYear, 6),
      firstDate: DateTime(currentYear),
      lastDate: DateTime(currentYear, 12, 31),
      locale: const Locale('es', ''), // Para que el picker salga en español
    );
    if (picked != null) {
      fechaApertura.value = picked;
    }
  }

  Future<void> pickHoraInicio(BuildContext ctx) async {
    final TimeOfDay inicial = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: horaInicio.value ?? inicial,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', ''),
          child: child,
        );
      },
    );

    if (picked != null) {
      horaInicio.value = picked;
    }
  }

  Future<void> pickHoraFinal(BuildContext ctx) async {
    final TimeOfDay inicial = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: horaFinal.value ?? inicial,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', ''),
          child: child,
        );
      },
    );

    if (picked != null) {
      horaFinal.value = picked;
    }
  }

  void eliminarHorario(int idx) {
    listaHorarios.removeAt(idx);
  }

  Future<void> guardarPiscina() async {
    if (listaHorarios.isEmpty) {
      Get.snackbar(
        'Establezca algún horario',
        'Debe establecer al menos un horario.',
      );
      return;
    }

    final Pool nuevaPiscina = Pool(
      nombre: nombre.value,
      ubicacion: ubicacion.value,
      fechaApertura: fechaApertura.value,
      weeklySchedules: listaHorarios,
    );

    final poolCtrl = Get.find<PoolController>();
    final String? res = await poolCtrl.createPool(nuevaPiscina);

    if (res != null) {
      Get.snackbar('Error', res);
    } else {
      Get.back();
      Get.snackbar('Piscina creada', 'Se creó la piscina ${nuevaPiscina.nombre}');
    }
  }

  void resetAll() {
    nombre.value = '';
    ubicacion.value = '';
    fechaApertura.value = DateTime(DateTime.now().year, 6, 1);
    horaInicio.value = null;
    horaFinal.value = null;
    // Vuelve a una lista de 7 falsos
    selectedDays.assignAll(List<bool>.filled(7, false));
    listaHorarios.clear();
    mensajeError.value = '';
  }
}
