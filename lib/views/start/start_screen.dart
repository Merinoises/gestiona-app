import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/global/environment.dart';
import 'package:gestiona_app/models/usuario.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/views/anadir/add_pool_screen.dart';
import 'package:gestiona_app/views/anadir/add_socorrista_screen.dart';
import 'package:gestiona_app/views/login/loading.dart';
import 'package:gestiona_app/views/piscinas/admin_piscinas_screen.dart';
import 'package:gestiona_app/views/piscinas/soco_piscinas_screen.dart';
import 'package:gestiona_app/views/resumen_por_fecha/resumen_por_fecha_screen.dart';
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
    final SocorristasController socorristasController =
        Get.find<SocorristasController>();
    final Usuario usuario = authService.usuario.value!;

    final bool isAdmin = usuario.isAdmin;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/GESTIONA-LOGO.png',
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  fit: BoxFit.fitWidth,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await authService.logout();
                                    Get.to(() => LoadingScreen());
                                  },
                                  icon: Icon(Icons.exit_to_app),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.user,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Usuario: ',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(authService.usuario.value!.nombre),
                                SizedBox(width: 2),
                                isAdmin ? Text('(admin)') : SizedBox.shrink(),
                              ],
                            ),
                            SizedBox(height: 8),
                            CardSeleccion(
                              rutaALaImagenDeFondo:
                                  '${Environment.apiUrl}/images/piscinas-card.png',
                              titulo: isAdmin
                                  ? 'Gestionar piscinas'
                                  : 'Mis piscinas',
                              subtitulo: isAdmin
                                  ? null
                                  : 'Accede para ver tus turnos de trabajo',
                              alturaCard:
                                  MediaQuery.of(context).size.height * (1 / 6),
                              anchuraCard:
                                  MediaQuery.of(context).size.height * 0.8,
                              onPressed: () {
                                isAdmin
                                    ? Get.to(() => AdminPiscinasScreen())
                                    : Get.to(() => SocoPiscinasScreen());
                              },
                            ),
                            // SizedBox(height: 20,),
                            CardSeleccion(
                              rutaALaImagenDeFondo:
                                  '${Environment.apiUrl}/images/socorristas-card.png',
                              titulo: isAdmin
                                  ? 'Gestionar socorristas'
                                  : 'Mis datos',
                              subtitulo: isAdmin
                                  ? null
                                  : 'Horarios, turnos, horas trabajadas',
                              alturaCard:
                                  MediaQuery.of(context).size.height * (1 / 6),
                              anchuraCard:
                                  MediaQuery.of(context).size.height * 0.8,
                              onPressed: () {
                                if (isAdmin) {
                                  Get.to(() => AdminSocorristasScreen());
                                } else {
                                  socorristasController
                                          .socorristaSeleccionado
                                          .value =
                                      usuario;
                                  Get.to(() => InfoSocorristaScreen());
                                }
                              },
                            ),
                            isAdmin
                                ? CardSeleccion(
                                    rutaALaImagenDeFondo:
                                        '${Environment.apiUrl}/images/piscinas-fechas-card.png',
                                    titulo: 'Resumen por día',
                                    subtitulo:
                                        'Consultar todos los datos resumidos para un día concreto',
                                    alturaCard:
                                        MediaQuery.of(context).size.height *
                                        (1 / 6),
                                    anchuraCard:
                                        MediaQuery.of(context).size.height *
                                        0.8,
                                    onPressed: () {
                                      Get.to(() => ResumenPorFechaScreen());
                                    },
                                  )
                                : SizedBox.shrink(),
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
                        Text(
                          'Gestiona Piscinas App - All rights reserved',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.offAll(() => LoadingScreen());
        },
        child: Icon(Icons.refresh_outlined),
      ),
    );
  }
}
