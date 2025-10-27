import 'package:flutter/material.dart';
import 'alert_style.dart';

class AlertInfoRowWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final bool isActive;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const AlertInfoRowWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.isActive,
    required this.switchValue,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isActive ? Colors.white : Colors.grey;
    final subtitleColor = isActive ? Colors.white60 : Colors.grey;

    return Row(
      children: [
        icon,
        const SizedBox(width: 16),
        Expanded(child: _buildTextColumn(textColor, subtitleColor)),
        Switch(
          value: switchValue,
          onChanged: onSwitchChanged,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected) ? kAlertAccent : Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected) 
              ? kAlertAccent.withAlpha((0.4 * 255).toInt())
              : Colors.grey.withAlpha((0.2 * 255).toInt());
          }),
        ),
      ],
    );
  }

  Widget _buildTextColumn(Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        subtitleWidget ?? Text(
          subtitle ?? '',
          style: TextStyle(
            color: subtitleColor,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
