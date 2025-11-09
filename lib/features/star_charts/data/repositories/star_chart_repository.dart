import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class StarChartRepository {
  final SupabaseClient _client;

  StarChartRepository({required SupabaseClient client}) : _client = client;

  Future<Map<String, dynamic>> getCelestialBodies({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.functions.invoke('astronomy-positions', 
        body: {
          'latitude': latitude,
          'longitude': longitude,
        }
      ).timeout(const Duration(seconds: 30));

      if (response.status != 200) {
        throw Exception('Edge Function failed with status: ${response.status}');
      }

      if (response.data == null) {
        throw Exception('Edge Function returned null data');
      }

      return response.data;

    } on TimeoutException {
      throw Exception('La solicitud a la Edge Function tardó demasiado');
    } catch (e) {
      throw Exception('Error al llamar a la Edge Function: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getStoredCelestialData() async {
    try {
      final response = await _client
          .from('star_map_data')
          .select()
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (response == null) {
        return [];
      }

      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        final extracted = extractCelestialBodiesFromData(data);
        return extracted;
      }
      
      return [];
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> extractCelestialBodiesFromData(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> result = [];
    final Map<String, List<Map<String, dynamic>>> constellations = {};
    
    try {
      final table = data['table'] as Map<String, dynamic>?;
      final rows = table?['rows'] as List<dynamic>? ?? [];

      for (final row in rows) {
        try {
          final entry = row['entry'] as Map<String, dynamic>? ?? {};
          final cells = row['cells'] as List<dynamic>? ?? [];

          for (final cell in cells) {
            final position = cell['position'] as Map<String, dynamic>? ?? {};
            final horizontal = position['horizontal'] as Map<String, dynamic>? ?? position['horizonal'] as Map<String, dynamic>? ?? {};
            final altitude = horizontal['altitude'] as Map<String, dynamic>? ?? {};
            final azimuth = horizontal['azimuth'] as Map<String, dynamic>? ?? {};
            final constellation = position['constellation'] as Map<String, dynamic>? ?? {};
            final extraInfo = cell['extraInfo'] as Map<String, dynamic>? ?? {};

            final celestialBody = {
              'id': entry['id'] ?? cell['id'],
              'name': entry['name'] ?? cell['name'],
              'az': double.tryParse(azimuth['degrees']?.toString() ?? '0') ?? 0.0,
              'alt': double.tryParse(altitude['degrees']?.toString() ?? '0') ?? 0.0,
              'mag': extraInfo['magnitude'] is double 
                  ? extraInfo['magnitude'] 
                  : double.tryParse(extraInfo['magnitude']?.toString() ?? '0') ?? 0.0,
              'type': _determineType((entry['id'] ?? cell['id'])?.toString() ?? ''),
              'constellation': constellation['name'] ?? '',
              'constellation_id': constellation['id'] ?? '',
              'is_visible': (double.tryParse(altitude['degrees']?.toString() ?? '0') ?? 0.0) > 0,
            };

            result.add(celestialBody);

            final constellationName = constellation['name'];
            final constellationId = constellation['id'];
            if (constellationName != null && constellationName.isNotEmpty) {
              if (!constellations.containsKey(constellationId)) {
                constellations[constellationId] = [];
              }
              constellations[constellationId]!.add(celestialBody);
            }
          }
        } catch (e) {
          // Ignorar errores en el procesamiento de filas individuales
        }
      }

      for (final constellationId in constellations.keys) {
        final constellationObjects = constellations[constellationId]!;
        if (constellationObjects.isNotEmpty) {
          final avgAz = constellationObjects.map((obj) => obj['az'] as double).reduce((a, b) => a + b) / constellationObjects.length;
          final avgAlt = constellationObjects.map((obj) => obj['alt'] as double).reduce((a, b) => a + b) / constellationObjects.length;
          
          final brightest = constellationObjects.reduce((a, b) => 
              (a['mag'] as double) < (b['mag'] as double) ? a : b);

          final constellationObject = {
            'id': 'constellation_$constellationId',
            'name': constellationObjects.first['constellation'],
            'az': avgAz,
            'alt': avgAlt,
            'mag': brightest['mag'],
            'type': 'constellation',
            'constellation': constellationObjects.first['constellation'],
            'object_count': constellationObjects.length,
            'brightest_star': brightest['name'],
            'is_visible': constellationObjects.any((obj) => obj['is_visible'] == true),
            'stars': constellationObjects,
          };

          result.add(constellationObject);
        }
      }
    } catch (e) {
      // Manejar error general de extracción
    }

    return result;
  }

  String _determineType(String id) {
    const planets = {'sun', 'moon', 'mercury', 'venus', 'mars', 'jupiter', 'saturn', 'uranus', 'neptune', 'pluto', 'earth'};
    if (planets.contains(id)) return 'planet';
    return 'star';
  }
}