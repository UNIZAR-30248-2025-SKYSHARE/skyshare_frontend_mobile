import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class LocationRepository {
  final SupabaseClient client;

  LocationRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<int?> getCurrentLocationId(int userId) async {
    final resp = await client
        .from('usuarioubicacion')
        .select('id_ubicacion(id_ubicacion)')
        .eq('id_usuario', userId)
        .order('fecha_registro', ascending: false)
        .limit(1)
        .maybeSingle();

    if (resp == null) return null;

    final nested = (resp)['id_ubicacion'];
    if (nested == null) return null;

    final id = nested['id_ubicacion'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    if (id is num) return id.toInt();
    return null;
  }

  Future<List<Map<String, dynamic>>> getSavedLocations(int userId) async {
    final resp = await client
        .from('usuarioubicacion')
        .select('id_ubicacion(id_ubicacion, nombre, latitud, longitud), fecha_registro')
        .eq('id_usuario', userId)
        .order('fecha_registro', ascending: false);

    final list = (resp as List).cast<Map<String, dynamic>>();

    final normalized = list.map((row) {
      final ubic = (row['id_ubicacion'] as Map).cast<String, dynamic>();
      final id = ubic['id_ubicacion'];
      int? idInt;
      if (id is int) {
        idInt = id;
      } else if (id is String) {
        idInt = int.tryParse(id);
      }
      else if (id is num) {
        idInt = id.toInt();
      }
      return {
        'id_ubicacion': idInt,
        'nombre': ubic['nombre'],
        'latitud': ubic['latitud'],
        'longitud': ubic['longitud'],
        'fecha_registro': row['fecha_registro'],
      };
    }).toList();

    return normalized;
  }
}
