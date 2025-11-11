
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class ARCheckButton extends StatefulWidget {
  final VoidCallback onARAvailable;
  
  const ARCheckButton({
    super.key,
    required this.onARAvailable,
  });

  @override
  State<ARCheckButton> createState() => _ARCheckButtonState();
}

class _ARCheckButtonState extends State<ARCheckButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onARAvailable,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.view_in_ar, size: 20),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)?.t('view_in_ar') ?? 'Ver en AR'),
        ],
      ),
    );
  }
}