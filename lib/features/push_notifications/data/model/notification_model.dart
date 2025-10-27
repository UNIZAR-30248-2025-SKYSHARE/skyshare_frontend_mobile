class NotificationData {
  final String playerId;
  final String? userId;

  NotificationData({
    required this.playerId,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'player_id': playerId,
        if (userId != null) 'user_id': userId,
      };

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      playerId: json['player_id'] as String,
      userId: json['user_id'] as String?,
    );
  }
}