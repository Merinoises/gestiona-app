import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/turno.dart';
import 'package:gestiona_app/models/usuario.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:get/get.dart';

class EditarTurno extends StatelessWidget {
  final Turno turno;
  final String nombreSocorrista;
  final Pool pool;

  const EditarTurno({
    super.key,
    required this.turno,
    required this.nombreSocorrista,
    required this.pool,
  });

  @override
  Widget build(BuildContext context) {
    final AuxMethods auxMethods = AuxMethods();
    final formKey = GlobalKey<FormState>();

    final SocorristasController socorristasCtrl =
        Get.find<SocorristasController>();

    Rx<TimeOfDay?> rxHoraInicio = socorristasCtrl.horaInicioTurno;
    Rx<TimeOfDay?> rxHoraFinal = socorristasCtrl.horaFinalTurno;
    Rx<String> rxMensajeError = socorristasCtrl.mensajeError;
    Rx<Usuario?> socorristaSeleccionado =
        socorristasCtrl.socorristaSeleccionado;

    TimeOfDay horaInicio = TimeOfDay(
      hour: turno.start.hour,
      minute: turno.start.minute,
    );
    TimeOfDay horaFinal = TimeOfDay(
      hour: turno.end.hour,
      minute: turno.end.minute,
    );

    rxHoraInicio.value = horaInicio;
    rxHoraFinal.value = horaFinal;
    rxMensajeError.value = '';
    socorristaSeleccionado.value = socorristasCtrl.getSocorristaByNombre(
      nombreSocorrista,
    );

    List<Usuario> listaSocorristas = socorristasCtrl.socorristas;

    return AlertDialog(
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
                'EDITAR HORARIO DE SOCORRISTA',
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
                            rxHoraInicio.value = await auxMethods
                                .pickHoraInicio(context);
                          },
                          child: Text('Hora inicial'),
                        ),
                        rxHoraInicio.value != null
                            ? SizedBox(height: 10)
                            : SizedBox.shrink(),
                        rxHoraInicio.value != null
                            ? Text(
                                rxHoraInicio.value!.format(context),
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
                            rxHoraFinal.value = await auxMethods
                                .pickHoraFinalizacion(context);
                          },
                          child: Text('Hora final'),
                        ),
                        rxHoraFinal.value != null
                            ? SizedBox(height: 10)
                            : SizedBox.shrink(),
                        rxHoraFinal.value != null
                            ? Text(
                                rxHoraFinal.value!.format(context),
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
                          if (rxHoraInicio.value == null ||
                              rxHoraFinal.value == null) {
                            rxMensajeError.value =
                                'Escoja la hora de inicio y finalización';
                            return;
                          }
                          // Convertimos la hora de inicio y fin a minutos para comparar con facilidad:
                          final int newStartMin =
                              rxHoraInicio.value!.hour * 60 +
                              rxHoraInicio.value!.minute;
                          final int newEndMin =
                              rxHoraFinal.value!.hour * 60 +
                              rxHoraFinal.value!.minute;
                          if (newStartMin > newEndMin) {
                            rxMensajeError.value =
                                'La hora de finalización ha de ser posterior a la de inicio';
                            return;
                          }

                          final fechaYHoraInicio = DateTime(
                            turno.start.year,
                            turno.start.month,
                            turno.start.day,
                            rxHoraInicio.value!.hour,
                            rxHoraInicio.value!.minute,
                          );
                          final fechaYHoraFinal = DateTime(
                            turno.start.year,
                            turno.start.month,
                            turno.start.day,
                            rxHoraFinal.value!.hour,
                            rxHoraFinal.value!.minute,
                          );
                          Turno turnoEditado = Turno(
                            id: '',
                            pool: pool,
                            start: fechaYHoraInicio,
                            end: fechaYHoraFinal,
                          );
                          socorristasCtrl.loading.value = true;
                          //En caso de no cambiar el socorrista, se actualiza simplemente su turno:
                          if (nombreSocorrista ==
                              socorristasCtrl
                                  .socorristaSeleccionado
                                  .value!
                                  .nombre) {
                            final String? resp = await socorristasCtrl
                                .actualizarTurnoDeSocorrista(
                                  socorristaSeleccionado.value!.id!,
                                  turno.id,
                                  turnoEditado,
                                );
                            socorristasCtrl.loading.value = false;
                            Get.back();
                            Get.back();
                            if (resp == null) {
                              Get.snackbar(
                                'Turno editado',
                                'Editado turno de $nombreSocorrista - ${turnoEditado.fechaYHoraDetallada()}',
                                backgroundColor: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                resp,
                                colorText: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  193,
                                  244,
                                  67,
                                  54,
                                ),
                              );
                            }
                          }
                          //En caso de que cambie de socorrista, hay que eliminar el turno del socorrista inicial y agregar un nuevo turno al otro socorrista
                          else {
                            final String? respEliminar = await socorristasCtrl
                                .eliminarTurnoDeSocorrista(
                                  socorristasCtrl.getIdByNombre(
                                    nombreSocorrista,
                                  )!,
                                  turno.id,
                                );
                            final String? respAnyadir = await socorristasCtrl
                                .asignarHorarioEnPiscina(
                                  turnoEditado,
                                  socorristaSeleccionado.value!,
                                );
                            Get.back();
                            Get.back();
                            socorristasCtrl.loading.value = false;
                            if (respEliminar == null && respAnyadir == null) {
                              Get.snackbar(
                                'Turno editado',
                                'añadido turno a ${socorristaSeleccionado.value!.nombre} - ${turnoEditado.fechaYHoraDetallada()}',
                                backgroundColor: Colors.white,
                              );
                            } else if (respEliminar != null) {
                              Get.snackbar(
                                'Error',
                                respEliminar,
                                colorText: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  193,
                                  244,
                                  67,
                                  54,
                                ),
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                respAnyadir!,
                                colorText: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  193,
                                  244,
                                  67,
                                  54,
                                ),
                              );
                            }
                          }
                        },
                  style: ButtonStyle(
                    backgroundColor: socorristasCtrl.loading.value
                        ? null
                        : WidgetStatePropertyAll(Colors.blue[400]),
                  ),
                  child: socorristasCtrl.loading.value
                      ? Center(child: CircularProgressIndicator())
                      : Text(
                          'Guardar horario editado',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 8),
              Obx(
                () => rxMensajeError.value != ''
                    ? Text(
                        rxMensajeError.value,
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
    );
  }
}
