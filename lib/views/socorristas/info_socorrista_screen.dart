import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/socorristas_controller.dart';
import 'package:gestiona_app/models/pool.dart';
import 'package:gestiona_app/models/usuario.dart';
import 'package:gestiona_app/services/auth_service.dart';
import 'package:gestiona_app/utils/aux_methods.dart';
import 'package:gestiona_app/widgets/admin/turnos/editar_o_eliminar_turno.dart';
import 'package:get/get.dart';

class InfoSocorristaScreen extends StatefulWidget {
  const InfoSocorristaScreen({super.key});

  @override
  State<InfoSocorristaScreen> createState() => _InfoSocorristaScreenState();
}

class _InfoSocorristaScreenState extends State<InfoSocorristaScreen> {
  @override
  Widget build(BuildContext context) {
    final AuxMethods auxMethods = AuxMethods();
    final AuthService authService = Get.find<AuthService>();
    final SocorristasController socorristasCtrl =
        Get.find<SocorristasController>();

    Usuario socorrista = socorristasCtrl.socorristaSeleccionado.value!;

    final Set<Pool> poolsDelSocorrista = socorrista.turnos
        .map((turno) => turno.pool)
        .toSet();

    final ahora = DateTime.now();
    final futuros =
        socorrista.turnos.where((t) => !t.start.isBefore(ahora)).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final proximosTres = futuros.length <= 3 ? futuros : futuros.sublist(0, 3);

    final int anyo = ahora.year;
    final List<int> meses = [6, 7, 8, 9];

    final double importeTotal = socorrista.importeTotalTurnos();
    final String importeTotalStr = '${importeTotal.toStringAsFixed(2)} €';

    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Datos socorrista: ${auxMethods.capitalize(socorrista.nombre)}',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 188, 188),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            // 1) Envolvemos todo en un SingleChildScrollView:
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ────────── Bloque “Próximos turnos” ──────────
                  const Text(
                    '🔜 Próximos turnos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (proximosTres.isEmpty)
                    const Center(child: Text('📭 Sin turnos próximos'))
                  else
                    ...proximosTres.asMap().entries.map((entry) {
                      final index = entry.key; // 0, 1, 2...
                      final turno = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[300],
                              radius: 12,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${turno.pool.nombre} · ${turno.fechaYHoraDetallada()}',
                                style: const TextStyle(fontSize: 14),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                  const Divider(height: 32),

                  // ────────── Bloque “Turnos completos por piscina” ──────────
                  const Text(
                    '📋 Turnos completos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  // Reemplazamos el ListView que estaba aquí por un Column de ExpansionTiles
                  if (poolsDelSocorrista.isEmpty)
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          '🏝️ No tiene asignado ningún turno en ninguna piscina',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: poolsDelSocorrista.map((pool) {
                        // 1) Sacamos todos los turnos de esta piscina...
                        final turnosDeEstePool = socorristasCtrl
                            .socorristaSeleccionado
                            .value!
                            .turnos
                            .where((t) => t.pool.id == pool.id)
                            .toList();
                        // 2) Ordenamos POR FECHA (start) de menor a mayor
                        turnosDeEstePool.sort(
                          (a, b) => a.start.compareTo(b.start),
                        );
                        // 3) Dividimos en pasados/futuros:
                        final pasados = turnosDeEstePool
                            .where((t) => t.end.isBefore(ahora))
                            .toList();
                        final futurosPool = turnosDeEstePool
                            .where((t) => !t.end.isBefore(ahora))
                            .toList();

                        return ExpansionTile(
                          title: Text(pool.nombre),
                          childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          children: [
                            // 3.a Si hay turnos pasados, los pintamos en tono apagado
                            if (pasados.isNotEmpty) ...[
                              const Text(
                                'Turnos anteriores:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ...pasados.map((turno) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: GestureDetector(
                                    onTap: authService.usuario.value!.isAdmin
                                        ? () async {
                                            await Get.dialog(
                                              EditarOEliminarTurno(
                                                turno: turno,
                                                nombreSocorrista:
                                                    socorrista.nombre,
                                                pool: pool,
                                              ),
                                            );

                                            socorrista = socorristasCtrl
                                                .getSocorristaByNombre(
                                                  socorrista.nombre,
                                                )!;
                                          }
                                        : null,
                                    child: Text(
                                      turno.fechaYHoraDetallada(),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                            ],

                            // 3.b Si hay turnos futuros, los pintamos en color resaltado
                            if (futurosPool.isNotEmpty) ...[
                              const Text(
                                'Turnos próximos:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ...futurosPool.map((turno) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: GestureDetector(
                                    onTap: authService.usuario.value!.isAdmin
                                        ? () async {
                                            await Get.dialog(
                                              EditarOEliminarTurno(
                                                turno: turno,
                                                nombreSocorrista:
                                                    socorrista.nombre,
                                                pool: pool,
                                              ),
                                            );
                                            socorrista = socorristasCtrl
                                                .getSocorristaByNombre(
                                                  socorrista.nombre,
                                                )!;
                                          }
                                        : null,
                                    child: Text(
                                      turno.fechaYHoraDetallada(),
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }).toList(),
                    ),

                  const Divider(height: 32),

                  // ────────── Bloque “Total horas realizadas” ──────────
                  const Text(
                    '🕒 Total horas realizadas:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Recorremos cada mes del período Junio–Octubre
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meses.map((mes) {
                      // 1) Horas planificadas: usa totalHorasEnMes
                      final Duration duracionPlanificada = socorristasCtrl
                          .socorristaSeleccionado
                          .value!
                          .totalHorasEnMes(anyo, mes);

                      // 2) Horas realizadas: sumamos únicamente los turnos cuyo end < ahora
                      Duration durRealizadas = Duration.zero;
                      for (var turno
                          in socorristasCtrl
                              .socorristaSeleccionado
                              .value!
                              .turnos) {
                        if (turno.start.year == anyo &&
                            turno.start.month == mes) {
                          if (turno.end.isBefore(ahora)) {
                            durRealizadas += turno.duracion;
                          }
                        }
                      }

                      // 3) Formateamos cada Duration en "Xh Ym"
                      final String horasPlan = auxMethods.formatDuration(
                        duracionPlanificada,
                      );
                      final String horasReal = auxMethods.formatDuration(
                        durRealizadas,
                      );

                      // 4) Nombre del mes en texto corto
                      final String nombreMes = auxMethods.nombreMes(mes);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1) Nombre del mes en negrita
                            Text(
                              nombreMes,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // 2) Horas planificadas
                            Text(
                              'Planificadas totales: $horasPlan',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 2),

                            // 3) Horas realizadas
                            Text(
                              'Realizadas: $horasReal',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (authService.usuario.value!.isAdmin) ...[
                    const Divider(height: 32),

                    // ────────── Bloque “Total pagos” ──────────
                    const Text(
                      '💲 Pagos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Recorremos cada mes del período Junio–Octubre
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: meses.map((mes) {
                        final double importeMes = socorristasCtrl
                            .socorristaSeleccionado
                            .value!
                            .importeAPagarEnMes(anyo, mes);
                        final String importeMesStr =
                            '${importeMes.toStringAsFixed(2)} €';

                        final String nombreMes = auxMethods.nombreMes(mes);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                '$nombreMes: ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                importeMesStr,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    DashedDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'IMPORTE TOTAL: $importeTotalStr',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
