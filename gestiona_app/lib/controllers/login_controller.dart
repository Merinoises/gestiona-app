import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  final email = ''.obs;
  final password = ''.obs;
  final nombre = ''.obs;

  void establecerEmail(String emailIntroducido) {
    email.value = emailIntroducido;
  }

  void establecerPassword(String passwordEstablecida) {
    password.value = passwordEstablecida;
  }

  void establecerNombre(String nombreEstablecido) {
    nombre.value = nombreEstablecido;
  }

  String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Introduzca un email válido';
    }
    return null;
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
