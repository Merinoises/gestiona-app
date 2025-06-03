import 'package:flutter/material.dart';

class BotonAccesoApp extends StatelessWidget {
  final void Function()? onTap;
  final Widget contenidoBoton;

  const BotonAccesoApp({
    super.key,
    required this.contenidoBoton,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 157, 157),
          border: Border.all(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5), // color semitransparente
              spreadRadius: 2, // cuánto se expande la sombra
              blurRadius: 6, // difuminado de la sombra
              offset: const Offset(2, 2), // desplazamiento (x, y)
            ),
            BoxShadow(
              color: const Color.fromARGB(255, 255, 59, 255).withValues(alpha: 0.5), // color semitransparente
              spreadRadius: 1, // cuánto se expande la sombra
              blurRadius: 10, // difuminado de la sombra
              offset: const Offset(-2, -2), // desplazamiento (x, y)
            ),
          ],
        ),
        child: Center(child: contenidoBoton),
      ),
    );
  }
}
