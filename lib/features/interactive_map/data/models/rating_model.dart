class Rating {
  final int spotId; 
  final String userId; 
  final int value; 
  final DateTime createdAt; 

  Rating({
    required this.spotId,
    required this.userId,
    required this.value,
    required this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      spotId: map['id_spot'] as int,
      userId: map['id_usuario'] as String,
      value: map['puntuacion'] as int,
      createdAt: DateTime.parse(map['fecha_valoracion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_spot': spotId,
      'id_usuario': userId,
      'puntuacion': value,
      'fecha_valoracion': createdAt.toIso8601String(),
    };
  }
}
