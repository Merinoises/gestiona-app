import 'package:flutter/material.dart';
import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/views/anadir/add_pool_screen.dart';
import 'package:gestiona_app/widgets/main_page/card_seleccion.dart';
import 'package:gestiona_app/widgets/main_page/misc_card.dart';
import 'package:get/get.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, // Punto de inicio del degradado
            end: Alignment.bottomRight, // Punto final del degradado
            colors: [
              Color.fromARGB(255, 255, 255, 255), // Color inicial
              Color.fromARGB(255, 255, 188, 188), // Color final
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: Column(
              children: [
                CardSeleccion(
                  rutaALaImagenDeFondo:
                      '${Environment.apiUrl}/images/piscinas-card.png',
                  titulo: 'Piscinas',
                  alturaCard: MediaQuery.of(context).size.height * (1 / 6),
                  anchuraCard: MediaQuery.of(context).size.height * 0.8,
                  onPressed: () {
                    print('Ir a piscinas');
                  },
                ),
                // SizedBox(height: 20,),
                CardSeleccion(
                  rutaALaImagenDeFondo:
                      '${Environment.apiUrl}/images/socorristas-card.png',
                  titulo: 'Socorristas',
                  alturaCard: MediaQuery.of(context).size.height * (1 / 6),
                  anchuraCard: MediaQuery.of(context).size.height * 0.8,
                  onPressed: () {},
                ),

                Row(
                  children: [
                    MiscelaneaCard(
                      rutaALaImagenDeFondo:
                          '${Environment.apiUrl}/images/anadir-piscina.png',
                      titulo: 'Añadir piscina',
                      onPressed: () {
                        print('Añadir piscina');
                        Get.to(() => AddPoolScreen());
                      },
                    ),
                    SizedBox(width: 20),
                    MiscelaneaCard(
                      rutaALaImagenDeFondo:
                          '${Environment.apiUrl}/images/anadir-socorrista.png',
                      titulo: 'Añadir socorrista',
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
