import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/rating_model.dart';

class RatingRepository {
  final SupabaseClient client;

  RatingRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<List<Rating>> fetchForSpot(int spotId) async {
    final resp = await client
        .from('valoracion') 
        .select('id_spot, id_usuario, puntuacion, fecha_valoracion')
        .eq('id_spot', spotId)
        .order('fecha_valoracion', ascending: false);

    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e)).toList();
    return rows.map(Rating.fromMap).toList();
  }

  Future<bool> insertRating(Rating rating) async {
    try {
      final resp = await client
          .from('valoracion')
          .upsert(
            rating.toMap(),
            onConflict: 'id_spot,id_usuario', 
          )
          .select();

      return resp.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error al insertar/actualizar valoración: $e');
      }
      return false;
    }
  }

  Future<double?> fetchAverageRating(int spotId) async {
    final resp = await client.rpc('average_rating', params: {'spot_id': spotId});
    if (resp == null || (resp as List).isEmpty) return null;

    return (resp[0]['avg'] as num?)?.toDouble();
  }

  Future<int?> fetchUserRating(int spotId, String userId) async {
    final resp = await client
        .from('valoracion')
        .select('puntuacion')
        .eq('id_spot', spotId)
        .eq('id_usuario', userId)
        .order('fecha_valoracion', ascending: false)
        .limit(1);
    final rows = resp as List;
    if (rows.isEmpty) return null;
    final row = Map<String, dynamic>.from(rows[0]);
    final val = row['puntuacion'];
    if (val == null) return null;
    return (val as num).toInt();
  }
}