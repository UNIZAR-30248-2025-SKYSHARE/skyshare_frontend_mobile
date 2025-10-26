import 'dart:async';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // Importa LatLng y LatLngBounds
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart'; // Ajusta esta ruta si es necesario
import '../models/spot_model.dart'; // Ajusta esta ruta si es necesario

class LocationRepository {
  final SupabaseClient client;

  LocationRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<Position?> getCurrentPosition() async {
    // ... (este método no cambia)
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
      double lat, double lng) async {
    // ... (este método no cambia)
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=14&addressdetails=1');
    try {
      final response =
          await http.get(url, headers: {'User-Agent': 'MiAppFlutter/1.0'});
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
    // ... (este método no cambia)
    final position = await getCurrentPosition();
    if (position == null) return null;
    return LatLng(position.latitude, position.longitude);
  }

  // --- MODIFICADO PARA USAR 'latitud' y 'longitud' ---
  Future<List<Spot>> fetchSpots({LatLngBounds? bounds}) async {
    if (bounds == null) {
      return [];
    }

    try {
      final resp = await client
          .from('spot')
          .select('''
            id_spot, 
            id_usuario_creador, 
            id_ubicacion, 
            nombre, 
            descripcion, 
            url_imagen,       
            ubicacion!inner(*),  
            valoracion(puntuacion)
          ''')
          // --- CORRECCIÓN CLAVE AQUÍ ---
          .gte('ubicacion.latitud', bounds.southWest.latitude)
          .lte('ubicacion.latitud', bounds.northEast.latitude)
          .gte('ubicacion.longitud', bounds.southWest.longitude)
          .lte('ubicacion.longitud', bounds.northEast.longitude);
      // -------------------------------

      final rows = (resp as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return rows.map(Spot.fromMap).toList();
    } catch (e) {
      print('Error en fetchSpots (LocationRepository): $e'); // ¡Mira este error en tu consola!
      return [];
    }
  }
}