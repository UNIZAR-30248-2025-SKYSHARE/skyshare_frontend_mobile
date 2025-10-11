// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class LocationResult {
//   final double latitude;
//   final double longitude;
//   final String city;
//   final String country;

//   const LocationResult({
//     required this.latitude,
//     required this.longitude,
//     required this.city,
//     required this.country,
//   });
// }

// class LocationService {
//   LocationService._();
//   static final LocationService instance = LocationService._();

//   Future<LocationResult> getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
//       throw StateError('Location permission denied');
//     }
//     final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
//     final p = placemarks.isNotEmpty ? placemarks.first : Placemark();
//     final city = (p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '').trim();
//     final country = (p.country ?? '').trim();
//     return LocationResult(latitude: pos.latitude, longitude: pos.longitude, city: city, country: country);
//   }
// }import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // para kIsWeb
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Resultado de la ubicación
class LocationResult {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });
}

/// Servicio de ubicación seguro para Web y móviles
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Obtiene la ubicación actual (seguro para Web y móvil)
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Verificar si el servicio está disponible
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Servicio de geolocalización no disponible, usando ubicación simulada.');
        return _fakeLocation();
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        print('⚠️ Permiso de ubicación denegado, usando ubicación simulada.');
        return _fakeLocation();
      }

      // Obtener posición actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String city = 'Unknown';
      String country = 'Unknown';

      if (kIsWeb) {
        // 🌍 En web usamos Nominatim (OpenStreetMap) para reverse geocoding
        try {
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json'
            '&lat=${position.latitude}&lon=${position.longitude}',
          );
          final response = await http.get(
            url,
            headers: {'User-Agent': 'FlutterApp'}, // requerido por Nominatim
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final address = data['address'] ?? {};
            city = address['city'] ??
                address['town'] ??
                address['village'] ??
                address['state'] ??
                'Unknown';
            country = address['country'] ?? 'Unknown';
          } else {
            print('Error obteniendo datos de Nominatim: ${response.statusCode}');
          }
        } catch (e) {
          print('Error usando Nominatim: $e');
        }
      } else {
        // 📱 En móvil usamos el plugin oficial
        try {
          final placemarks =
              await placemarkFromCoordinates(position.latitude, position.longitude);
          final p = placemarks.isNotEmpty ? placemarks.first : Placemark();
          city = (p.locality ??
                  p.subAdministrativeArea ??
                  p.administrativeArea ??
                  '')
              .trim();
          country = (p.country ?? '').trim();
        } catch (e) {
          print('Error en placemarkFromCoordinates: $e');
        }
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city.isNotEmpty ? city : 'Unknown',
        country: country.isNotEmpty ? country : 'Unknown',
      );
    } catch (e) {
      print('Error general obteniendo ubicación: $e. Usando ubicación simulada.');
      return _fakeLocation();
    }
  }

  /// Ubicación simulada (Madrid)
  LocationResult _fakeLocation() {
    return const LocationResult(
      latitude: 40.4168,
      longitude: -3.7038,
      city: 'Madrid',
      country: 'España',
    );
  }
}
