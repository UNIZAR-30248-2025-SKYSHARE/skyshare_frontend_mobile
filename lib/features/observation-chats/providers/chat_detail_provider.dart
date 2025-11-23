import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/e2ee_group_service.dart';
import 'package:skyshare_frontend_mobile/features/observation-chats/service/key_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/chat_message_model.dart';
import '../data/repositories/observation_chats_repository.dart';

class ChatDetailProvider extends ChangeNotifier {
  final ObservationChatsRepository _repository;
  final SupabaseClient _supabaseClient;
  final E2EGroupService _e2eService;
  final KeyManager _keyManager;
  final int _groupId;
  final String _myUserId;

  late final RealtimeChannel _channel;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  final Set<BigInt> _undecipherableMessageIds = {};
  bool get hasUndecipherableMessages => _undecipherableMessageIds.isNotEmpty;

  ChatDetailProvider({
    required ObservationChatsRepository repository,
    required SupabaseClient supabaseClient,
    required E2EGroupService e2eService,
    required KeyManager keyManager,
    required int groupId,
  })  : _repository = repository,
        _supabaseClient = supabaseClient,
        _e2eService = e2eService,
        _keyManager = keyManager,
        _groupId = groupId,
        _myUserId = supabaseClient.auth.currentUser!.id {
    _initialize();
  }

  Set<BigInt> get undecipherableMessageIds => _undecipherableMessageIds;

  Future<void> _initialize() async {
    await _keyManager.initDeviceBundleIfNeeded();
    await _fetchMessages();
    _setupRealtimeSubscription();
    _setupKeyDistributionSubscription();
  }

  Future<String> _fetchSenderName(String senderId) async {
    if (senderId == _myUserId) return "Yo";
    
    try {
      final userResp = await _supabaseClient
          .from('usuario') 
          .select('nombre_usuario') 
          .eq('id_usuario', senderId)
          .maybeSingle();
      
      if (userResp != null) {
        return userResp['nombre_usuario'] ?? 'Usuario';
      }
    } catch (e) {
      debugPrint("Error RLS/Tabla al buscar perfil: $e");
    }
    return 'Usuario Desconocido';
  }

  Future<void> _fetchMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawMessages = await _repository.getMessages(_groupId);

      _messages = [];
      _undecipherableMessageIds.clear();

      for (final msg in rawMessages) {
        if (msg.isEncrypted == true) {
          final decrypted = await _e2eService.decryptGroupMessageRow(msg.toJson());
          if (decrypted != null) {
            msg.texto = decrypted;
          } else {
            msg.texto = "[Mensaje cifrado]";
            _undecipherableMessageIds.add(msg.id);
          }
        }
        msg.isMe = (msg.idUsuario == _myUserId);
        _messages.add(msg);
      }
      
      _messages = _messages.reversed.toList();

    } catch (e) {
      debugPrint("Error fatal al cargar mensajes: $e");
      _messages = [];
      _undecipherableMessageIds.clear();
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
          callback: (payload) async {
            final newJson = payload.newRecord;
            if (newJson.isEmpty) return;

            final senderId = newJson['id_usuario'];

            if (senderId == _myUserId) {
              return;
            }

            try {
              final msg = ChatMessage.fromJson(newJson);

              msg.nombreUsuario = await _fetchSenderName(senderId);

              if (msg.isEncrypted == true) {
                final decrypted = await _e2eService.decryptGroupMessageRow(newJson);
                if (decrypted != null) {
                  msg.texto = decrypted;
                  _undecipherableMessageIds.remove(msg.id);
                } else {
                  msg.texto = "[Mensaje cifrado]";
                  _undecipherableMessageIds.add(msg.id);
                }
              }
              msg.isMe = (msg.idUsuario == _myUserId);
              _messages.insert(0, msg); 
              notifyListeners();
            } catch (e) {
              await _fetchMessages();
            }
          },
        )
        .subscribe();
  }

  void _setupKeyDistributionSubscription() {
    final myDeviceIdFuture = _keyManager.getDeviceId();
    myDeviceIdFuture.then((myDeviceId) {
      final channelName = 'key_dist_${_groupId}_$myDeviceId';
      _supabaseClient
          .channel(channelName)
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'group_key_distribution',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'recipient_device',
              value: myDeviceId,
            ),
            callback: (payload) async {
              final newRec = payload.newRecord;
              if (newRec.isEmpty) return;
              try {
                await _fetchMessages();
              } catch (e) {
                debugPrint('Error al procesar distribucion de key: $e');
              }
            },
          )
          .subscribe();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final tempMessage = ChatMessage(
      id: BigInt.from(DateTime.now().millisecondsSinceEpoch * -1),
      createdAt: DateTime.now(),
      idUsuario: _myUserId,
      texto: text.trim(),
      nombreUsuario: "Yo",
      isMe: true,
    );

    _messages.insert(0, tempMessage);
    notifyListeners();

    try {
      final senderKeyId = await _e2eService.ensureSenderKeyForGroup(_groupId);
      final ciphertext = await _e2eService.encryptGroupMessage(_groupId, text.trim());  
      final myDeviceId = await _keyManager.getDeviceId();
      await _repository.sendMessageEncrypted(_groupId, ciphertext, senderDeviceId: myDeviceId, senderKeyId: senderKeyId);
    } catch (e) {
      debugPrint('Error enviando mensaje cifrado: $e');
    }
  }

  Future<void> retryDecryptPending() async {
    final pendingIds = _undecipherableMessageIds.toList();
    if (pendingIds.isEmpty) return;

    await _fetchMessages();
  }

  @override
  void dispose() {
    try {
      _supabaseClient.removeChannel(_channel);
    } catch (_) {}
    super.dispose();
  }
}