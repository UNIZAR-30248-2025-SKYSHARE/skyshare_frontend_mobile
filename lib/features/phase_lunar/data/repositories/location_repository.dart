import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class LocationRepository {
  final SupabaseClient client;

  LocationRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<int?> getCurrentLocationId({String? userId}) async {
    final uid = userId ?? client.auth.currentUser?.id;
    if (uid == null) return null;

    final resp = await client
        .from('usuarioubicacion')
        .select('id_ubicacion, fecha_registro')
        .eq('id_usuario', uid)
        .order('fecha_registro', ascending: false)
        .limit(1)
        .maybeSingle();

    if (resp == null) return null;

    final map = Map<String, dynamic>.from(resp as Map);
    final idField = map['id_ubicacion'];
    if (idField == null) return null;
    if (idField is int) return idField;
    if (idField is String) return int.tryParse(idField);
    if (idField is num) return idField.toInt();
    return null;
  }

  Future<List<Map<String, dynamic>>> getSavedLocations({String? userId}) async {
    final uid = userId ?? client.auth.currentUser?.id;
    if (uid == null) return [];

    final resp = await client
        .from('usuarioubicacion')
        .select('''
          id_ubicacion,
          ubicacion:id_ubicacion(id_ubicacion, nombre, latitud, longitud, pais)
        ''')
        .eq('id_usuario', uid)
        .order('fecha_registro', ascending: false);

    final list = (resp as List).cast<Map<String, dynamic>>();

    final normalized = list.map((row) {
      final ubicacionData = row['ubicacion'] as Map<String, dynamic>?;
      if (ubicacionData == null) return null;
      
      final id = ubicacionData['id_ubicacion'];
      int? idInt;
      if (id is int) {
        idInt = id;
      } else if (id is String) {
        idInt = int.tryParse(id);
      } else if (id is num) {
        idInt = id.toInt();
      }
      
      return {
        'id_ubicacion': idInt,
        'nombre': ubicacionData['nombre'],
        'latitud': ubicacionData['latitud'],
        'longitud': ubicacionData['longitud'],
        'pais': ubicacionData['pais'],
        'fecha_registro': row['fecha_registro'],
      };
    }).where((item) => item != null).cast<Map<String, dynamic>>().toList();

    return normalized;
  }
}