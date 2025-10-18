// lib/features/push_notifications/data/services/one_signal_service.dart
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/notification_repository.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;

  OneSignalService._internal();

  bool _initialized = false;

  /// Inicializa el SDK de OneSignal (SDK 5.x)
  Future<void> init() async {
    if (_initialized) return;

    final appId = dotenv.env['ONESIGNAL_APP_ID'];
    if (appId == null || appId.isEmpty) {
      print('[OneSignal] ERROR: ONESIGNAL_APP_ID no está definido en .env');
      return;
    }

    try {
      print('[OneSignal] Initializing SDK with appId=$appId');
      
      // Nivel de logs (opcional)
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      
      // Inicializa OneSignal (v5)
      OneSignal.initialize(appId);
      
      print('[OneSignal] Initialized OK');

      // Observer v5: escuchar cambios en la suscripción push (playerId/token/optedIn)
      OneSignal.User.pushSubscription.addObserver((OSPushSubscriptionChangedState state) {
        try {
          final current = state.current;
          final previous = state.previous;
          final id = current.id;
          final token = current.token;
          final optedIn = current.optedIn;

          final tokenShort = token == null
              ? 'null'
              : (token.length > 8 ? token.substring(0, 8) + '…' : token);
          print('[OneSignal] pushSubscription changed:'
              ' id=$id token=$tokenShort optedIn=$optedIn'
              ' (prevId=${previous.id} prevOptedIn=${previous.optedIn})');

          if (id != null && id.isNotEmpty) {
            print('[OneSignal] PlayerId available: $id');
          }
        } catch (e, st) {
          print('[OneSignal] pushSubscription observer ERROR: $e\n$st');
        }
      });
      
      _initialized = true;
    } catch (e, st) {
      print('[OneSignal] Initialize ERROR: $e\n$st');
      rethrow;
    }
  }

  /// Pide permiso al usuario para recibir notificaciones (opcional en Android)
  Future<void> requestPermission() async {
    try {
      print('[OneSignal] Requesting push permission...');
      final accepted = await OneSignal.Notifications.requestPermission(true);
      print('[OneSignal] Permission granted? $accepted');
    } catch (e, st) {
      print('[OneSignal] Request permission ERROR: $e\n$st');
    }
  }

  /// Devuelve el playerId del dispositivo
  Future<String?> getPlayerId() async {
    try {
      final id = OneSignal.User.pushSubscription.id;
      print('[OneSignal] Current playerId: $id');
      return id;
    } catch (e, st) {
      print('[OneSignal] Get playerId ERROR: $e\n$st');
      return null;
    }
  }

  /// Envía el playerId a Supabase
  Future<void> sendPlayerId(SupabaseClient client, String userId) async {
    try {
      final playerId = await getPlayerId();
      if (playerId == null || playerId.isEmpty) {
        print('[OneSignal] sendPlayerId skipped: playerId is null/empty');
        return;
      }
      print('[OneSignal] Sending playerId to Supabase. userId=$userId, playerId=$playerId');
      await NotificationRepository(client: client).updatePlayerId(
        userId: userId,
        playerId: playerId,
      );
      print('[OneSignal] playerId sent to Supabase OK');
    } catch (e, st) {
      print('[OneSignal] sendPlayerId ERROR: $e\n$st');
    }
  }
}
