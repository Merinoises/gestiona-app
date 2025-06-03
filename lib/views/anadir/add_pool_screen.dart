import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/add_pool_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddPoolScreen extends StatelessWidget {
  AddPoolScreen({super.key});

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final addPoolCtrl = Get.find<AddPoolController>();

    return Scaffold(
      body: SafeArea(
        child: Container(
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
            padding: EdgeInsetsGeometry.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Añadir piscina',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      PoolTextForm(
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Debes seleccionar un nombre';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          addPoolCtrl.nombre.value = value!;
                        },
                        hintText: 'Nombre de la piscina',
                      ),
                      SizedBox(height: 8),
                      PoolTextForm(
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Debes seleccionar una ubicación';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          addPoolCtrl.ubicacion.value = value!;
                        },
                        hintText: 'Ubicación',
                      ),
                      SizedBox(height: 20),

                      Obx(
                        () => TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Fecha de apertura',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          // Si ya hay fecha seleccionada, la mostramos formateada; si no, placeholder
                          controller: TextEditingController(
                            text: _dateFormat.format(
                              addPoolCtrl.fechaApertura.value,
                            ),
                          ),
                          onTap: () => addPoolCtrl.pickFechaApertura(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Obx(() {
                  if (addPoolCtrl.listaHorarios.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // Puedes usar ListView.builder para listas grandes:
                  return ListView.builder(
                    itemCount: addPoolCtrl.listaHorarios.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final texto = addPoolCtrl.listaHorarios[index].toString();
                      return ListTile(
                        title: Text(texto),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            addPoolCtrl.eliminarHorario(index);
                          },
                        ),
                      );
                    },
                  );
                }),
                GestureDetector(
                  onTap: () => addPoolCtrl.mostrarSelectorHorario(context),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.lightBlue[300]),
                      SizedBox(width: 5),
                      Text('Añadir horario'),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await addPoolCtrl.guardarPiscina();
                      addPoolCtrl.resetAll();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(255, 255, 184, 255),
                    ),
                  ),
                  child: Text(
                    'Guardar piscina',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PoolTextForm extends StatelessWidget {
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const PoolTextForm({
    super.key,
    required this.validator,
    required this.onSaved,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: const Color.fromARGB(255, 255, 0, 0),
      decoration: InputDecoration(
        labelText: hintText,
        floatingLabelStyle: TextStyle(color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
        focusedBorder: OutlineInputBorder(
          // Borde cuando SÍ está enfocado
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 71, 71),
            width: 2.0,
          ),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
