import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;

  const LoadingOverlay({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return const SizedBox.expand(
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: true,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
