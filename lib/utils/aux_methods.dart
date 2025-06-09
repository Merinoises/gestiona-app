import 'package:flutter/material.dart';

class AuxMethods {
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  bool isToday(DateTime date) {
    final DateTime today = DateTime.now();
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return true;
    }
    return false;
  }

  /// Recibe una duración y devuelve un string en formato "Xh Ym".
  String formatDuration(Duration d) {
    final int horas = d.inHours;
    final int minutos = d.inMinutes.remainder(60);
    return '${horas}h ${minutos}m';
  }

  /// Dado el número de mes (1–12), devuelve el nombre en español.
  String nombreMes(int mes) {
    const List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    if (mes < 1 || mes > 12) return '';
    return meses[mes - 1];
  }

  Future<TimeOfDay?> pickHoraInicio(BuildContext ctx) async {
    final TimeOfDay inicial = TimeOfDay(hour: 8, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: inicial,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', ''),
          child: child,
        );
      },
    );
    return picked;
  }

  Future<TimeOfDay?> pickHoraFinalizacion(BuildContext ctx) async {
    final TimeOfDay finalizacion = TimeOfDay(hour: 20, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: finalizacion,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es', ''),
          child: child,
        );
      },
    );
    return picked;
  }
}

class DashedDivider extends StatelessWidget {
  /// Grosor del trazo (alto del guión).
  final double height;

  /// Longitud de cada guión.
  final double dashWidth;

  /// Espacio entre guiones.
  final double dashGap;

  /// Color de los guiones.
  final Color color;

  const DashedDivider({
    this.height = 1.0,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.color = Colors.grey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      // Ocupa todo el ancho disponible
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          dashWidth: dashWidth,
          dashGap: dashGap,
          color: color,
          strokeWidth: height,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashGap;
  final Color color;
  final double strokeWidth;

  _DashedLinePainter({
    required this.dashWidth,
    required this.dashGap,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;

    // Dibujamos guiones de izquierda a derecha
    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) {
    return old.dashWidth != dashWidth ||
        old.dashGap != dashGap ||
        old.color != color ||
        old.strokeWidth != strokeWidth;
  }
}
