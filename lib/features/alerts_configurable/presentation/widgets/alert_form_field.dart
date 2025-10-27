import 'package:flutter/material.dart';

class AlertFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  // Keys opcionales para testing
  final Key? labelKey;
  final Key? childKey;

  const AlertFormField({
    super.key,
    required this.label,
    required this.child,
    this.padding,
    this.labelKey,
    this.childKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            key: labelKey ?? Key('alert_form_label_$label'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            key: childKey ?? Key('alert_form_child_$label'),
            child: child,
          ),
        ],
      ),
    );
  }
}
