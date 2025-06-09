import 'package:flutter/material.dart';
import 'package:gestiona_app/controllers/add_pool_controller.dart';
import 'package:get/get.dart';

class DaysSelector extends StatefulWidget {
  final List<bool> selectedDays;

  const DaysSelector({super.key, required this.selectedDays});

  @override
  DaysSelectorState createState() => DaysSelectorState();
}

class DaysSelectorState extends State<DaysSelector> {

  // Etiquetas para cada día (abreviadas)
  final List<String> _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final addPoolCtrl = Get.find<AddPoolController>();

    return Center(
      child: ToggleButtons(
        isSelected: widget.selectedDays,
        onPressed: (int index) {
          setState(() {
            // Invertimos el estado: si estaba false → true; si estaba true → false
            widget.selectedDays[index] = !widget.selectedDays[index];
            addPoolCtrl.selectedDays = widget.selectedDays;
          });
        },
        borderRadius: BorderRadius.circular(30), // un radio alto para que sean redondos
        selectedColor: Colors.white,              // color del texto cuando está seleccionado
        fillColor: Colors.blue,                   // fondo azul cuando está seleccionado
        color: Colors.black87,                    // color del texto cuando NO está seleccionado
        borderColor: Colors.grey.shade400,        // borde gris claro
        selectedBorderColor: Colors.blue,         // borde azul cuando está seleccionado
        constraints: BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        children: _dayLabels.map((label) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(label),
          );
        }).toList(),
      ),
    );
  }
}
