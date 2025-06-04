import 'package:flutter/material.dart';
import 'package:gestiona_app/models/usuario.dart';

class AddSocorristaScreen extends StatelessWidget {
  AddSocorristaScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String nombre = '';
    String password = '';

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
                        'Añadir socorrista',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      SocorristaTextForm(
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Debes seleccionar un nombre';
                          }
                          final texto = val.trim();
                          // Regex: ^[a-z]+$ -> solo letras minúsculas, al menos una.
                          final soloMinusculas = RegExp(r'^[a-z]+$');
                          if (!soloMinusculas.hasMatch(texto)) {
                            return 'Solo letras minúsculas, sin espacios ni números';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          nombre = value!;
                        },
                        hintText: 'Nombre del socorrista',
                      ),
                      SizedBox(height: 8),
                      SocorristaTextForm(
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Debes establecer una contraseña';
                          }
                          if (val.trim().length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!.trim();
                        },
                        hintText: 'Contraseña',
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final Usuario usuario = Usuario(nombre: nombre, password: password, isAdmin: false);
                      print(usuario);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      const Color.fromARGB(255, 255, 184, 255),
                    ),
                  ),
                  child: Text(
                    'Guardar socorrista',
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

class SocorristaTextForm extends StatelessWidget {
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const SocorristaTextForm({
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
