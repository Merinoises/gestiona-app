import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/usuario.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:gestiona_app/views/piscinas/soco_calendar_screen.dart';
import 'package:get/get.dart';

class SocoPiscinasScreen extends StatelessWidget {
  const SocoPiscinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final AuxMethods auxMeths = AuxMethods();

    final Usuario usuario = authService.usuario.value!;

    final List<Pool> piscinasConTurnos = usuario.turnos
        .map((turno) => turno.pool)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TUS PISCINAS',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
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
            itemCount: piscinasConTurnos.length,
            itemBuilder: (context, index) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    auxMeths.capitalize(piscinasConTurnos[index].nombre),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(piscinasConTurnos[index].ubicacion),
                  trailing: IconButton(
                    onPressed: () => Get.to(
                      () =>
                          SocoCalendarioScreen(pool: piscinasConTurnos[index]),
                    ),
                    icon: FaIcon(FontAwesomeIcons.eye),
                    color: Colors.pinkAccent,
                  ),
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
