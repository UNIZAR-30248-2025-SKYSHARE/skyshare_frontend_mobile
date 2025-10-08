class VisibleSkyItem {
  final int id;
  final int locationId;
  final DateTime timestamp;
  final String name;
  final String tipo;
  final String? descripcion;

  VisibleSkyItem({
    required this.id,
    required this.locationId,
    required this.timestamp,
    required this.name,
    required this.tipo,
    this.descripcion,
  });

  factory VisibleSkyItem.fromMap(Map<String, dynamic> map) {
    final dynamic idVal = map['id_cielo_visible'] ?? map['id'] ?? 0;
    final int id = idVal is int ? idVal : int.tryParse(idVal.toString()) ?? 0;

    final dynamic locVal = map['id_ubicacion'] ?? map['idUbicacion'] ?? map['id_location'];
    final int locationId = locVal is int ? locVal : int.tryParse(locVal.toString()) ?? 0;

    final dynamic ultima = map['ultima_actualizacion'] ?? map['ultimaActualizacion'] ?? map['updated_at'];
    DateTime timestamp;
    if (ultima is DateTime) {
      timestamp = ultima;
    } else if (ultima is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(ultima);
    } else {
      timestamp = DateTime.tryParse(ultima?.toString() ?? '') ?? DateTime.now();
    }

    final String name = (map['nombre'] ?? map['name'] ?? '').toString();
    final String tipo = (map['tipo'] ?? '').toString();
    final String? descripcion = map['descripcion']?.toString();

    return VisibleSkyItem(
      id: id,
      locationId: locationId,
      timestamp: timestamp,
      name: name,
      tipo: tipo,
      descripcion: descripcion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_cielo_visible': id,
      'id_ubicacion': locationId,
      'ultima_actualizacion': timestamp.toIso8601String(),
      'nombre': name,
      'tipo': tipo,
      'descripcion': descripcion,
    };
  }
}
