import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/models/turno.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:get/get.dart';

class EliminarTurno extends StatelessWidget {
  final Turno turno;
  final String nombreSocorrista;
  const EliminarTurno({
    super.key,
    required this.turno,
    required this.nombreSocorrista,
  });

  @override
  Widget build(BuildContext context) {
    final AuxMethods auxMethods = AuxMethods();
    final SocorristasController socorristasCtrl =
        Get.find<SocorristasController>();

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
                '¿Quiere eliminar este turno?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turno perteneciente a: ${auxMethods.capitalize(nombreSocorrista)}',
                    ),
                    Text('Piscina: ${turno.pool.nombre}'),
                    Text('Fecha y hora: ${turno.fechaYHoraDetallada()}'),
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
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.penToSquare,
                          color: Colors.black,
                        ),
                        Text(
                          ' Volver',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final idSocorrista = socorristasCtrl.getIdByNombre(
                        nombreSocorrista,
                      );
                      if (idSocorrista == null) {
                        Get.back();
                        Get.back();
                        Get.snackbar(
                          'Error',
                          'Socorrista no encontrado',
                          colorText: Colors.white,
                          backgroundColor: const Color.fromARGB(
                            200,
                            244,
                            67,
                            54,
                          ),
                        );
                      }
                      String? resp = await socorristasCtrl
                          .eliminarTurnoDeSocorrista(idSocorrista!, turno.id);
                      Get.back();
                      Get.back();
                      if (resp == null) {
                        Get.snackbar(
                          'Turno eliminado',
                          'Eliminado turno de $nombreSocorrista - ${turno.fechaYHoraDetallada()}',
                          backgroundColor: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Socorrista no encontrado',
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
                      backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(176, 244, 67, 54),
                      ),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleXmark,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        Text(
                          ' Eliminar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
