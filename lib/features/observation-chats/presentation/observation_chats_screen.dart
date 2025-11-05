import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/observation_chats_provider.dart';
import 'widgets/chat_list_item.dart'; 
import '../data/models/group_info_model.dart'; // <-- AÑADIDO

class ObservationChatsScreen extends StatelessWidget {
  const ObservationChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 'watch' re-dibuja la UI cuando hay cambios
    final provider = context.watch<ObservationChatsProvider>();
    // 'read' se usa para llamar a funciones sin re-dibujar
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
              // Lógica para crear nuevo grupo
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
          
          // 2. Filtros (¡AHORA SON INTERACTIVOS!)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionChip(
                label: const Text("Mis Grupos"),
                backgroundColor: provider.currentFilter == ChatFilter.misGrupos
                    ? const Color(0xFF6A4D9C) // Color activo
                    : const Color(0xFF3A2D4C), // Color inactivo
                onPressed: () => providerActions.setFilter(ChatFilter.misGrupos),
              ),
              ActionChip(
                label: const Text("Buscar Grupos"), // Texto cambiado
                backgroundColor: provider.currentFilter == ChatFilter.todos
                    ? const Color(0xFF6A4D9C)
                    : const Color(0xFF3A2D4C),
                onPressed: () => providerActions.setFilter(ChatFilter.todos),
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // 3. Lista de Chats (¡AHORA ES DINÁMICA!)
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFilteredList(provider), // Usamos un widget helper
          ),
        ],
      ),
    );
  }

  // Widget helper para decidir qué lista mostrar
  Widget _buildFilteredList(ObservationChatsProvider provider) {
    switch (provider.currentFilter) {
      
      case ChatFilter.misGrupos:
        if (provider.groupChats.isEmpty) {
          return const Center(child: Text("No estás en ningún grupo.", style: TextStyle(color: Colors.white70)));
        }
        return ListView.builder(
          itemCount: provider.groupChats.length,
          itemBuilder: (context, index) {
            final chat = provider.groupChats[index];
            return ChatListItem(chat: chat); // Tu widget existente
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
            // Widget temporal para mostrar la info de los grupos a descubrir
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
                    // Lógica futura para unirse al grupo
                  },
                ),
              ),
            );
          },
        );
    }
  }
}