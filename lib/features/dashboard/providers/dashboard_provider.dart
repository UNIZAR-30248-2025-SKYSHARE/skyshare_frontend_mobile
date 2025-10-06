import 'package:flutter/material.dart';
import '../../../core/models/location_model.dart';
import '../data/models/visible_sky_model.dart';
import '../data/models/weather_model.dart';
import '../data/models/sky_indicator_model.dart';
import '../data/repositories/weather_repository.dart';
import '../data/repositories/visible_sky_repository.dart';
import '../data/repositories/location_repository.dart';
import '../../../core/services/location_service.dart';

class DashboardProvider extends ChangeNotifier {
  final WeatherRepository weatherRepository;
  final VisibleSkyRepository visibleSkyRepository;
  final LocationRepository locationRepository;

  Location? selectedLocation;
  final List<Location> savedLocations = [];

  List<VisibleSkyItem> _constellations = [];
  WeatherData? _weather;
  SkyIndicator? _skyIndicator;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardProvider({
    required this.weatherRepository,
    required this.visibleSkyRepository,
    required this.locationRepository,
  });

  List<VisibleSkyItem> get constellations => _constellations;
  WeatherData? get weather => _weather;
  SkyIndicator? get skyIndicator => _skyIndicator;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSelectedLocation(Location location) {
    selectedLocation = location;
    if (!savedLocations.any((l) => l.id == location.id)) savedLocations.add(location);
    notifyListeners();
  }

  Future<void> detectAndSyncLocation({required int userId}) async {
    try {
      final lr = await LocationService.instance.getCurrentLocation();
      final currentCity = lr.city;
      final currentCountry = lr.country;
      final existing = await locationRepository.fetchUserCurrentLocation(userId);
      if (existing != null && existing.name.toLowerCase() == currentCity.toLowerCase()) {
        setSelectedLocation(existing);
        await loadDashboardData(location: existing);
        return;
      }
      await locationRepository.deleteUserLocationAssociations(userId);
      final created = await locationRepository.createLocation(
        latitude: lr.latitude,
        longitude: lr.longitude,
        name: currentCity.isNotEmpty ? currentCity : '${lr.latitude.toStringAsFixed(4)},${lr.longitude.toStringAsFixed(4)}',
        country: currentCountry,
      );
      if (created == null) {
        _errorMessage = 'No se pudo crear la nueva ubicación';
        notifyListeners();
        return;
      }
      final ok = await locationRepository.createUserLocationAssociation(userId: userId, locationId: created.id);
      if (!ok) {
        _errorMessage = 'No se pudo asociar la ubicación al usuario';
        notifyListeners();
        return;
      }
      setSelectedLocation(created);
      await loadDashboardData(location: created);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
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
      final futures = <Future>[];
      futures.add(_loadWeather(loc));
      futures.add(_loadConstellations(loc));
      await Future.wait(futures);
      
      _loadSkyIndicatorFromWeather();
    } catch (e) {
      _errorMessage = 'Error al cargar los datos: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadConstellations(Location loc) async {
    if (loc.id != 0) {
      _constellations = await visibleSkyRepository.fetchLatestForLocation(loc.id);
    } else {
      _constellations = [];
    }
  }

  Future<void> _loadWeather(Location loc) async {
    if (loc.id != 0) {
      _weather = await weatherRepository.fetchLatestForLocation(loc.id);
    } else {
      _weather = null;
    }
  }

  void _loadSkyIndicatorFromWeather() {
    if (_weather == null) {
      _skyIndicator = null;
      return;
    }

    if (_weather!.skyIndicator != null) {
      _skyIndicator = SkyIndicator.fromValue(_weather!.skyIndicator!);
    } else {
      _calculateSkyIndicatorFallback();
    }
  }

  void _calculateSkyIndicatorFallback() {
    if (_weather == null) {
      _skyIndicator = null;
      return;
    }
    
    _skyIndicator = SkyIndicator.calculate(
      astronomicalEvents: _constellations.length,
      cloudCoverage: _weather!.cloudCoverage ?? 0.0,
      humidity: _weather!.humidity ?? 0.0,
      moonIllumination: 45.0,
      bortleScale: _weather!.lightPollution ?? 0.0,
    );
    
    print('WARNING: SkyIndicator calculado como fallback. Debería estar en la BD.');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}