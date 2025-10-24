class Comment {
  final int id; 
  final int spotId; 
  final int userId; 
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
      'fecha_comentario': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id_comentario'],
      spotId: map['id_spot'],
      userId: map['id_usuario'],
      text: map['texto'],
      createdAt: DateTime.parse(map['fecha_comentario']),
    );
  }
}
