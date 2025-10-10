class Constellation {
  final int id;
  final int locationId;
  final DateTime timestamp;
  final String name;

  Constellation({
    required this.id,
    required this.locationId,
    required this.timestamp,
    required this.name,
  });

  factory Constellation.fromMap(Map<String, dynamic> map) {
    return Constellation(
      id: (map['id_cielo_visible'] ?? map['id'] ?? 0) as int,
      locationId: (map['id_ubicacion'] as int),
      timestamp: DateTime.parse((map['fecha_hora'] as String)),
      name: (map['constelacion'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cielo_visible': id,
      'id_ubicacion': locationId,
      'fecha_hora': timestamp.toIso8601String(),
      'constelacion': name,
    };
  }
}
