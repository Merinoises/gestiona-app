import 'package:flutter/material.dart';

class BotonAccesoApp extends StatelessWidget {
  final void Function()? onTap;
  final Widget contenidoBoton;

  const BotonAccesoApp({super.key, required this.contenidoBoton, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 248, 193, 27), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: contenidoBoton,
        ),
      ),
    );
  }
}