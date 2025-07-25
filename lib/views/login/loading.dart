import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/services/version_service.dart';
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo-app.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Cargando...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    final versionService = Get.find<VersionService>();
    final bool shouldStop = await versionService.checkAndUpdateIfAndroid();

    if (shouldStop) {
      SystemNavigator.pop();
    }

    final auth = Get.find<AuthService>();
    final autenticado = await auth.isLoggedIn();

    if (autenticado) {
      try {
        final poolCtrl = Get.find<PoolController>();
        await poolCtrl.loadPools();
        final socorristasCtrl = Get.find<SocorristasController>();
        await socorristasCtrl.loadSocorristas();
      } catch (e) {
        Get.offAll(() => InicioAccesoScreen());
        Get.snackbar('Error de carga', e.toString());
      }
      Get.offAll(() => StartScreen());
    } else {
      Get.offAll(() => InicioAccesoScreen());
    }
  }
}
