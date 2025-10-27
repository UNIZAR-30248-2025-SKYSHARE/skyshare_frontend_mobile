import 'package:flutter/material.dart';

class AlertErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AlertErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildErrorIcon(),
            const SizedBox(height: 16),
            _buildErrorTitle(),
            const SizedBox(height: 8),
            _buildErrorMessage(),
            const SizedBox(height: 24),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
      color: Colors.red.withAlpha((0.1 * 255).toInt()),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 48,
      ),
    );
  }

  Widget _buildErrorTitle() {
    return const Text(
      'Error loading alerts', // traducido
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      error,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      key: const Key('alert_retry_button'),
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Retry'), // traducido
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
