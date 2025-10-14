import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String? errorMessage;

  const ErrorBanner({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.red[700],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}