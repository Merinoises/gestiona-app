import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/views/piscinas/admin_calendar_screen.dart';
import 'package:gestiona_app/widgets/admin/piscinas/editar_o_eliminar_piscina.dart';
import 'package:get/get.dart';

class AdminPiscinasScreen extends StatelessWidget {
  const AdminPiscinasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poolCtrl = Get.find<PoolController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GESTIONAR PISCINAS',
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
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: poolCtrl.pools.length,
              itemBuilder: (context, index) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: IconButton(
                      onPressed: () => Get.dialog(
                        EditarOEliminarPiscina(pool: poolCtrl.pools[index]),
                      ),
                      icon: FaIcon(FontAwesomeIcons.penToSquare),
                      color: Colors.teal,
                    ),
                    title: Text(
                      poolCtrl.pools[index].nombre,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(poolCtrl.pools[index].ubicacion),
                    trailing: IconButton(
                      onPressed: () => Get.to(
                        () =>
                            AdminCalendarioScreen(pool: poolCtrl.pools[index]),
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
      ),
    );
  }
}
