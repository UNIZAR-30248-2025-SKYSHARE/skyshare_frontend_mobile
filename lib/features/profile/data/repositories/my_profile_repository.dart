import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/supabase_service.dart';
import 'package:flutter/material.dart';

class MyProfileRepository {
  final SupabaseClient client;

  MyProfileRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;
  

  Future<AppUser?> getCurrentUserProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final response = await client
        .from('usuario')
        .select()
        .eq('id_usuario', user.id)
        .maybeSingle();

    if (response == null) return null;

    return AppUser(
      id: response['id_usuario'],
      username: response['nombre_usuario'],
      email: response['email'],
      photoUrl: response['url_foto'],
      createdAt: DateTime.parse(response['created_at'] ?? user.createdAt),
    );
  }

  Future<AppUser?> getUserProfileById(String userId) async {
    try {
      final response = await client
          .from('usuario')
          .select()
          .eq('id_usuario', userId)
          .maybeSingle();

      if (response == null) return null;

      return AppUser(
        id: response['id_usuario'],
        username: response['nombre_usuario'],
        email: response['email'],
        photoUrl: response['url_foto'],
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      debugPrint('❌ Error al obtener perfil de usuario por ID: $e');
      return null;
    }
  }

  Future<Map<String, int>> getFollowersData(String userId) async {
    try {
      final followersRes =
          await client.from('seguidores').select().eq('id_seguido', userId);

      final followingRes =
          await client.from('seguidores').select().eq('id_seguidor', userId);

      return {
        'followers': followersRes.length,
        'following': followingRes.length,
      };
    } catch (e) {
      debugPrint('❌ Error al contar seguidores: $e');
      return {'followers': 0, 'following': 0};
    }
  }

  Future<int> getSpotsCount(String userId) async {
    try {
      final spotsRes =
          await client.from('spot').select().eq('id_usuario_creador', userId);
      return spotsRes.length;
    } catch (e) {
      debugPrint('❌ Error al contar spots: $e');
      return 0;
    }
  }

  


}