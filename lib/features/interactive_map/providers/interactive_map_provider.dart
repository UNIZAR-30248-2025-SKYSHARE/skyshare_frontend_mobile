import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class InteractiveMapProvider with ChangeNotifier {
  // Estado del mapa
  bool _isLoading = false;
  String? _errorMessage;

  // Posiciones
  LatLng? _userPosition; // Ubicación real del usuario
  LatLng? _spotPosition; // Última ubicación seleccionada para spot

  // Info de lugar
  String? _city;
  String? _country;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LatLng? get currentPosition => _userPosition;
  LatLng? get spotPosition => _spotPosition;
  String? get city => _city;
  String? get country => _country;

  // Obtener la ubicación actual del usuario
  Future<void> fetchUserLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('El GPS está desactivado.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permiso de ubicación denegado permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition();
      _userPosition = LatLng(position.latitude, position.longitude);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación: $e';
      debugPrint(_errorMessage);
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
      _spotPosition = LatLng(location.latitude, location.longitude);

      final result = await getCityCountryFromOSM(location.latitude, location.longitude);
      city = result['city'] ?? 'Desconocida';
      country = result['country'] ?? 'Desconocido';

      _city = city;
      _country = country;
    } catch (e) {
      _errorMessage = 'Error al obtener ubicación del spot: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return {'city': city, 'country': country};
  }
  Future<Map<String, String>> getCityCountryFromOSM(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=14&addressdetails=1'
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'MiAppFlutter/1.0 (skyshare@dominio.com)' 
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};

        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'] ??
            address['hamlet'] ??
            address['county'] ??
            'Desconocida';

        final country = address['country'] ?? 'Desconocido';
        debugPrint('Resultado Nominatim: city=$city, country=$country');

        return {'city': city, 'country': country};
      } else {
        debugPrint('Nominatim error: ${response.statusCode}');
        
        return {'city': 'Desconocida', 'country': 'Desconocido'};
      }
    } catch (e) {
      debugPrint('Error en Nominatim: $e');
      return {'city': 'Desconocida', 'country': 'Desconocido'};
    }
  }
}