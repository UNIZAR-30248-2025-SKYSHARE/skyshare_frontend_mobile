import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../data/repositories/location_repository.dart';

class InteractiveMapProvider with ChangeNotifier {
  final LocationRepository _locationRepository;

  InteractiveMapProvider({required LocationRepository locationRepository})
      : _locationRepository = locationRepository;

  bool _isLoading = false;
  String? _errorMessage;
  LatLng? _userPosition;
  LatLng? _spotPosition;
  String? _city;
  String? _country;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LatLng? get currentPosition => _userPosition;
  LatLng? get spotPosition => _spotPosition;
  String? get city => _city;
  String? get country => _country;

  Future<void> fetchUserLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userPosition = await _locationRepository.getCurrentLatLng();
      if (_userPosition == null) {
        _errorMessage = 'No se pudo obtener la ubicación';
      }
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, String>> fetchSpotLocation(LatLng? location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String city = 'Desconocida';
    String country = 'Desconocido';

    try {
      if (location == null) throw Exception('La ubicación proporcionada es nula.');
      _spotPosition = location;

      final result = await _locationRepository.getCityCountryFromCoordinates(
        location.latitude, 
        location.longitude
      );
      city = result['city'] ?? 'Desconocida';
      country = result['country'] ?? 'Desconocido';

      _city = city;
      _country = country;
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación del spot: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return {'city': city, 'country': country};
  }
}