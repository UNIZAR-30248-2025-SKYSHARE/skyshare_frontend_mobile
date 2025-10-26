// alert_model.dart - Modelo actualizado
class AlertModel {
  final int idAlerta;
  final String idUsuario;
  final int idUbicacion; 
  final String tipoAlerta;
  final String? parametroObjetivo; 
  final String tipoRepeticion;
  final DateTime fechaObjetivo;
  final String? horaObjetivo; 
  final double? valorMinimo;
  final double? valorMaximo;
  final bool activa;

  AlertModel({
    required this.idAlerta,
    required this.idUsuario,
    required this.idUbicacion,
    required this.tipoAlerta,
    this.parametroObjetivo,
    required this.tipoRepeticion,
    required this.fechaObjetivo,
    this.horaObjetivo,
    this.valorMinimo,
    this.valorMaximo,
    this.activa = true,
  });

  factory AlertModel.fromMap(Map<String, dynamic> map) {
    String? horaStr;
    if (map['hora_objetivo'] != null) {
      final horaData = map['hora_objetivo'];
      if (horaData is String) {
        try {
          final dt = DateTime.parse(horaData);
          horaStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } catch (_) {
          horaStr = horaData;
        }
      }
    }

    return AlertModel(
      idAlerta: map['id_alerta'] as int,
      idUsuario: map['id_usuario'] as String,
      idUbicacion: map['id_ubicacion'] as int,
      tipoAlerta: map['tipo_alerta'] as String,
      parametroObjetivo: map['parametro_objetivo'] as String?,
      tipoRepeticion: map['tipo_repeticion'] as String? ?? 'UNICA',
      fechaObjetivo: DateTime.parse(map['fecha_objetivo'] as String),
      horaObjetivo: horaStr,
      activa: map['activa'] as bool? ?? true,
      valorMinimo: map['valor_minimo'] is num ? (map['valor_minimo'] as num).toDouble() : null,
      valorMaximo: map['valor_maximo'] is num ? (map['valor_maximo'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alerta': idAlerta,
      'id_usuario': idUsuario,
      'id_ubicacion': idUbicacion,
      'tipo_alerta': tipoAlerta,
      'parametro_objetivo': parametroObjetivo,
      'tipo_repeticion': tipoRepeticion,
      'fecha_objetivo': fechaObjetivo.toIso8601String(),
      'hora_objetivo': horaObjetivo,
      'activa': activa,
      'valor_minimo': valorMinimo,
      'valor_maximo': valorMaximo,
    };
  }

  AlertModel copyWith({
    int? idAlerta,
    String? idUsuario,
    int? idUbicacion,
    String? tipoAlerta,
    String? parametroObjetivo,
    String? tipoRepeticion,
    DateTime? fechaObjetivo,
    String? horaObjetivo,
    bool? activa,
    double? valorMinimo,
    double? valorMaximo,
  }) {
    return AlertModel(
      idAlerta: idAlerta ?? this.idAlerta,
      idUsuario: idUsuario ?? this.idUsuario,
      idUbicacion: idUbicacion ?? this.idUbicacion, 
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      parametroObjetivo: parametroObjetivo ?? this.parametroObjetivo,
      tipoRepeticion: tipoRepeticion ?? this.tipoRepeticion,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      horaObjetivo: horaObjetivo ?? this.horaObjetivo,
      valorMinimo: valorMinimo ?? this.valorMinimo,
      valorMaximo: valorMaximo ?? this.valorMaximo,
      activa: activa ?? this.activa,
    );
  }
  

  String get ubicacionDisplay => 'Ubicación #$idUbicacion';
}