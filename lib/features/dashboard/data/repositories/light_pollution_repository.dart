import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/light_pollution_model.dart';
import '../models/weather_model.dart';
import '../../../../core/models/location_model.dart';

class LightPollutionRepository {
  final SupabaseClient client;

  LightPollutionRepository({SupabaseClient? client}) : client = client ?? SupabaseService.instance.client;

  Future<LightPollution?> fetchLatestForLocation(int locationId) async {
    final resp = await client
        .from('informacion_meteorologica')
        .select()
        .eq('id_ubicacion', locationId)
        .order('ultima_actualizacion', ascending: false)
        .limit(1)
        .maybeSingle();
    if (resp == null) return null;
    final w = WeatherData.fromMap(Map<String, dynamic>.from(resp as Map));
    final loc = Location(id: w.locationId, name: '', country: '', latitude: 0, longitude: 0);
    return LightPollution.fromWeatherData(w, loc);
  }

  Future<bool> insertLightPollutionForLocation(int locationId, double sourceValue) async {
    final now = DateTime.now().toIso8601String();
    final resp = await client.from('informacion_meteorologica').insert([
      {'id_ubicacion': locationId, 'ultima_actualizacion': now, 'contaminacion_luminica': sourceValue}
    ]);
    return resp != null;
  }
}
