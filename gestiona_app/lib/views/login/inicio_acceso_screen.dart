import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/login_controller.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/views/start/start_screen.dart';
import 'package:gestiona_app/widgets/login/boton_acceso_app.dart';
import 'package:gestiona_app/widgets/login/inicio_sesion_textfield.dart';

import 'package:get/get.dart';

class InicioAccesoScreen extends StatelessWidget {
  const InicioAccesoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginCtrl = Get.put(LoginController());
    final auth = Get.find<AuthService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, // Punto de inicio del degradado
            end: Alignment.bottomRight, // Punto final del degradado
            colors: [
              Color.fromARGB(255, 12, 19, 10), // Color inicial
              Color.fromARGB(255, 19, 46, 12), // Color final
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'GESTIONA S.L.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  //logo
                  // CachedNetworkImage(
                  //       imageUrl: '${Environment.apiUrl}/images/logo_app.png',
                  //       height: 150,
                  //       fit: BoxFit.contain,
                  //     ),
                  // CachedNetworkImage(
                  //       imageUrl: '${Environment.apiUrl}/images/logo_invictest.png',
                  //       width: MediaQuery.of(context).size.width*0.8,
                  //       fit: BoxFit.contain,
                  //     ),
                  const SizedBox(height: 20),
                  //Texto de bienvenida a un usuario ya registrado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0),
                    child: Text(
                      'Bienvenido a la aplicación móvil de GESTIONA',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Form(
                    key: loginCtrl.loginFormKey,
                    child: Column(
                      children: [
                        //username
                        InicioSesionTextfield(
                          // controller: emailController,
                          hintText: 'Email',
                          obscureText: false,
                          tipoTeclado: TextInputType.emailAddress,
                          validator: loginCtrl.validateEmail,
                          onSaved: (value) {
                            loginCtrl.establecerEmail(value!);
                          },
                        ),

                        const SizedBox(height: 10),

                        //password
                        InicioSesionTextfield(
                          // controller: passwordController,
                          hintText: 'Contraseña',
                          obscureText: true,
                          tipoTeclado: TextInputType.text,
                          validator: loginCtrl.validatePassword,
                          onSaved: (value) {
                            loginCtrl.establecerPassword(value!);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  //Olvidaste la contraseña
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            //TODO: Implementar OLVIDO DE LA CONTRASEÑA
                          },
                          child: Text(
                            '¿Olvidaste la contraseña?',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 207, 207, 207),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  //Boton para sign in
                  BotonAccesoApp(
                    contenidoBoton: auth.autenticando.value
                        ? CircularProgressIndicator()
                        : Text(
                            'Iniciar sesión',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                    onTap: auth.autenticando.value
                        ? null
                        : () async {
                            if (loginCtrl.loginFormKey.currentState!
                                .validate()) {
                              loginCtrl.loginFormKey.currentState!.save();
                              final res = await auth.login(
                                loginCtrl.email.value,
                                loginCtrl.password.value,
                              );
                              if (res == true) {
                                Get.off(() => StartScreen());
                              } else {
                                Get.snackbar(
                                  'Error',
                                  res.toString(),
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            }
                          },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
