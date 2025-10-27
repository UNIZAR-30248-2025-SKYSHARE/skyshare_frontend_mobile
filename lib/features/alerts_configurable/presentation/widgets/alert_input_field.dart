import 'package:flutter/material.dart';

class AlertInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool readOnly;

  const AlertInputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        readOnly: readOnly,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}