import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/observation_chats_provider.dart';
import 'widgets/chat_list_item.dart'; 
import '../data/models/group_info_model.dart'; 
import 'widgets/create_group_bottom_sheet.dart'; 
import 'chat_detail_screen.dart';
import '../providers/chat_detail_provider.dart';
import '../data/repositories/observation_chats_repository.dart';

class ObservationChatsScreen extends StatelessWidget {
  const ObservationChatsScreen({Key? key}) : super(key: key);

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
        return CreateGroupBottomSheet(); 
      },
    );
  }

  void _showJoinGroupDialog(BuildContext context, GroupInfo groupInfo) {
    final providerActions = context.read<ObservationChatsProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3D),
        title: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Quieres unirte al grupo "${groupInfo.nombre}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4D9C),
            ),
            child: const Text('Unirme', style: TextStyle(color: Colors.white)),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats & Grupos", style: TextStyle(color: Colors.white)),
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
                hintText: "Buscar chats o grupos...",
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
                label: const Text("Mis Grupos"),
                backgroundColor: provider.currentFilter == ChatFilter.misGrupos
                    ? const Color(0xFF6A4D9C) 
                    : const Color(0xFF3A2D4C), 
                onPressed: () => providerActions.setFilter(ChatFilter.misGrupos),
              ),
              ActionChip(
                label: const Text("Buscar Grupos"), 
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
    switch (provider.currentFilter) {
      
      case ChatFilter.misGrupos:
        if (provider.groupChats.isEmpty) {
          return const Center(child: Text("No estás en ningún grupo.", style: TextStyle(color: Colors.white70)));
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
          return const Center(child: Text("No hay grupos para descubrir.", style: TextStyle(color: Colors.white70)));
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
                subtitle: Text(groupInfo.descripcion ?? "Sin descripción", style: const TextStyle(color: Colors.white70)),
                trailing: ElevatedButton(
                  child: const Text("Unirse"),
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