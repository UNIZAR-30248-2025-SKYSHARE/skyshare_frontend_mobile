import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/repositories/location_repository.dart';
import '../data/models/spot_model.dart';

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
  List<Spot> _spots = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LatLng? get currentPosition => _userPosition;
  LatLng? get spotPosition => _spotPosition;
  String? get city => _city;
  String? get country => _country;
  List<Spot> get spots => List.unmodifiable(_spots);

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

  // --- MODIFICADO PARA LAZY LOADING ---
  Future<void> fetchSpots({LatLngBounds? bounds}) async {
    // Si no hay bounds (zoom muy bajo), limpia los spots y no cargues nada.
    if (bounds == null) {
      clearSpots(); // Llama al nuevo método para limpiar
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Pasa los 'bounds' al repositorio
      final resp = await _locationRepository.fetchSpots(bounds: bounds);
      _spots = resp;
    } catch (e) {
      _errorMessage = 'Error al cargar spots: $e';
      _spots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // ------------------------------------

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
        location.longitude,
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

  // --- NUEVO MÉTODO AÑADIDO ---
  // Método para limpiar los spots manualmente (ej. cuando el zoom es muy bajo)
  void clearSpots() {
    if (_spots.isEmpty) return; // No notificar si ya está vacío
    
    _spots = [];
    notifyListeners();
  }
  // ------------------------------
}