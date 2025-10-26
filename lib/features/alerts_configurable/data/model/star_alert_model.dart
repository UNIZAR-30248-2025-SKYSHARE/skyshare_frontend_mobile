class StarsAlert {
  final int idAlerta;
  final String idUsuario;
  final String nombreUbicacion;
  final String tipoAlerta;
  final String parametroObjetivo;
  final String tipoRepeticion;
  final DateTime fechaObjetivo;
  final bool activa;

  StarsAlert({
    required this.idAlerta,
    required this.idUsuario,
    required this.nombreUbicacion,
    required this.tipoAlerta,
    required this.parametroObjetivo,
    required this.tipoRepeticion,
    required this.fechaObjetivo,
    this.activa = true,
  });

  factory StarsAlert.fromMap(Map<String, dynamic> map) {
    return StarsAlert(
      idAlerta: map['id_alerta'] as int,
      idUsuario: map['id_usuario'] as String,
      nombreUbicacion: map['nombre_ubicacion'] as String,
      tipoAlerta: map['tipo_alerta'] as String,
      parametroObjetivo: map['parametro_objetivo'] as String,
      tipoRepeticion: map['tipo_repeticion'] as String? ?? "UNICA",
      fechaObjetivo: DateTime.parse(map['fecha_objetivo'] as String),
      activa: map['activa'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alerta': idAlerta,
      'id_usuario': idUsuario,
      'nombre_ubicacion': nombreUbicacion,
      'tipo_alerta': tipoAlerta,
      'parametro_objetivo': parametroObjetivo,
      'tipo_repeticion': tipoRepeticion,
      'fecha_objetivo': fechaObjetivo.toIso8601String(),
      'activa': activa,
    };
  }

  StarsAlert copyWith({
    int? idAlerta,
    String? idUsuario,
    String? nombreUbicacion,
    String? tipoAlerta,
    String? parametroObjetivo,
    String? tipoRepeticion,
    DateTime? fechaObjetivo,
    bool? activa,
  }) {
    return StarsAlert(
      idAlerta: idAlerta ?? this.idAlerta,
      idUsuario: idUsuario ?? this.idUsuario,
      nombreUbicacion: nombreUbicacion ?? this.nombreUbicacion,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      parametroObjetivo: parametroObjetivo ?? this.parametroObjetivo,
      tipoRepeticion: tipoRepeticion ?? this.tipoRepeticion,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      activa: activa ?? this.activa,
    );
  }
}