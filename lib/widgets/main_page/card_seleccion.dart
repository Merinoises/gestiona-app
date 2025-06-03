import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';


class CardSeleccion extends StatelessWidget {
  final String rutaALaImagenDeFondo;
  final String titulo;
  final String? subtitulo;
  final double alturaCard;
  final double anchuraCard;
  final Icon? icono;
  final VoidCallback onPressed;

  const CardSeleccion({
    super.key,
    required this.rutaALaImagenDeFondo,
    required this.titulo,
    this.subtitulo,
    required this.alturaCard,
    this.icono,
    required this.onPressed,
    required this.anchuraCard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.only(bottom: alturaCard * (1 / 12)),
        child: Stack(
          children: [
            // Imagen de fondo
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: rutaALaImagenDeFondo,
                width: anchuraCard,
                height: alturaCard,
                fit: BoxFit.cover,
                placeholder:
                    (_, __) => SizedBox(
                      width: anchuraCard,
                      height: alturaCard,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (_, __, ___) => SizedBox(
                      width: anchuraCard,
                      height: alturaCard,
                      child: Center(
                        child: Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
              ),
            ),
            // Contenido superpuesto a la imagen
            Container(
              width: anchuraCard,
              height: alturaCard,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            icono != null ? icono! : const SizedBox.shrink(),
                            icono != null
                                ? const SizedBox(width: 10)
                                : const SizedBox.shrink(),
                            Expanded(
                              child: Text(
                                titulo,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 10.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (subtitulo != null)
                          // Primero, recortamos para que el blur no se salga del área
                          Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: BackdropFilter(
                                // El blur
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    // Fondo semitransparente
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: AutoSizeText(
                                    subtitulo!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    minFontSize: 10,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: anchuraCard * 0.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
