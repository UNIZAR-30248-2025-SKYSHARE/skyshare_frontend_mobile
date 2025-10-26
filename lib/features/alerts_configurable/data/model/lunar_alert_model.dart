class LunarAlert {
  final int idAlerta;
  final String idUsuario;
  final String nombreUbicacion;
  final String tipoAlerta;
  final String parametroObjetivo;
  final String tipoRepeticion;
  final DateTime? fechaObjetivo;
  final DateTime? horaObjetivo;
  final double? valorMinimo;
  final double? valorMaximo;
  final bool activa;

  LunarAlert({
    required this.idAlerta,
    required this.idUsuario,
    required this.nombreUbicacion,
    this.tipoAlerta = "fase lunar",
    required this.parametroObjetivo,
    this.tipoRepeticion = "UNICA",
    this.fechaObjetivo,
    this.horaObjetivo,
    this.valorMinimo,
    this.valorMaximo,
    this.activa = true,
  });

  factory LunarAlert.fromMap(Map<String, dynamic> map) {
    return LunarAlert(
      idAlerta: map['id_alerta'] as int,
      idUsuario: map['id_usuario'] as String,
      nombreUbicacion: map['nombre_ubicacion'] as String,
      tipoAlerta: map['tipo_alerta'] as String? ?? "fase lunar",
      parametroObjetivo: map['parametro_objetivo'] as String,
      tipoRepeticion: map['tipo_repeticion'] as String? ?? "UNICA",
      fechaObjetivo: map['fecha_objetivo'] != null
          ? DateTime.parse(map['fecha_objetivo'] as String)
          : null,
      horaObjetivo: map['hora_objetivo'] != null
          ? DateTime.parse(map['hora_objetivo'] as String)
          : null,
      valorMinimo: map['valor_minimo'] != null
          ? (map['valor_minimo'] as num).toDouble()
          : null,
      valorMaximo: map['valor_maximo'] != null
          ? (map['valor_maximo'] as num).toDouble()
          : null,
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
      'fecha_objetivo': fechaObjetivo?.toIso8601String(),
      'hora_objetivo': horaObjetivo?.toIso8601String(),
      'valor_minimo': valorMinimo,
      'valor_maximo': valorMaximo,
      'activa': activa,
    };
  }

  LunarAlert copyWith({
    int? idAlerta,
    String? idUsuario,
    String? nombreUbicacion,
    String? tipoAlerta,
    String? parametroObjetivo,
    String? tipoRepeticion,
    DateTime? fechaObjetivo,
    DateTime? horaObjetivo,
    double? valorMinimo,
    double? valorMaximo,
    bool? activa,
  }) {
    return LunarAlert(
      idAlerta: idAlerta ?? this.idAlerta,
      idUsuario: idUsuario ?? this.idUsuario,
      nombreUbicacion: nombreUbicacion ?? this.nombreUbicacion,
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
}