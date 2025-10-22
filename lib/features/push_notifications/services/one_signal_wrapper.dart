import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Interfaz que define las operaciones del SDK de OneSignal que usamos.
abstract class IOneSignalWrapper {
  void initialize(String appId);
  void setLogLevel(OSLogLevel level);
  String? getPlayerId();
  Future<bool> requestPermission();
  void addPushSubscriptionObserver(void Function(OSPushSubscriptionChangedState) observer);
}

/// Implementación real del wrapper, que delega en el SDK de OneSignal.
class OneSignalWrapper implements IOneSignalWrapper {
  @override
  void initialize(String appId) => OneSignal.initialize(appId);

  @override
  void setLogLevel(OSLogLevel level) => OneSignal.Debug.setLogLevel(level);

  @override
  String? getPlayerId() => OneSignal.User.pushSubscription.id;

  @override
  Future<bool> requestPermission() async =>
      await OneSignal.Notifications.requestPermission(true);

  @override
  void addPushSubscriptionObserver(
      void Function(OSPushSubscriptionChangedState) observer) {
    OneSignal.User.pushSubscription.addObserver(observer);
  }
}