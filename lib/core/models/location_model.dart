class Location {
  final int id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const Location({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: (map['id_ubicacion'] ?? map['id'] ?? map['idLocation']) as int,
      name: (map['nombre'] ?? map['name']) as String,
      country: (map['pais'] ?? map['country']) as String,
      latitude: (map['latitud'] as num).toDouble(),
      longitude: (map['longitud'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_ubicacion': id,
      'nombre': name,
      'pais': country,
      'latitud': latitude,
      'longitud': longitude,
    };
  }
}
