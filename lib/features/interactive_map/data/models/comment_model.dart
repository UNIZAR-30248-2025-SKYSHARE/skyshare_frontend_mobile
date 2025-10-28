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

  Map<String, dynamic> toMap() {
    return {
      'id_spot': spotId,
      'id_usuario': userId,
      'texto': text,
      'fecha_comentario': createdAt.toIso8601String().split('T').first,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    DateTime created;
    try {
      created = DateTime.parse(map['fecha_comentario'].toString());
    } catch (_) {
      created = DateTime.now();
    }
    return Comment(
      id: (map['id_comentario'] is int) ? map['id_comentario'] as int : int.parse(map['id_comentario'].toString()),
      spotId: (map['id_spot'] is int) ? map['id_spot'] as int : int.parse(map['id_spot'].toString()),
      userId: map['id_usuario']?.toString() ?? '',
      text: map['texto']?.toString() ?? '',
      createdAt: created,
    );
  }
}
