import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/spot_model.dart';

class LocationRepository {
  final SupabaseClient client;

  LocationRepository({SupabaseClient? client}) 
      : client = client ?? SupabaseService.instance.client;

  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> getCityCountryFromCoordinates(
    double lat, 
    double lng
  ) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=14&addressdetails=1'
    );
    try {
      final response = await http.get(
        url, 
        headers: {'User-Agent': 'MiAppFlutter/1.0'}
      );
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
        return {'city': city, 'country': country};
      }
      return {'city': 'Desconocida', 'country': 'Desconocido'};
    } catch (e) {
      return {'city': 'Desconocida', 'country': 'Desconocido'};
    }
  }

  Future<LatLng?> getCurrentLatLng() async {
    final position = await getCurrentPosition();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  Future<List<Spot>> fetchSpots({int limit = 100}) async {
    try {
      final resp = await client
          .from('spot')
          .select('''
            id_spot, 
            id_usuario_creador, 
            id_ubicacion, 
            nombre, 
            descripcion, 
            ubicacion(*),
            valoracion(puntuacion)
          ''')
          .limit(limit);
      
      final rows = (resp as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      
      return rows.map(Spot.fromMap).toList();
    } catch (e) {
      return [];
    }
  }
}