import 'package:skyshare_frontend_mobile/features/observation-chats/data/models/chat_message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_preview_model.dart';
import '../models/group_info_model.dart';

class ObservationChatsRepository {
  final SupabaseClient _supabaseClient;

  ObservationChatsRepository(this._supabaseClient);

  Future<List<ChatPreview>> getMyGroupPreviews() async {
    final response = await _supabaseClient.rpc('get_my_group_previews');
    if (response is List) {
      return response
          .map((item) => ChatPreview.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<GroupInfo>> getDiscoverableGroups() async {
    final response = await _supabaseClient.rpc('get_discoverable_groups');
    if (response is List) {
      return response
          .map((item) => GroupInfo.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<int> createGroup(String name, String description) async {
    final response = await _supabaseClient.rpc(
      'create_and_join_group',
      params: {
        'group_name': name,
        'group_description': description,
      },
    );
    return response as int;
  }

  Future<void> joinGroup(int groupId) async {
    await _supabaseClient.rpc(
      'join_group',
      params: {'group_id': groupId},
    );
  }

  Future<List<ChatMessage>> getMessages(int groupId) async {
    final response = await _supabaseClient.rpc(
      'get_messages_for_group',
      params: {'p_group_id': groupId},
    );

    if (response is List) {
      return response
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> sendMessageEncrypted(int groupId, String ciphertext, {required String senderDeviceId, required String senderKeyId}) async {
    final myUserId = _supabaseClient.auth.currentUser!.id;

    await _supabaseClient.from('mensajes').insert({
      'id_grupo': groupId,
      'id_usuario': myUserId,
      'ciphertext': ciphertext,
      'is_encrypted': true,
      'sender_device': senderDeviceId,
      'sender_key_id': senderKeyId,
    });
  }

  /// Legacy
  Future<void> sendMessage(int groupId, String text) async {
    final myUserId = _supabaseClient.auth.currentUser!.id;

    await _supabaseClient.from('mensajes').insert({
      'id_grupo': groupId,
      'id_usuario': myUserId,
      'texto': text,
    });
  }
}
