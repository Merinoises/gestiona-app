import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();

  final password = ''.obs;
  final nombre = ''.obs;

  void establecerPassword(String passwordEstablecida) {
    password.value = passwordEstablecida;
  }

  void establecerNombre(String nombreEstablecido) {
    nombre.value = nombreEstablecido;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'La contraseña ha de ser como mínimo de 6 caracteres';
    }
    password.value = value;
    return null;
  }


  // Called when the user taps “Iniciar sesión”
  void accesoAppUsuario() {
    if (loginFormKey.currentState?.validate() ?? false) {
      loginFormKey.currentState!.save();
    }
  }

}
