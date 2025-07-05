import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestiona_app/controllers/add_pool_controller.dart';
import 'package:gestiona_app/controllers/pool_controller.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/firebase_options.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/services/fcm-service.dart';
import 'package:gestiona_app/services/version_service.dart';
import 'package:gestiona_app/views/login/loading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Inicio de Firebase y Firebase Messaging
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  Get.put(FcmService());
  Get.put(AuthService());
  Get.put(PoolController());
  Get.put(AddPoolController());
  Get.put(SocorristasController());
  Get.put(VersionService(), permanent: true);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GESTIONA App',
      home: LoadingScreen(),
      theme: ThemeData(fontFamily: 'Montserrat', brightness: Brightness.light),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 2) Idiomas soportados (al menos el español y el inglés)
      supportedLocales: const [
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español
      ],

      // Opcional: configura la locale por defecto
      locale: const Locale('es', ''),
    );
  }
}
