import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/models/turno.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:gestiona_app/widgets/admin/turnos/eliminar_turno.dart';
import 'package:get/get.dart';

class EditarOEliminarTurno extends StatelessWidget {
  final Turno turno;
  final String nombreSocorrista;

  const EditarOEliminarTurno({
    super.key,
    required this.turno,
    required this.nombreSocorrista,
  });

  @override
  Widget build(BuildContext context) {
    final AuxMethods auxMethods = AuxMethods();

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
                'Gestionar turno',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Turno perteneciente a: ${auxMethods.capitalize(nombreSocorrista)}'),
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
                    onPressed: () async {
                      await Get.dialog(EliminarTurno(turno: turno, nombreSocorrista: nombreSocorrista));
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(const Color.fromARGB(176, 244, 67, 54)),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.circleXmark,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        Text(
                          ' Eliminar',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    child: Row(
                      children: [
                        FaIcon(FontAwesomeIcons.penToSquare, color: Colors.black,),
                        Text(' Editar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
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
