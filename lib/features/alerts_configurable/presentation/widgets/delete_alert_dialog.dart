import 'package:flutter/material.dart';

class DeleteAlertDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteAlertDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: _buildTitle(),
      content: _buildContent(),
      actions: _buildActions(context),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
          color: Colors.red.withAlpha((0.1 * 255).toInt()),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Flexible(
          fit: FlexFit.tight,
          child: Text(
            'Delete alert?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Text(
        'This action cannot be undone. The alert will be permanently deleted.',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        key: const Key('delete_dialog_cancel'),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(
          'Cancelar',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      ElevatedButton(
        key: const Key('delete_dialog_confirm'),
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Eliminar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }
}
