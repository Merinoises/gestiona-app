import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MiscelaneaCard extends StatelessWidget {
  final String rutaALaImagenDeFondo;
  final String titulo;
  final IconData? icono;
  final VoidCallback onPressed;

  const MiscelaneaCard({
    super.key,
    required this.rutaALaImagenDeFondo,
    required this.titulo,
    this.icono,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Stack(
        children: [
          Opacity(
            opacity: 1.0,
            child: InkWell(
              onTap: onPressed,
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(rutaALaImagenDeFondo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // The text positioned at the bottom center
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 0,
                    child: Center(
                      child: Row(
                        children: [
                          icono != null
                              ? FaIcon(
                                  icono,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 0),
                                      blurRadius: 20,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink(),
                          icono != null
                              ? SizedBox(width: 10)
                              : SizedBox.shrink(),
                          Flexible(
                            child: AutoSizeText(
                              titulo,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 20.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              minFontSize: 12,    // Tamaño mínimo al que puede reducirse
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
