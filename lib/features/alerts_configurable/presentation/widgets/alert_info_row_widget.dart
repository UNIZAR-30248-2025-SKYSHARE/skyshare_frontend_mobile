import 'package:flutter/material.dart';
import 'alert_style.dart';

class AlertInfoRowWidget extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final bool switchValue;
  final Function(bool) onSwitchChanged;

  const AlertInfoRowWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.switchValue,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isActive ? Colors.white60 : Colors.grey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Switch(
          value: switchValue,
          onChanged: onSwitchChanged,
          // modern theming: use MaterialStateProperty for thumb/track
          activeColor: kAlertAccent, // still supported on some platforms
          activeTrackColor: kAlertAccent.withOpacity(0.4),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.2),
        ),
      ],
    );
  }
}