import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final SupabaseClient client;

  WeatherRepository({SupabaseClient? client}) : client = client ?? SupabaseService.instance.client;

  Future<WeatherData?> fetchLatestForLocation(int locationId) async {
    final resp = await client
        .from('informacion_meteorologica')
        .select()
        .eq('id_ubicacion', locationId)
        .order('ultima_actualizacion', ascending: false)
        .limit(1)
        .maybeSingle();
    if (resp == null) return null;
    return WeatherData.fromMap(Map<String, dynamic>.from(resp as Map));
  }

  Future<List<WeatherData>> fetchHistoryForLocation(int locationId, {int limit = 48}) async {
    final resp = await client
        .from('informacion_meteorologica')
        .select()
        .eq('id_ubicacion', locationId)
        .order('ultima_actualizacion', ascending: false)
        .limit(limit);
    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return rows.map(WeatherData.fromMap).toList();
  }

  Future<bool> insertWeather(WeatherData w) async {
    final resp = await client.from('informacion_meteorologica').insert([w.toMap()]);
    return resp != null;
  }

  Future<bool> upsertWeather(WeatherData w) async {
    final resp = await client.from('informacion_meteorologica').upsert([w.toMap()]);
    return resp != null;
  }
}
