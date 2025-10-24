import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/comment_model.dart';

class ComentarioRepository {
  final SupabaseClient client;

  ComentarioRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<List<Comment>> fetchForSpot(int spotId) async {
    final resp = await client
        .from('comentario')
        .select('id_comentario, id_spot, id_usuario, texto, fecha_comentario')
        .eq('id_spot', spotId)
        .order('fecha_comentario', ascending: false);

    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e)).toList();
    return rows.map(Comment.fromMap).toList();
  }

  Future<bool> insertComentario(Comment comentario) async {
    final resp = await client.from('comentario').insert([comentario.toMap()]).select();
    return resp.isNotEmpty;
  }
}
