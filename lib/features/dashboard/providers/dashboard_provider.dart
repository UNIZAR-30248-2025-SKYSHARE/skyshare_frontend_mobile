import 'package:flutter/material.dart';
import '../../../core/models/location_model.dart';
import '../data/models/cielo_visible_model.dart';
import '../data/models/weather_model.dart';
import '../data/models/light_pollution_model.dart';
import '../data/models/sky_indicator_model.dart';

class DashboardProvider extends ChangeNotifier {
  Location? selectedLocation;
  final List<Location> savedLocations = [];

  List<Constellation> _constellations = [];
  WeatherData? _weather;
  LightPollution? _lightPollution;
  SkyIndicator? _skyIndicator;
  bool _isLoading = false;
  String? _errorMessage;

  List<Constellation> get constellations => _constellations;
  WeatherData? get weather => _weather;
  LightPollution? get lightPollution => _lightPollution;
  SkyIndicator? get skyIndicator => _skyIndicator;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSelectedLocation(Location location) {
    selectedLocation = location;
    if (!savedLocations.any((l) => l.id == location.id)) {
      savedLocations.add(location);
    }
    notifyListeners();
  }

  Future<void> loadDashboardData({Location? location, double? latitude, double? longitude}) async {
    final loc = location ?? selectedLocation ?? (latitude != null && longitude != null ? Location(id: 0, name: 'Custom', country: '', latitude: latitude, longitude: longitude) : null);
    if (loc == null) {
      _errorMessage = 'No location provided';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadConstellations(loc),
        _loadWeather(loc),
        _loadLightPollution(loc),
      ]);

      if (_weather != null && _lightPollution != null) {
        _calculateSkyIndicator();
      }
    } catch (e) {
      _errorMessage = 'Error al cargar los datos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadConstellations(Location loc) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _constellations = [
      Constellation(id: 1, locationId: loc.id, timestamp: DateTime.now(), name: 'Orión'),
      Constellation(id: 2, locationId: loc.id, timestamp: DateTime.now(), name: 'Osa Mayor'),
      Constellation(id: 3, locationId: loc.id, timestamp: DateTime.now(), name: 'Casiopea'),
    ];
  }

  Future<void> _loadWeather(Location loc) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _weather = WeatherData(
      id: 1,
      locationId: loc.id,
      timestamp: DateTime.now(),
      temperature: 18.5,
      humidity: 65,
      wind: 10.0,
      cloudCoverage: 50,
      lightPollution: 1.2,
      skyIndicator: null,
    );
  }

  Future<void> _loadLightPollution(Location loc) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_weather != null) {
      _lightPollution = LightPollution.fromWeatherData(_weather!, loc);
    } else {
      _lightPollution = LightPollution(bortleScale: 5, sourceValue: 3.0, location: loc, label: 'Suburbano (Clase 5)');
    }
  }

  void _calculateSkyIndicator() {
    if (_weather == null || _lightPollution == null) return;
    _skyIndicator = SkyIndicator.calculate(
      astronomicalEvents: _constellations.length,
      cloudCoverage: _weather!.cloudCoverage ?? 0.0,
      humidity: _weather!.humidity ?? 0.0,
      moonIllumination: 45.0,
      bortleScale: _lightPollution!.bortleScale,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
