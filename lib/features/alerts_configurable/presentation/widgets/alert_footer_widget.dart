import 'package:flutter/material.dart';

class AlertFooterWidget extends StatelessWidget {
  final DateTime? date;
  final bool isActive;
  final VoidCallback onDelete;

  const AlertFooterWidget({
    super.key,
    required this.date,
    required this.isActive,
    required this.onDelete,
  });

  String _getDateText() {
    if (date == null) return 'Sin fecha';

    final now = DateTime.now();
    final diff = date!.difference(now);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Mañana';
    } else if (diff.inDays < 7) {
      return 'En ${diff.inDays} días';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'En $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else {
      return '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateInfo(),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildDateInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: isActive ? Colors.white60 : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            _getDateText(),
            style: TextStyle(
              color: isActive ? Colors.white60 : Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
        color: Colors.red.shade700,
        iconSize: 20,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        tooltip: 'Eliminar alerta',
      ),
    );
  }
}