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
  bool _locationSyncCompleted = false;
  bool _dataLoaded = false;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const Duration _initialDelay = Duration(seconds: 2);

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
  bool get locationSyncCompleted => _locationSyncCompleted;
  bool get dataLoaded => _dataLoaded;

  void setSelectedLocation(Location location) {
    selectedLocation = location;
    if (!savedLocations.any((l) => l.id == location.id)) {
      savedLocations.add(location);
    }
    notifyListeners();
  }

  Future<void> detectAndSyncLocation({String? userId}) async {
    try {
      _isLoading = true;
      _locationSyncCompleted = false;
      _dataLoaded = false;
      _retryCount = 0;
      _errorMessage = null;
      notifyListeners();

      final uid = userId ?? locationRepository.client.auth.currentUser?.id;
      if (uid == null) {
        _errorMessage = 'Usuario no autenticado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final lr = await LocationService.instance.getCurrentLocation();
      final currentCity = lr.city;
      final currentCountry = lr.country;

      final existingUserLocation = await locationRepository.fetchUserCurrentLocation(uid);
      
      if (existingUserLocation != null && 
          existingUserLocation.name.toLowerCase() == currentCity.toLowerCase()) {
        setSelectedLocation(existingUserLocation);
        _locationSyncCompleted = true;
        await _loadDashboardDataWithRetry(location: existingUserLocation);
        return;
      }

      final existingLocation = await locationRepository.findLocationByName(currentCity, currentCountry);
      
      Location? targetLocation;
      if (existingLocation != null) {
        await locationRepository.deleteUserLocationAssociations(uid);
        final ok = await locationRepository.createUserLocationAssociation(
          userId: uid, 
          locationId: existingLocation.id
        );
        if (!ok) {
          throw Exception('No se pudo asociar la ubicación existente al usuario');
        }
        targetLocation = existingLocation;
      } else {
        await locationRepository.deleteUserLocationAssociations(uid);
        final created = await locationRepository.createLocation(
          latitude: lr.latitude,
          longitude: lr.longitude,
          name: currentCity.isNotEmpty ? currentCity : '${lr.latitude.toStringAsFixed(4)},${lr.longitude.toStringAsFixed(4)}',
          country: currentCountry,
        );
        if (created == null) {
          throw Exception('No se pudo crear la nueva ubicación');
        }
        final ok = await locationRepository.createUserLocationAssociation(
          userId: uid, 
          locationId: created.id
        );
        if (!ok) {
          throw Exception('No se pudo asociar la nueva ubicación al usuario');
        }
        targetLocation = created;
      }

      setSelectedLocation(targetLocation);
      _locationSyncCompleted = true;
      
      await Future.delayed(_initialDelay);
      await _loadDashboardDataWithRetry(location: targetLocation);

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _locationSyncCompleted = false;
      notifyListeners();
    }
  }

  Future<void> _loadDashboardDataWithRetry({Location? location}) async {
    while (_retryCount < _maxRetries) {
      try {
        await _loadDashboardDataSingleAttempt(location: location);
        
        if (_weather != null || _constellations.isNotEmpty) {
          _dataLoaded = true;
          _isLoading = false;
          notifyListeners();
          return;
        }
        
        _retryCount++;
        if (_retryCount < _maxRetries) {
          final delay = Duration(seconds: 2 * (1 << (_retryCount - 1)));
          await Future.delayed(delay);
        }
      } catch (e) {
        _retryCount++;
        if (_retryCount >= _maxRetries) {
          _errorMessage = 'No se pudieron cargar los datos después de $_maxRetries intentos';
          _isLoading = false;
          notifyListeners();
          return;
        }
        final delay = Duration(seconds: 2 * (1 << (_retryCount - 1)));
        await Future.delayed(delay);
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDashboardDataSingleAttempt({Location? location}) async {
    final loc = location ?? selectedLocation;
    if (loc == null) {
      throw Exception('No location provided');
    }

    final futures = <Future>[];
    futures.add(_loadWeather(loc));
    futures.add(_loadConstellations(loc));
    await Future.wait(futures);
    
    _loadSkyIndicatorFromWeather();
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
    _retryCount = 0;
    notifyListeners();

    try {
      await _loadDashboardDataSingleAttempt(location: loc);
      _dataLoaded = true;
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
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetLocationSync() {
    _locationSyncCompleted = false;
    _dataLoaded = false;
    _retryCount = 0;
    notifyListeners();
  }

  bool get shouldShowRetry {
    return !_isLoading && _locationSyncCompleted && !_dataLoaded && _retryCount >= _maxRetries;
  }
}