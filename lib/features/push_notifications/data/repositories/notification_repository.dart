import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';

class NotificationRepository {
  final SupabaseClient client;

  NotificationRepository({SupabaseClient? client})
      : client = client ?? SupabaseService.instance.client;

  Future<void> updatePlayerId({
    required String userId,
    required String playerId,
  }) async {
    try {
      await client
          .from('usuario')
          .upsert({
            'id_usuario': userId,
            'player_id': playerId,
          }, onConflict: 'id_usuario');
    } catch (e, st) {
      print('[ERROR] No se pudo actualizar el playerId: $e\n$st');
    }
  }
}
