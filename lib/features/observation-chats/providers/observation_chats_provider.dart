import 'package:flutter/material.dart';
import '../data/models/chat_preview_model.dart';
import '../data/models/group_info_model.dart'; 
import '../data/repositories/observation_chats_repository.dart';

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

  Future<bool> createGroup(String name, String description) async {
    try {
      await _repository.createGroup(name, description);
      
      _groupChats = []; 
      
      await fetchMyGroups(); 
      
      _currentFilter = ChatFilter.misGrupos;
      
      notifyListeners(); 
      return true;

    } catch (e) {
      print('Error creando grupo: $e');
      return false;
    }
  }

  Future<bool> joinGroup(int groupId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.joinGroup(groupId);
      
      _groupChats = [];
      _discoverableGroups = [];
      await fetchMyGroups(); 

      _currentFilter = ChatFilter.misGrupos;
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      print('Error al unirse al grupo: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}