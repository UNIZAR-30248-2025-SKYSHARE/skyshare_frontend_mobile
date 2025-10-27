import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/notification_repository.dart';
import 'one_signal_wrapper.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService({IOneSignalWrapper? wrapper}) {
    _instance._wrapper = wrapper ?? OneSignalWrapper();
    return _instance;
  }

  OneSignalService._internal();

  late IOneSignalWrapper _wrapper;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final appId = dotenv.env['ONESIGNAL_APP_ID'];
    if (appId == null || appId.isEmpty) {
      if (kDebugMode) {
        print('[OneSignal] ERROR: ONESIGNAL_APP_ID no está definido en .env');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('[OneSignal] Initializing SDK with appId=$appId');
      }
      _wrapper.setLogLevel(OSLogLevel.verbose);
      _wrapper.initialize(appId);
      if (kDebugMode) {
        print('[OneSignal] Initialized OK');
      }

      _wrapper.addPushSubscriptionObserver((OSPushSubscriptionChangedState state) {
        try {
          final current = state.current;
          final previous = state.previous;
          final id = current.id;
          final token = current.token;
          final optedIn = current.optedIn;

          final tokenShort = token == null
              ? 'null'
              : (token.length > 8 ? '${token.substring(0, 8)}…' : token);
          if (kDebugMode) {
            print('[OneSignal] pushSubscription changed:'
              ' id=$id token=$tokenShort optedIn=$optedIn'
              ' (prevId=${previous.id} prevOptedIn=${previous.optedIn})');
          }

          if (id != null && id.isNotEmpty) {
            if (kDebugMode) {
              print('[OneSignal] PlayerId available: $id');
            }
          }
        } catch (e, st) {
          if (kDebugMode) {
            print('[OneSignal] pushSubscription observer ERROR: $e\n$st');
          }
        }
      });

      _initialized = true;
    } catch (e, st) {
      if (kDebugMode) {
        print('[OneSignal] Initialize ERROR: $e\n$st');
      }
      rethrow;
    }
  }

  Future<void> requestPermission() async {
    try {
      if (kDebugMode) {
        print('[OneSignal] Requesting push permission...');
      }
      final accepted = await _wrapper.requestPermission();
      if (kDebugMode) {
        print('[OneSignal] Permission granted? $accepted');
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('[OneSignal] Request permission ERROR: $e\n$st');
      }
    }
  }

  Future<String?> getPlayerId() async {
    try {
      final id = _wrapper.getPlayerId();

      if (kDebugMode) {
        print('[OneSignal] Current playerId: $id');
      }
      return id;
    } catch (e, st) {
      if (kDebugMode) {
        print('[OneSignal] Get playerId ERROR: $e\n$st');
      }
      return null;
    }
  }

  Future<void> sendPlayerId(SupabaseClient client, String userId) async {
    try {
      final playerId = await getPlayerId();
      if (playerId == null || playerId.isEmpty) {
        if (kDebugMode) {
          print('[OneSignal] sendPlayerId skipped: playerId is null/empty');
        }
        return;
      }

      if (kDebugMode) {
        print('[OneSignal] Sending playerId to Supabase. userId=$userId, playerId=$playerId');
      }
      await NotificationRepository(client: client).updatePlayerId(
        userId: userId,
        playerId: playerId,
      );

      if (kDebugMode) {
        print('[OneSignal] playerId sent to Supabase OK');
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('[OneSignal] sendPlayerId ERROR: $e\n$st');
      }
    }
  }
}
