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
    if (date == null) return 'No date set';

    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final targetDate = DateTime(date!.year, date!.month, date!.day);
    final diff = targetDate.difference(currentDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return 'In $diff days';
    if (diff < 30) {
      final weeks = (diff / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    }

    return '${targetDate.day.toString().padLeft(2, '0')}/'
        '${targetDate.month.toString().padLeft(2, '0')}/'
        '${targetDate.year}';
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
      key: const Key('alert_footer_date'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withAlpha((0.1 * 255).toInt())
            : Colors.grey.withAlpha((0.05 * 255).toInt()),
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
    return IconButton(
      key: const Key('alert_footer_delete'),
      onPressed: onDelete,
      icon: const Icon(Icons.delete_outline),
      color: Colors.red.shade700,
      iconSize: 24,
      tooltip: 'Delete alert',
    );
  }
}
