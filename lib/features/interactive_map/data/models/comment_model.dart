class Comment {
  final int id;
  final int spotId;
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.spotId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap({bool includeTimestamp = false}) {
    final map = {
      'id_spot': spotId,
      'id_usuario': userId,
      'texto': text,
    };
    if (includeTimestamp) {
      map['created_at'] = createdAt.toUtc().toIso8601String();
    }
    return map;
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    final rawDate = map['created_at'] ?? map['fecha_comentario'];
    DateTime created;
    if (rawDate == null) {
      created = DateTime.now();
    } else {
      if (rawDate is String) {
        created = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        try {
          created = rawDate is DateTime ? rawDate : DateTime.parse(rawDate.toString());
        } catch (_) {
          created = DateTime.now();
        }
      }
    }

    final idVal = map['id_comentario'] ?? map['id'];
    return Comment(
      id: (idVal is int) ? idVal : int.parse(idVal.toString()),
      spotId: (map['id_spot'] is int) ? map['id_spot'] as int : int.parse(map['id_spot'].toString()),
      userId: map['id_usuario']?.toString() ?? '',
      text: map['texto']?.toString() ?? '',
      createdAt: created.toLocal(),
    );
  }
}
