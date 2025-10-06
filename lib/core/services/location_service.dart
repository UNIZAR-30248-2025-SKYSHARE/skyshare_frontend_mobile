import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<LocationResult> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      throw StateError('Location permission denied');
    }

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
    
    final pos = await Geolocator.getCurrentPosition(locationSettings: settings);
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final p = placemarks.isNotEmpty ? placemarks.first : const Placemark();
    final city = (p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '').trim();
    final country = (p.country ?? '').trim();
    return LocationResult(latitude: pos.latitude, longitude: pos.longitude, city: city, country: country);
  }
}
