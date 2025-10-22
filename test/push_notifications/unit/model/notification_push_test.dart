import 'package:flutter_test/flutter_test.dart';
import 'package:skyshare_frontend_mobile/features/push_notifications/data/model/notification_model.dart';

void main() {
  group('NotificationData', () {
    test('toJson y fromJson funcionan con playerId y userId', () {
      final json = {
        'player_id': 'player-123',
        'user_id': 'user-abc',
      };

      final model = NotificationData.fromJson(json);

      expect(model.playerId, 'player-123');
      expect(model.userId, 'user-abc');

      final out = model.toJson();
      expect(out['player_id'], 'player-123');
      expect(out['user_id'], 'user-abc');
    });
  });
}
