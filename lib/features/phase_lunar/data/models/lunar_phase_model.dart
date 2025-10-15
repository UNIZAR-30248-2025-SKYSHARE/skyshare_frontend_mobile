class LunarPhase {
  final int idLuna;
  final int? idUbicacion;
  final String fase; 
  final double? porcentajeIluminacion;
  final double? edadLunar;
  final String? horaSalida;
  final double? azimutSalida;
  final String? horaPuesta;
  final double? azimutPuesta;
  final double? altitudActual;
  final String? proximaFase;
  final DateTime? fecha;

  LunarPhase({
  required this.idLuna,
  this.idUbicacion,
    required this.fase,
  this.fecha,
    this.porcentajeIluminacion,
    this.edadLunar,
    this.horaSalida,
    this.azimutSalida,
    this.horaPuesta,
    this.azimutPuesta,
    this.altitudActual,
    this.proximaFase,
  });

  factory LunarPhase.fromMap(Map<String, dynamic> map) {
  DateTime? fechaParsed;
    try {
      final raw = map['fecha'];
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

    return LunarPhase(
    idLuna: (map['id_luna'] is int) ? map['id_luna'] as int : (map['id_luna'] is num ? (map['id_luna'] as num).toInt() : 0),
    idUbicacion: (map['id_ubicacion'] is int)
      ? map['id_ubicacion'] as int
      : (map['id_ubicacion'] is num ? (map['id_ubicacion'] as num).toInt() : null),
    fase: map['fase']?.toString() ?? '',
      porcentajeIluminacion:
        //(map['porcentaje_iluminacion'] as num?)?.toDouble(),
        _tryParseDouble(map['porcentaje_iluminacion']),
      edadLunar: (map['edad_lunar'] as num?)?.toDouble(),
      horaSalida: map['hora_salida'] as String?,
      azimutSalida: (map['azimut_salida'] as num?)?.toDouble(),
      horaPuesta: map['hora_puesta'] as String?,
      azimutPuesta: (map['azimut_puesta'] as num?)?.toDouble(),
      altitudActual: (map['altitud_actual'] as num?)?.toDouble(),
      proximaFase: map['proxima_fase'] as String?,
      fecha: fechaParsed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_luna': idLuna,
      'id_ubicacion': idUbicacion,
      'fase': fase,
      'porcentaje_iluminacion': porcentajeIluminacion,
      'edad_lunar': edadLunar,
      'hora_salida': horaSalida,
      'azimut_salida': azimutSalida,
      'hora_puesta': horaPuesta,
      'azimut_puesta': azimutPuesta,
      'altitud_actual': altitudActual,
      'proxima_fase': proximaFase,
      'fecha': fecha?.toIso8601String(),
    };
  }

  Map<String, dynamic> toBasicMap() {
    return {
      'id_luna': idLuna,
      'fecha': fecha?.toIso8601String(),
      'fase': fase,
      'porcentaje_iluminacion': porcentajeIluminacion,
    };
  }

  static double? _tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

}
