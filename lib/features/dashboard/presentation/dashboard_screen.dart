import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/location_header.dart';
import 'widgets/weather_card.dart';
import 'widgets/light_pollution_bar.dart';
import 'widgets/visible_sky_section.dart';
import 'widgets/sky_indicator.dart';
import '../../../core/widgets/star_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.detectAndSyncLocation(userId: 1);
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<DashboardProvider>();
    await provider.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return StarBackground(
      child: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => provider.detectAndSyncLocation(userId: 1), child: const Text('Reintentar')),
                  ],
                ),
              );
            }

            if (provider.isLoading && provider.selectedLocation == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    SizedBox(height: 12),
                    Text(
                      'Detectando ubicación…',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            final locName = provider.selectedLocation?.name ?? '';
            final country = provider.selectedLocation?.country ?? '';

            return RefreshIndicator(
              onRefresh: _loadData,
              backgroundColor: const Color(0xFF1A1F3A),
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                children: [
                  const SizedBox(height: 24),
                  LocationHeader(cityName: locName, countryName: country),
                  const SizedBox(height: 24),
                  if (provider.weather != null) WeatherCard(weather: provider.weather!),
                  const SizedBox(height: 24),
                  if (provider.lightPollution != null) LightPollutionBar(value: (provider.lightPollution!.bortleScale).toDouble()),
                  const SizedBox(height: 24),
                  if (provider.constellations.isNotEmpty) VisibleSkySection(constellations: provider.constellations),
                  const SizedBox(height: 24),
                  if (provider.skyIndicator != null) SkyIndicator(value: provider.skyIndicator!.value),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
