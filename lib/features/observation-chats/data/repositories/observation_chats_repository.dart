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
}