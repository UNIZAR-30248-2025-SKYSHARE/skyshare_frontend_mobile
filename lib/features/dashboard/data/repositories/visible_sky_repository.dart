import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/cielo_visible_model.dart';

class VisibleSkyRepository {
  final SupabaseClient client;

  VisibleSkyRepository({SupabaseClient? client}) : client = client ?? SupabaseService.instance.client;

  Future<List<Constellation>> fetchLatestForLocation(int locationId, {int limit = 50}) async {
    final resp = await client
        .from('cielo_visible')
        .select()
        .eq('id_ubicacion', locationId)
        .order('fecha_hora', ascending: false)
        .limit(limit);
    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return rows.map(Constellation.fromMap).toList();
  }

  Future<bool> insertVisible(Constellation c) async {
    final resp = await client.from('cielo_visible').insert([c.toMap()]);
    return resp != null;
  }
}
