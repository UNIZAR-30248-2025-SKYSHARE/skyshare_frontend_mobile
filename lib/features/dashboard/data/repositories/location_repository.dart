import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/location_model.dart';
import '../../../../core/services/supabase_service.dart';

class LocationRepository {
  final SupabaseClient client;

  LocationRepository({SupabaseClient? client}) : client = client ?? SupabaseService.instance.client;

  Future<Location?> fetchUserCurrentLocation(int userId) async {
    final resp = await client
        .from('usuarioubicacion')
        .select('id_ubicacion,fecha_registro,ubicacion(*)')
        .eq('id_usuario', userId)
        .order('fecha_registro', ascending: false)
        .limit(1)
        .maybeSingle();
    if (resp == null) return null;
    final map = Map<String, dynamic>.from(resp as Map);
    final ubicacionMap = map['ubicacion'] as Map<String, dynamic>?;
    if (ubicacionMap == null) return null;
    return Location.fromMap(ubicacionMap);
  }

  Future<Location?> createLocation({
    required double latitude,
    required double longitude,
    required String name,
    required String country,
  }) async {
    final resp = await client.from('ubicacion').insert([
      {'latitud': latitude, 'longitud': longitude, 'nombre': name, 'pais': country}
    ]).select().maybeSingle();
    if (resp == null) return null;
    return Location.fromMap(Map<String, dynamic>.from(resp as Map));
  }

  Future<bool> createUserLocationAssociation({
    required int userId,
    required int locationId,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    final resp = await client.from('usuarioubicacion').insert([
      {'id_usuario': userId, 'id_ubicacion': locationId, 'fecha_registro': now}
    ]).select().maybeSingle();

    return resp != null;
  }

  Future<bool> deleteUserLocationAssociations(int userId) async {
    final resp = await client.from('usuarioubicacion').delete().eq('id_usuario', userId);
    return resp != null;
  }
}
