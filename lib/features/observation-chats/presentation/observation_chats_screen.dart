import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/e2ee_group_service.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/key_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/observation_chats_provider.dart';
import 'widgets/chat_list_item.dart';
import '../data/models/group_info_model.dart';
import 'widgets/create_group_bottom_sheet.dart';
import 'chat_detail_screen.dart';
import '../providers/chat_detail_provider.dart';
import '../data/repositories/observation_chats_repository.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';

class ObservationChatsScreen extends StatelessWidget {
  const ObservationChatsScreen({super.key});

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return const CreateGroupBottomSheet();
      },
    );
  }

  void _showJoinGroupDialog(BuildContext context, GroupInfo groupInfo) {
    final providerActions = context.read<ObservationChatsProvider>();
    final localizations = AppLocalizations.of(context)!;
    
    final joinMessage = localizations.t(
      'chat.join_group_message', 
      {'name': groupInfo.nombre}
    );
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3D),
        title: Text(localizations.t('chat.confirm_title'), style: const TextStyle(color: Colors.white)),
        content: Text(
          joinMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: Text(localizations.t('cancel'), style: const TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4D9C),
            ),
            child: Text(localizations.t('chat.join_button'), style: const TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(ctx).pop();
              providerActions.joinGroup(groupInfo.idGrupo);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ObservationChatsProvider>();
    final providerActions = context.read<ObservationChatsProvider>();
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.t('chat.title'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30, color: Colors.white),
            onPressed: () {
              _showCreateGroupSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: localizations.t('chat.search_hint'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF2A2A3D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionChip(
                label: Text(localizations.t('chat.my_groups')),
                backgroundColor: provider.currentFilter == ChatFilter.misGrupos
                    ? const Color(0xFF6A4D9C)
                    : const Color(0xFF3A2D4C),
                onPressed: () => providerActions.setFilter(ChatFilter.misGrupos),
              ),
              ActionChip(
                label: Text(localizations.t('chat.discover_groups')),
                backgroundColor: provider.currentFilter == ChatFilter.todos
                    ? const Color(0xFF6A4D9C)
                    : const Color(0xFF3A2D4C),
                onPressed: () => providerActions.setFilter(ChatFilter.todos),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFilteredList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList(BuildContext context, ObservationChatsProvider provider) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (provider.currentFilter) {
     
      case ChatFilter.misGrupos:
        if (provider.groupChats.isEmpty) {
          return Center(child: Text(localizations.t('chat.no_my_groups'), style: const TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          itemCount: provider.groupChats.length,
          itemBuilder: (context, index) {
            final chat = provider.groupChats[index];
           
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => ChatDetailProvider(
                        repository: context.read<ObservationChatsRepository>(),
                        supabaseClient: context.read<SupabaseClient>(),
                        e2eService: context.read<E2EGroupService>(),
                        keyManager: context.read<KeyManager>(),
                        groupId: chat.idGrupo,
                      ),
                      child: ChatDetailScreen(
                        groupName: chat.nombreGrupo,
                      ),
                    ),
                  ),
                );
              },
              child: ChatListItem(key: ValueKey(chat.idGrupo), chat: chat),
            );
          },
        );

      case ChatFilter.todos:
        if (provider.discoverableGroups.isEmpty) {
          return Center(child: Text(localizations.t('chat.no_discover_groups'), style: const TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          itemCount: provider.discoverableGroups.length,
          itemBuilder: (context, index) {
            final GroupInfo groupInfo = provider.discoverableGroups[index];
            return Card(
              color: const Color(0xFF3A2D4C),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.public, color: Colors.white70),
                title: Text(groupInfo.nombre, style: const TextStyle(color: Colors.white)),
                subtitle: Text(groupInfo.descripcion ?? localizations.t('spot.no_description'), style: const TextStyle(color: Colors.white70)),
                trailing: ElevatedButton(
                  child: Text(localizations.t('chat.join_button')),
                  onPressed: () {
                    _showJoinGroupDialog(context, groupInfo);
                  },
                ),
              ),
            );
          },
        );
    }
  }
}