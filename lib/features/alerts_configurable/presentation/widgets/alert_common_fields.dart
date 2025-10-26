import 'package:flutter/material.dart';
import 'alert_form_field.dart';
import 'alert_input_field.dart';

class AlertCommonFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final String Function() exampleNameGetter;

  const AlertCommonFields({
    Key? key,
    required this.nameController,
    required this.dateController,
    required this.timeController,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.exampleNameGetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AlertFormField(
          label: 'NOMBRE DE LA ALERTA',
          child: AlertInputField(
            hintText: 'Ej: ${exampleNameGetter()}',
            controller: nameController,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: AlertFormField(
                label: 'FECHA',
                child: GestureDetector(
                  onTap: onSelectDate,
                  child: AbsorbPointer(
                    child: AlertInputField(
                      hintText: 'DD/MM/AAAA',
                      controller: dateController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AlertFormField(
                label: 'HORA',
                child: GestureDetector(
                  onTap: onSelectTime,
                  child: AbsorbPointer(
                    child: AlertInputField(
                      hintText: 'HH:MM',
                      controller: timeController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.access_time, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
