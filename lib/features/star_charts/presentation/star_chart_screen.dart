import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/star_chart_content.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/providers/star_chart_provider.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/calibration_guide.dart';
import 'package:skyshare_frontend_mobile/features/star_charts/presentation/widgets/custom_back_button.dart';

class StarChartScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const StarChartScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<StarChartScreen> createState() => _StarChartScreenState();
}

class _StarChartScreenState extends State<StarChartScreen> {
  bool _showCalGuide = true;
  bool _shouldReload = true;

  @override
  void didUpdateWidget(StarChartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _shouldReload = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCalGuide) {
      return CalibrationGuide(
        onContinue: () => setState(() => _showCalGuide = false),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Consumer<StarChartProvider>(
            builder: (context, starChartProvider, child) {
              if (_shouldReload) {
                _shouldReload = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  starChartProvider.fetchCelestialBodies(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                  );
                });
              }
              
              return StarChartContent(
                starChartProvider: starChartProvider,
              );
            },
          ),
          const Positioned(
            top: 0,
            left: 0,
            child: CustomBackButton(),
          ),
        ],
      ),
    );
  }
}