import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EliminarPiscina extends StatelessWidget {
  final Pool pool;
  const EliminarPiscina({super.key, required this.pool});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/mm/yyyy');
    final PoolController poolCtrl = Get.find<PoolController>();

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
              Color.fromARGB(255, 255, 191, 191), // Color final
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
                '¿Quiere eliminar esta piscina?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color.fromARGB(199, 244, 67, 54),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nombre: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(pool.nombre)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Ubicación: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(pool.ubicacion)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Fecha de apertura: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(dateFormat.format(pool.fechaApertura!)),
                        ),
                      ],
                    ),
                    Text(
                      'Horarios semanales: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...pool.weeklySchedules.map(
                      (weekSch) => Text(weekSch.toString()),
                    ),
                    Text(
                      'Horarios especiales: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (pool.specialSchedules.isNotEmpty)
                      ...pool.specialSchedules.map(
                        (weekSch) => Text(weekSch.toString()),
                      )
                    else
                      Text('No hay horarios especiales'),
                  ],
                ),
              ),

              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    child: Text(
                      ' Volver',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Obx(
                    () => ElevatedButton(
                      onPressed: poolCtrl.loading.value
                          ? null
                          : () async {
                              String? resp = await poolCtrl.deletePool(
                                pool.id!,
                              );
                              Get.back();
                              Get.back();
                              if (resp == null) {
                                Get.snackbar(
                                  'Piscina eliminada',
                                  'Eliminada piscina ${pool.nombre}',
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
                            },
                      style: ButtonStyle(
                        backgroundColor: poolCtrl.loading.value
                            ? null
                            : WidgetStatePropertyAll(
                                const Color.fromARGB(176, 244, 67, 54),
                              ),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.circleXmark,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          poolCtrl.loading.value
                              ? CircularProgressIndicator()
                              : Text(
                                  ' Eliminar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
