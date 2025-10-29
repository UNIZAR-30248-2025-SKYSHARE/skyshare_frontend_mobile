import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class ComentarioRepository {
  final SupabaseClient client;

  ComentarioRepository({required this.client});

  Future<List<Comment>> fetchForSpot(int spotId, {int? limit, int? offset}) async {
    var query = client
        .from('comentario')
        .select('id_comentario, id_spot, id_usuario, texto, created_at')
        .eq('id_spot', spotId)
        .order('created_at', ascending: false); 

    if (limit != null) query = query.range(offset ?? 0, (offset ?? 0) + limit - 1);

    final resp = await query;
    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e)).toList();
    return rows.map(Comment.fromMap).toList();
  }

  Future<bool> insertComentario(Comment comentario, {bool useServerTimestamp = true}) async {
    final map = comentario.toMap(includeTimestamp: !useServerTimestamp);
    final resp = await client.from('comentario').insert([map]).select();
    return (resp as List).isNotEmpty;
  }

  Future<bool> deleteComentario(int comentarioId) async {
    try {
      final resp = await client
          .from('comentario')
          .delete()
          .eq('id_comentario', comentarioId)
          .select();
      return (resp as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> fetchUserNames(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    
    final resp = await client
        .from('usuario')
        .select('id_usuario, nombre_usuario')
        .inFilter('id_usuario', userIds);

    final rows = (resp as List).map((e) => Map<String, dynamic>.from(e)).toList();
    final Map<String, String> names = {};
    
    for (final r in rows) {
      final id = r['id_usuario']?.toString() ?? '';
      final nombre = r['nombre_usuario']?.toString() ?? '';
      if (id.isNotEmpty) names[id] = nombre;
    }
    
    return names;
  }
}
