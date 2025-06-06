import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/views/login/inicio_acceso_screen.dart';
import 'package:gestiona_app/views/start/start_screen.dart';

import 'package:get/get.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return const Center(child: Text('Espere...'));
        },
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    final auth = Get.find<AuthService>();
    final autenticado = await auth.isLoggedIn();

    if (autenticado) {
      try {
        final poolCtrl = Get.find<PoolController>();
        await poolCtrl.loadPools();
        final socorristasCtrl = Get.find<SocorristasController>();
        await socorristasCtrl.loadSocorristas();
      } catch (e) {
        Get.to(() => InicioAccesoScreen());
        Get.snackbar('Error de carga', e.toString());
      }
      Get.to(() => StartScreen());
    } else {
      Get.to(() => InicioAccesoScreen());
    }
  }
}
