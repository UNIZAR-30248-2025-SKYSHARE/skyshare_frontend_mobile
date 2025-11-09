import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/supabase_service.dart';

class FollowsRepository {
  final SupabaseClient client;

  FollowsRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;


  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await client.from('usuario').select();

      if (response.isEmpty) return [];

      return (response as List)
          .map((e) => AppUser(
                id: e['id_usuario'],
                username: e['nombre_usuario'],
                email: e['email'],
                createdAt: DateTime.parse(e['created_at']),
              ))
          .toList();
    } catch (e) {
      print('Error al obtener todos los usuarios: $e');
      return [];
    }
  }

  Future<List<AppUser>> getUsuariosSeguidos(String idSeguidor) async {
    try {
      final response = await client
          .from('seguidores')
          .select('id_seguido')
          .eq('id_seguidor', idSeguidor);

      if (response.isEmpty) return [];

      final idsSeguidos =
          (response as List).map((e) => e['id_seguido'] as String).toList();

      if (idsSeguidos.isEmpty) return [];

      final usuariosResponse = await client
          .from('usuario')
          .select()
          .inFilter('id_usuario', idsSeguidos);

      if (usuariosResponse.isEmpty) return [];

      return (usuariosResponse as List)
          .map((e) => AppUser(
                id: e['id_usuario'],
                username: e['nombre_usuario'],
                email: e['email'],
                createdAt: DateTime.parse(e['created_at']),
              ))
          .toList();
    } catch (e) {
      print('Error al obtener usuarios seguidos: $e');
      return [];
    }
  }
  

  Future<List<AppUser>> getUsuariosSeguidores(String idSeguidor) async {
    try {
      final response = await client
          .from('seguidores')
          .select('id_seguidor')
          .eq('id_seguido', idSeguidor);

      if (response.isEmpty) return [];

      final idsSeguidos =
          (response as List).map((e) => e['id_seguidor'] as String).toList();

      if (idsSeguidos.isEmpty) return [];

      final usuariosResponse = await client
          .from('usuario')
          .select()
          .inFilter('id_usuario', idsSeguidos);

      if (usuariosResponse.isEmpty) return [];

      return (usuariosResponse as List)
          .map((e) => AppUser(
                id: e['id_usuario'],
                username: e['nombre_usuario'],
                email: e['email'],
                createdAt: DateTime.parse(e['created_at']),
              ))
          .toList();
    } catch (e) {
      print('Error al obtener usuarios seguidos: $e');
      return [];
    }
  }

  Future<void> followUser(String idSeguidor, String idSeguido) async {
    try {
      await client.from('seguidores').insert({
        'id_seguidor': idSeguidor,
        'id_seguido': idSeguido,
        'fecha_seguimiento': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al seguir usuario: $e');
      rethrow;
    }
  }

  Future<void> unfollowUser(String idSeguidor, String idSeguido) async {
    try {
      await client
          .from('seguidores')
          .delete()
          .eq('id_seguidor', idSeguidor)
          .eq('id_seguido', idSeguido);
    } catch (e) {
      print('Error al dejar de seguir: $e');
      rethrow;
    }
  }

  Future<bool> isFollowing(String idSeguidor, String idSeguido) async {
    try {
      final response = await client
          .from('seguidores')
          .select()
          .eq('id_seguidor', idSeguidor)
          .eq('id_seguido', idSeguido)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error al verificar si está siguiendo: $e');
      return false;
    }
  }

  


}


