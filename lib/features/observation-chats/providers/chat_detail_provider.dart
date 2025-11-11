import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/chat_message_model.dart';
import '../data/repositories/observation_chats_repository.dart';

class ChatDetailProvider extends ChangeNotifier {
  final ObservationChatsRepository _repository;
  final SupabaseClient _supabaseClient;
  final int _groupId;
  final String _myUserId;

  late final RealtimeChannel _channel;

  ChatDetailProvider({
    required ObservationChatsRepository repository,
    required SupabaseClient supabaseClient,
    required int groupId,
  })  : _repository = repository,
        _supabaseClient = supabaseClient,
        _groupId = groupId,
        _myUserId = supabaseClient.auth.currentUser!.id {
    _initialize();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  Future<void> _initialize() async {
    await _fetchMessages();
    _setupRealtimeSubscription();
  }

  Future<void> _fetchMessages() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final messages = await _repository.getMessages(_groupId);
      
      _messages = messages.map((msg) {
        msg.isMe = (msg.idUsuario == _myUserId);
        return msg;
      }).toList();

    } catch (e) {
      // ignore: avoid_print
      print("Error fatal al cargar mensajes: $e");
      _messages = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void _setupRealtimeSubscription() {
    
    String channelName = 'chat_group_$_groupId';
    
    _channel = _supabaseClient
        .channel(channelName) 
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mensajes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id_grupo',
            value: _groupId,
          ),
          callback: (payload) {
            final newJson = payload.newRecord; 
            if (newJson.isEmpty) return;

            final senderId = newJson['id_usuario'];

            if (senderId == _myUserId) {
              return; 
            }

            _fetchMessages();
          },
        )
        .subscribe();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final tempMessage = ChatMessage(

      id: BigInt.from(DateTime.now().millisecondsSinceEpoch * -1), 
      createdAt: DateTime.now(),
      idUsuario: _myUserId,
      texto: text.trim(),
      nombreUsuario: "", 
      isMe: true,
    );

    _messages.add(tempMessage);

    notifyListeners();

    try {
      await _repository.sendMessage(_groupId, text.trim());
      
    } catch (e) {
      // ignore: avoid_print
      print('Error enviando mensaje: $e');
    }
  }

  @override
  void dispose() {
    _supabaseClient.removeChannel(_channel);
    super.dispose();
  }
}
