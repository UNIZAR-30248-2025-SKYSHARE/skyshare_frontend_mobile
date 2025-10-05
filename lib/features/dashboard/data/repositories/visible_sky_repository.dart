import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/visible_sky_model.dart';

class VisibleSkyRepository {
  final SupabaseClient client;

  VisibleSkyRepository({SupabaseClient? client}) : client = client ?? SupabaseService.instance.client;

  Future<List<VisibleSkyItem>> fetchLatestForLocation(int locationId, {int limit = 50}) async {
    final resp = await client
        .from('cielo_visible')
        .select('id_cielo_visible, id_ubicacion, tipo, nombre, descripcion, ultima_actualizacion')
        .eq('id_ubicacion', locationId)
        .order('ultima_actualizacion', ascending: false)
        .limit(limit);
    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return rows.map(VisibleSkyItem.fromMap).toList();
  }

  Future<bool> insertVisible(VisibleSkyItem c) async {
    final resp = await client.from('cielo_visible').insert([c.toMap()]).select();
    if (resp.isNotEmpty) return true;
    return false;
  }
}
