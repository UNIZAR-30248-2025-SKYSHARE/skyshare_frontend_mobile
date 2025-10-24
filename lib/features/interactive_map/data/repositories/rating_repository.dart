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
    final resp = await client
        .from('valoracion')
        .insert([rating.toMap()])
        .select();

    return resp.isNotEmpty;
  }

  Future<double?> fetchAverageRating(int spotId) async {
    final resp = await client.rpc('average_rating', params: {'spot_id': spotId});
    if (resp == null || (resp as List).isEmpty) return null;

    return (resp[0]['avg'] as num?)?.toDouble();
  }
}
