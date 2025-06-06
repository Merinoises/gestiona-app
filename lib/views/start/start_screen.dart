import 'package:flutter/material.dart';
import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/models/usuario.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/views/anadir/add_pool_screen.dart';
import 'package:gestiona_app/views/anadir/add_socorrista_screen.dart';
import 'package:gestiona_app/views/login/loading.dart';
import 'package:gestiona_app/views/piscinas/admin_piscinas_screen.dart';
import 'package:gestiona_app/views/socorristas/admin_socorristas_screen.dart';
import 'package:gestiona_app/views/socorristas/info_socorrista_screen.dart';
import 'package:gestiona_app/widgets/main_page/card_seleccion.dart';
import 'package:gestiona_app/widgets/main_page/misc_card.dart';
import 'package:get/get.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final Usuario usuario = authService.usuario.value!;
    final bool isAdmin = usuario.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GESTIONA S.L. - Socorrismo',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              await authService.logout();
              Get.to(() => LoadingScreen());
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Usuario: ${authService.usuario.value!.nombre}'),
                    SizedBox(width: 2),
                    isAdmin ? Text('(admin)') : SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: 8),
                CardSeleccion(
                  rutaALaImagenDeFondo:
                      '${Environment.apiUrl}/images/piscinas-card.png',
                  titulo: isAdmin ? 'Gestionar piscinas' : 'Mis piscinas',
                  subtitulo: isAdmin
                      ? null
                      : 'Accede para ver tus turnos de trabajo',
                  alturaCard: MediaQuery.of(context).size.height * (1 / 6),
                  anchuraCard: MediaQuery.of(context).size.height * 0.8,
                  onPressed: () {
                    Get.to(() => AdminPiscinasScreen());
                  },
                ),
                // SizedBox(height: 20,),
                CardSeleccion(
                  rutaALaImagenDeFondo:
                      '${Environment.apiUrl}/images/socorristas-card.png',
                  titulo: isAdmin ? 'Gestionar socorristas' : 'Mis datos',
                  subtitulo: isAdmin
                      ? null
                      : 'Horarios, turnos, horas trabajadas',
                  alturaCard: MediaQuery.of(context).size.height * (1 / 6),
                  anchuraCard: MediaQuery.of(context).size.height * 0.8,
                  onPressed: () {
                    if (isAdmin) {
                      Get.to(() => AdminSocorristasScreen());
                    } else {
                      Get.to(() => InfoSocorristaScreen(socorrista: usuario));
                    }
                  },
                ),
                isAdmin
                    ? Row(
                        children: [
                          MiscelaneaCard(
                            rutaALaImagenDeFondo:
                                '${Environment.apiUrl}/images/anadir-piscina.png',
                            titulo: 'Añadir piscina',
                            onPressed: () {
                              Get.to(() => AddPoolScreen());
                            },
                          ),
                          SizedBox(width: 20),
                          MiscelaneaCard(
                            rutaALaImagenDeFondo:
                                '${Environment.apiUrl}/images/anadir-socorrista.png',
                            titulo: 'Añadir socorrista',
                            onPressed: () {
                              Get.to(() => AddSocorristaScreen());
                            },
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
