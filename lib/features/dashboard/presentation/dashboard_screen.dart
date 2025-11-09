import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/location_header.dart';
import 'widgets/weather_card.dart';
import 'widgets/light_pollution_bar.dart';
import 'widgets/visible_sky_section.dart';
import 'widgets/sky_indicator.dart';
import '../../../core/widgets/star_background.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'package:skyshare_frontend_mobile/core/i18n/language_switcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialLoadCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    await provider.detectAndSyncLocation();
    setState(() {
      _initialLoadCompleted = true;
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    if (provider.selectedLocation != null) {
      await provider.loadDashboardData();
    } else {
      await provider.detectAndSyncLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StarBackground(
      child: Stack(
        children: [
          SafeArea(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
            // build the main content (varies depending on provider state)
            Widget content;

            if (provider.errorMessage != null) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        _initializeData();
                      },
                      child: Text(AppLocalizations.of(context)?.t('retry') ?? 'Reintentar'),
                    ),
                  ],
                ),
              );
            } else if (provider.shouldShowRetry) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.t('dashboard.data_taking_long') ?? 'Los datos están tardando más de lo esperado',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)?.t('dashboard.normal_when_new_location') ?? 'Esto es normal cuando se detecta una nueva ubicación',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializeData,
                      child: Text(AppLocalizations.of(context)?.t('dashboard.retry_load') ?? 'Reintentar carga'),
                    ),
                  ],
                ),
              );
            } else if (!_initialLoadCompleted || (provider.isLoading && !provider.locationSyncCompleted)) {
              content = Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.t('dashboard.detecting_location') ?? 'Detectando ubicación…',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            } else if (provider.selectedLocation == null) {
              content = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, color: Colors.white70, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)?.t('dashboard.could_not_detect_location') ?? 'No se pudo detectar la ubicación',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializeData,
                      child: Text(AppLocalizations.of(context)?.t('dashboard.try_again') ?? 'Intentar nuevamente'),
                    ),
                  ],
                ),
              );
            } else if (provider.isLoading && provider.selectedLocation != null) {
              content = _buildContentSkeleton(provider);
            } else {
              content = _buildMainContent(provider);
            }

            // Place the language switcher only on the Dashboard, bottom-left, so right-side buttons remain visible
            return Stack(
              children: [
                content,
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: LanguageSwitcher(),
                ),
              ],
            );
              },
            ),
          ),
          // Language switcher removed from this outer layer to avoid duplicates - it's placed inside the SafeArea consumer only
        ],
      ),
    );
  }

  Widget _buildContentSkeleton(DashboardProvider provider) {
    final locName = provider.selectedLocation?.name ?? 'Ubicación no disponible';
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
          _buildShimmerWeatherCard(),
          const SizedBox(height: 24),
          _buildShimmerLightPollution(),
          const SizedBox(height: 24),
          _buildShimmerConstellations(),
          const SizedBox(height: 24),
          _buildShimmerSkyIndicator(),
        ],
      ),
    );
  }

  Widget _buildMainContent(DashboardProvider provider) {
    final locName = provider.selectedLocation?.name ?? 'Ubicación no disponible';
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
          
          provider.weather != null 
              ? WeatherCard(weather: provider.weather!)
              : _buildNoDataCard('Datos meteorológicos no disponibles'),
          
          const SizedBox(height: 24),
          
          if (provider.weather?.lightPollution != null) 
            LightPollutionBar(value: provider.weather!.lightPollution!.toDouble()),
          
          const SizedBox(height: 24),
          
          provider.constellations.isNotEmpty 
              ? VisibleSkySection(constellations: provider.constellations)
              : _buildNoDataCard('No hay datos de constelaciones visibles'),
          
          const SizedBox(height: 24),
          
          if (provider.skyIndicator != null) 
            SkyIndicator(value: provider.skyIndicator!.value),
        ].where((widget) => widget != const SizedBox(height: 0)).toList(),
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Card(
      color: const Color.fromRGBO(0, 0, 0, 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerWeatherCard() {
    return const Card(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 20,
                ),
                SizedBox(height: 8),
                Text('---', style: TextStyle(color: Colors.white70)),
              ],
            ),
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 20,
                ),
                SizedBox(height: 8),
                Text('---', style: TextStyle(color: Colors.white70)),
              ],
            ),
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 20,
                ),
                SizedBox(height: 8),
                Text('---', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLightPollution() {
    return const Card(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contaminación lumínica', 
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 8),
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
              backgroundColor: Colors.white10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerConstellations() {
    return const Card(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cielo visible', 
                style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerSkyIndicator() {
    return const Card(
      color: Color.fromRGBO(0, 0, 0, 0.3),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condiciones del cielo', 
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 8),
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
              backgroundColor: Colors.white10,
            ),
          ],
        ),
      ),
    );
  }
}