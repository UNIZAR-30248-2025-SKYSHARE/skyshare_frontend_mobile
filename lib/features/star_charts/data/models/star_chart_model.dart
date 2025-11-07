class StarChartModel {
  final String imageUrl;
  final bool cached;
  final String cachedKey;
  final DateTime expiresAt;
  final DateTime generatedAt;

  StarChartModel({
    required this.imageUrl,
    required this.cached,
    required this.cachedKey,
    required this.expiresAt,
    required this.generatedAt,
  });

  factory StarChartModel.fromJson(Map<String, dynamic> json) {
    return StarChartModel(
      imageUrl: json['imageUrl'],
      cached: json['cached'] ?? false,
      cachedKey: json['cachedKey'],
      expiresAt: DateTime.parse(json['expiresAt']),
      generatedAt: DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}