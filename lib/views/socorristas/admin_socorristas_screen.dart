import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:get/get.dart';

class AdminSocorristasScreen extends StatelessWidget {
  const AdminSocorristasScreen({super.key});

  
  

  @override
  Widget build(BuildContext context) {
    final AuxMethods auxMethods = AuxMethods();

    final socorristasCtrl = Get.find<SocorristasController>();

    return Scaffold(
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            itemCount: socorristasCtrl.socorristas.length,
            itemBuilder: (context, index) {
              final socorrista = socorristasCtrl.socorristas[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: InitialsCircle(
                      text: socorrista.nombre,
                    ),
                    title: Text(
                      auxMethods.capitalize(socorrista.nombre),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: FaIcon(FontAwesomeIcons.eye),
                    ),
                    tileColor: const Color.fromARGB(255, 255, 206, 221),
                    iconColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color.fromARGB(104, 0, 0, 0),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Un widget que pinta un círculo de un color “aleatorio determinista”
/// (extraído de una lista de ~40 colores) y coloca en su interior las
/// dos primeras letras en mayúscula de la cadena [text].
class InitialsCircle extends StatelessWidget {
  /// El texto del que tomaremos las dos primeras letras.
  final String text;

  /// El diámetro del círculo. Por defecto 48.0 puntos.
  final double size;

  const InitialsCircle({Key? key, required this.text, this.size = 48.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1) Obtener las dos primeras letras en mayúscula.
    String initials;
    if (text.trim().isEmpty) {
      initials = '';
    } else if (text.trim().length == 1) {
      initials = text.trim()[0].toUpperCase();
    } else {
      // Si tiene al menos 2 caracteres, tomamos substring(0, 2)
      initials = text.trim()[0].toUpperCase() + text.trim()[1].toLowerCase();
    }

    // 2) Elegir el color del array de forma “determinista” a partir del hash
    //    Esto hace que un mismo texto siempre produzca el mismo color.
    final Color backgroundColor = const Color.fromARGB(166, 155, 39, 176);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize:
                size *
                0.3, // ajusta el tamaño de la letra en proporción al círculo
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
