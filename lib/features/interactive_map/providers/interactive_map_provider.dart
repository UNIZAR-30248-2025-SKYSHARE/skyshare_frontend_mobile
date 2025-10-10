import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart'; 

class InteractiveMapProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  String? _errorMessage;
  bool _isLoading = false;
  String? _city;
  String? _country;

  LatLng? get currentPosition => _currentPosition;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String? get city => _city;
  String? get country => _country;

  Future<void> fetchUserLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final locationResult = await LocationService.instance.getCurrentLocation();
      
      _currentPosition = LatLng(
        locationResult.latitude,
        locationResult.longitude,
      );
      _city = locationResult.city;
      _country = locationResult.country;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación: $e';
      _currentPosition = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}