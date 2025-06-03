import 'package:flutter/material.dart';
import 'package:gestiona_app/views/login/loading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GESTIONA App',
      home: LoadingScreen(),
      theme: ThemeData(
        fontFamily: 'Montserrat',
        brightness: Brightness.light,
      ),
    );
  }
}
