import 'package:flutter/material.dart';

class ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const ZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            bottom: 90,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  backgroundColor: const Color(0xFF161426),
                  foregroundColor: Colors.white,
                  heroTag: 'zoomIn',
                  mini: true,
                  onPressed: onZoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  backgroundColor: const Color(0xFF161426),
                  foregroundColor: Colors.white,
                  heroTag: 'zoomOut',
                  mini: true,
                  onPressed: onZoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
