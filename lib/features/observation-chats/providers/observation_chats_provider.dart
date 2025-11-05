import 'package:flutter/material.dart';
import '../data/models/chat_preview_model.dart';
import '../data/models/group_info_model.dart'; 
import '../data/repositories/observation_chats_repository.dart';

// Enum para saber qué filtro está activo
enum ChatFilter { misGrupos, todos }

class ObservationChatsProvider extends ChangeNotifier {
  final ObservationChatsRepository _repository;

  ObservationChatsProvider(this._repository) {
    fetchMyGroups();
  }

  ChatFilter _currentFilter = ChatFilter.misGrupos;
  ChatFilter get currentFilter => _currentFilter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ChatPreview> _groupChats = [];
  List<ChatPreview> get groupChats => _groupChats; 

  List<GroupInfo> _discoverableGroups = [];
  List<GroupInfo> get discoverableGroups => _discoverableGroups;

  Future<void> setFilter(ChatFilter filter) async {
    if (_currentFilter == filter) return; 

    _currentFilter = filter;
    _isLoading = true;
    notifyListeners();

    try {
      switch (filter) {
        case ChatFilter.misGrupos:
          await fetchMyGroups();
          break;
        case ChatFilter.todos:
          await fetchDiscoverableGroups();
          break;
      }
    } catch (e) {
      print("Error al cambiar de filtro: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyGroups() async {
    if (_groupChats.isEmpty) { 
      _groupChats = await _repository.getMyGroupPreviews();
    }
  }

  Future<void> fetchDiscoverableGroups() async {
    if (_discoverableGroups.isEmpty) {
      _discoverableGroups = await _repository.getDiscoverableGroups();
    }
  }
}