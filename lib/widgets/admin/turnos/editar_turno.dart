// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class EditarTurno extends StatelessWidget {
//   const EditarTurno({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors
//           .transparent, // opcional: para que el degradado sea visible en los bordes
//       contentPadding: EdgeInsets
//           .zero, // para que el contenido ocupe todo el espacio disponible dentro del AlertDialog
//       content: Container(
//         decoration: const BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(8)),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft, // Punto de inicio del degradado
//             end: Alignment.bottomRight, // Punto final del degradado
//             colors: [
//               Color.fromARGB(255, 255, 255, 255), // Color inicial
//               Color.fromARGB(255, 191, 237, 255), // Color final
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'CREAR HORARIO DE SOCORRISTA',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 30),
//               Text(
//                 'Selección de socorrista',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Form(
//                 key: _formKey,
//                 child: DropdownButtonFormField<Usuario>(
//                   decoration: InputDecoration(
//                     labelText: 'Socorrista',
//                     border: const OutlineInputBorder(),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                   items: listaSocorristas.map((Usuario s) {
//                     return DropdownMenuItem<Usuario>(
//                       value: s,
//                       child: Text(s.nombre),
//                     );
//                   }).toList(),
//                   value: socorristaSeleccionado.value,
//                   hint: const Text('Selecciona un socorrista'),
//                   onChanged: (socorrista) {
//                     socorristaSeleccionado.value = socorrista;
//                   },
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Debes elegir un socorrista';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'Horas de inicio y finalización',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),

//               SizedBox(height: 10),
//               Obx(
//                 () => Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Column(
//                       children: [
//                         ElevatedButton(
//                           onPressed: () async {
//                             horaInicio.value = await pickHoraInicio(context);
//                           },
//                           child: Text('Hora inicial'),
//                         ),
//                         horaInicio.value != null
//                             ? SizedBox(height: 10)
//                             : SizedBox.shrink(),
//                         horaInicio.value != null
//                             ? Text(
//                                 horaInicio.value!.format(context),
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               )
//                             : SizedBox.shrink(),
//                       ],
//                     ),

//                     SizedBox(width: 10),
//                     Column(
//                       children: [
//                         ElevatedButton(
//                           onPressed: () async {
//                             horaFinal.value = await pickHoraFinalizacion(
//                               context,
//                             );
//                           },
//                           child: Text('Hora final'),
//                         ),
//                         horaFinal.value != null
//                             ? SizedBox(height: 10)
//                             : SizedBox.shrink(),
//                         horaFinal.value != null
//                             ? Text(
//                                 horaFinal.value!.format(context),
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               )
//                             : SizedBox.shrink(),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (!_formKey.currentState!.validate()) {
//                     // Si el dropdown no está seleccionado, no continua
//                     return;
//                   }
//                   if (horaInicio.value == null || horaFinal.value == null) {
//                     mensajeError.value =
//                         'Escoja la hora de inicio y finalización';
//                     print(mensajeError);
//                     return;
//                   }
//                   // Convertimos la hora de inicio y fin a minutos para comparar con facilidad:
//                   final int newStartMin =
//                       horaInicio.value!.hour * 60 + horaInicio.value!.minute;
//                   final int newEndMin =
//                       horaFinal.value!.hour * 60 + horaFinal.value!.minute;
//                   if (newStartMin > newEndMin) {
//                     mensajeError.value =
//                         'La hora de finalización ha de ser posterior a la de inicio';
//                     print(mensajeError);
//                     return;
//                   }

//                   final fechaYHoraInicio = DateTime(
//                     fechaDia.year,
//                     fechaDia.month,
//                     fechaDia.day,
//                     horaInicio.value!.hour,
//                     horaInicio.value!.minute,
//                   );
//                   final fechaYHoraFinal = DateTime(
//                     fechaDia.year,
//                     fechaDia.month,
//                     fechaDia.day,
//                     horaFinal.value!.hour,
//                     horaFinal.value!.minute,
//                   );
//                   Turno nuevoTurno = Turno(
//                     id: '',
//                     pool: pool,
//                     start: fechaYHoraInicio,
//                     end: fechaYHoraFinal,
//                   );
//                   print(nuevoTurno);
//                   socorristasCtrl.loading.value = true;
//                   final String? resp = await socorristasCtrl
//                       .asignarHorarioEnPiscina(
//                         nuevoTurno,
//                         socorristaSeleccionado.value!,
//                       );
//                   if (resp == null) {
//                     Get.back();
//                     socorristasCtrl.loading.value = false;
//                     final index = listaSocorristas.indexWhere(
//                       (u) => u.id == socorristaSeleccionado.value!.id,
//                     );
//                     final Usuario socorristaModificado =
//                         listaSocorristas[index];
//                     setState(() {
//                       return;
//                     });
//                     Get.snackbar(
//                       'Turno agregado a ${socorristaModificado.nombre}',
//                       'Añadido el turno $nuevoTurno',
//                       duration: Duration(seconds: 3),
//                       backgroundColor: Colors.white,
//                     );
//                   } else {
//                     Get.back();
//                     socorristasCtrl.loading.value = false;
//                     Get.snackbar('Error', resp);
//                   }

//                   // listaHorarios.add(nuevoHorario);
//                   // selectedDays = List.filled(7, false);
//                   // horaInicio.value = null;
//                   // horaFinal.value = null;
//                   // mensajeError.value = '';
//                   // Get.back();
//                 },
//                 style: ButtonStyle(
//                   backgroundColor: WidgetStatePropertyAll(Colors.blue[400]),
//                 ),
//                 child: Obx(() {
//                   return socorristasCtrl.loading.value
//                       ? Center(child: CircularProgressIndicator())
//                       : Text(
//                           'Guardar horario',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                 }),
//               ),
//               SizedBox(height: 8),
//               Obx(
//                 () => mensajeError.value != ''
//                     ? Text(
//                         mensajeError.value,
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     : SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
