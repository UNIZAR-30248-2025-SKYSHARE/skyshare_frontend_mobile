import 'package:flutter/material.dart';

class ConstellationInfoPanel extends StatelessWidget {
  final Map<String, dynamic> object;
  final VoidCallback onClose;

  const ConstellationInfoPanel({
    super.key,
    required this.object,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.6), 
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getObjectIcon(object['type']),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    object['name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (object['type'] != null)
              _buildInfoRow('Type', _formatType(object['type'])),
            if (object['alt'] != null && object['az'] != null)
              _buildInfoRow(
                'Position', 
                'Alt: ${object['alt'].toStringAsFixed(1)}° Az: ${object['az'].toStringAsFixed(1)}°'
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getObjectIcon(String? type) {
    switch (type) {
      case 'star':
        return Icons.star;
      case 'planet':
        return Icons.public;
      case 'constellation':
        return Icons.auto_awesome;
      default:
        return Icons.help;
    }
  }

  String _formatType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }
}