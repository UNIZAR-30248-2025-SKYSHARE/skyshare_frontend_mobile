class GuiaConstelacion {
  final int idGuia;
  final String nombreConstelacion;
  final String temporada; // solo puede ser 'invierno' o 'verano'
  final String? descripcionGeneral;
  final String paso1;
  final String paso2;
  final String paso3;
  final String paso4;
  final String referencia;
  final String? urlReferencia;
  final String? imagenUrl;
  final DateTime? fechaCreacion;
  final String? paso5;
  final String? paso6;

  GuiaConstelacion({
    required this.idGuia,
    required this.nombreConstelacion,
    required this.temporada,
    this.descripcionGeneral,
    required this.paso1,
    required this.paso2,
    required this.paso3,
    required this.paso4,
    required this.referencia,
    this.urlReferencia,
    this.imagenUrl,
    this.fechaCreacion,
    this.paso5,
    this.paso6,
  });

  factory GuiaConstelacion.fromMap(Map<String, dynamic> map) {
    DateTime? fechaParsed;
    try {
      final raw = map['fecha_creacion'];
      if (raw == null) {
        fechaParsed = null;
      } else if (raw is String) {
        fechaParsed = DateTime.tryParse(raw);
      } else if (raw is DateTime) {
        fechaParsed = raw;
      } else {
        fechaParsed = null;
      }
    } catch (_) {
      fechaParsed = null;
    }

    return GuiaConstelacion(
      idGuia: (map['id_guia'] is int)
          ? map['id_guia'] as int
          : (map['id_guia'] is num ? (map['id_guia'] as num).toInt() : 0),
      nombreConstelacion: map['nombre_constelacion']?.toString() ?? '',
      temporada: map['temporada']?.toString() ?? '',
      descripcionGeneral: map['descripcion_general']?.toString(),
      paso1: map['paso_1']?.toString() ?? '',
      paso2: map['paso_2']?.toString() ?? '',
      paso3: map['paso_3']?.toString() ?? '',
      paso4: map['paso_4']?.toString() ?? '',
      referencia: map['referencia']?.toString() ?? '',
      urlReferencia: map['url_referencia']?.toString(),
      imagenUrl: map['imagen_url']?.toString(),
      fechaCreacion: fechaParsed,
      paso5: map['paso_5']?.toString(),
      paso6: map['paso_6']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_guia': idGuia,
      'nombre_constelacion': nombreConstelacion,
      'temporada': temporada,
      'descripcion_general': descripcionGeneral,
      'paso_1': paso1,
      'paso_2': paso2,
      'paso_3': paso3,
      'paso_4': paso4,
      'referencia': referencia,
      'url_referencia': urlReferencia,
      'imagen_url': imagenUrl,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'paso_5': paso5,
      'paso_6': paso6,
    };
  }

  Map<String, dynamic> toBasicMap() {
    return {
      'id_guia': idGuia,
      'nombre_constelacion': nombreConstelacion,
      'temporada': temporada,
      'referencia': referencia,
    };
  }
}
