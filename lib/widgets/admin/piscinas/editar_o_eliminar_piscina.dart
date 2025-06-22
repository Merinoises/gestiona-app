import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/add_pool_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/widgets/admin/piscinas/editar_piscina.dart';
import 'package:gestiona_app/widgets/admin/piscinas/eliminar_piscina.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditarOEliminarPiscina extends StatelessWidget {
  final Pool pool;

  const EditarOEliminarPiscina({super.key, required this.pool});

  @override
Widget build(BuildContext context) {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  // Calculamos un máximo razonable para la altura de la sección de horarios:
  final maxHeight = MediaQuery.of(context).size.height * 0.5;

  return AlertDialog(
    backgroundColor: Colors.transparent,
    contentPadding: EdgeInsets.zero,
    content: Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 255, 255, 255),
            Color.fromARGB(255, 191, 237, 255),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gestionar piscina',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Divider(),
            // Contenedor que limitará la altura de la sección de datos + horarios:
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Nombre: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(pool.nombre)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Ubicación: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(pool.ubicacion)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('Fecha de apertura: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(dateFormat.format(pool.fechaApertura!))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Horarios semanales: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    // Si la lista semanal es muy larga, también puede ponerse en un ListView con shrinkWrap, pero si no es excesiva:
                    ...pool.weeklySchedules.map((weekSch) => Text(weekSch.toString())),
                    const SizedBox(height: 12),
                    Text('Horarios especiales: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (pool.specialSchedules.isNotEmpty)
                      ...pool.specialSchedules.map(
                        (weekSch) => Text(weekSch.toString()),
                      )
                    else
                      Text('No hay horarios especiales'),
                  ],
                ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Get.dialog(EliminarPiscina(pool: pool));
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(176, 244, 67, 54),
                    ),
                  ),
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.circleXmark, color: Colors.white),
                      Text(' Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    final addPoolCtrl = Get.find<AddPoolController>();
                    addPoolCtrl.nombre.value = pool.nombre;
                    addPoolCtrl.ubicacion.value = pool.ubicacion;
                    addPoolCtrl.fechaApertura.value = pool.fechaApertura!;
                    addPoolCtrl.listaHorarios.value = pool.weeklySchedules;
                    addPoolCtrl.listaHorariosEspeciales.value = pool.specialSchedules;
                    Get.back();
                    Get.to(() => EditarPiscina(pool: pool));
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.penToSquare, color: Colors.black),
                      Text(' Editar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
