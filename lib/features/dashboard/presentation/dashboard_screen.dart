import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/location_header.dart';
import 'widgets/weather_card.dart';
import 'widgets/light_pollution_bar.dart';
import 'widgets/visible_sky_section.dart';
import 'widgets/sky_indicator.dart';
import '../../../core/widgets/app_navigation.dart';
import '../../../core/widgets/star_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<DashboardProvider>();
    await provider.loadDashboardData(latitude: 37.7749, longitude: -122.4194);
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
              }

              if (provider.errorMessage != null) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
                  ]),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadData,
                backgroundColor: const Color(0xFF1A1F3A),
                color: Colors.white,
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 120), children: [
                  const SizedBox(height: 24),
                  LocationHeader(cityName: 'Zaragoza', countryName: 'España'),
                  const SizedBox(height: 24),
                  if (provider.weather != null) WeatherCard(weather: provider.weather!),
                  const SizedBox(height: 24),
                  if (provider.lightPollution != null) LightPollutionBar(value: provider.lightPollution!.bortleScale.toDouble()),
                  const SizedBox(height: 24),
                  if (provider.constellations.isNotEmpty) VisibleSkySection(constellations: provider.constellations),
                  const SizedBox(height: 24),
                  if (provider.skyIndicator != null) SkyIndicator(value: provider.skyIndicator!.score),
                ]),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(
        selectedIndex: _selectedIndex,
        onTap: _onNavTapped,
        locationCount: 2, 
        onAddLocation: () {
        },
      ),
    );
  }
}
