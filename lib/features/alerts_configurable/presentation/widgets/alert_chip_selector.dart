// widgets/alert_chip_selector.dart
import 'package:flutter/material.dart';

class AlertChipSelector extends StatefulWidget {
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String label;

  const AlertChipSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.label,
  });

  @override
  State<AlertChipSelector> createState() => _AlertChipSelectorState();
}

class _AlertChipSelectorState extends State<AlertChipSelector> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.options.map((option) {
            final isSelected = _selectedValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedValue = selected ? option : null;
                });
                widget.onChanged(_selectedValue);
              },
              selectedColor: const Color(0xFF6C63FF),
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white30,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}