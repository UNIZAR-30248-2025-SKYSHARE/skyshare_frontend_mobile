import 'package:flutter/material.dart';
import 'alert_style.dart';

class AlertToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AlertToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('alert_toggle_container'),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Switch(
            key: const Key('alert_toggle_switch'),
            value: value,
            onChanged: onChanged,
            activeThumbColor: kAlertAccent,
            activeTrackColor: kAlertAccent.withAlpha((0.4 * 255).toInt()),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withAlpha((0.2 * 255).toInt()),
          ),
        ],
      ),
    );
  }
}
