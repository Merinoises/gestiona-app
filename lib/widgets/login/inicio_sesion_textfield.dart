import 'package:flutter/material.dart';

class InicioSesionTextfield extends StatelessWidget {
  // final controller;
  final String hintText;
  final bool obscureText;
  final TextInputType tipoTeclado;
  final bool autocorrect;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const InicioSesionTextfield({
    super.key,
    // required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.tipoTeclado,
    this.autocorrect = true,
    required this.validator,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
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
            borderSide: const BorderSide(color: Color.fromARGB(255, 255, 71, 71), width: 2.0),
          ),
        ),
        keyboardType: tipoTeclado,
        autocorrect: autocorrect,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
