class WeatherAlert {
  final int idAlerta;
  final String idUsuario;
  final String nombreUbicacion;
  final String tipoAlerta;
  final double? valorMinimo;
  final double? valorMaximo;
  final String tipoRepeticion;
  final DateTime fechaObjetivo;
  final bool activa;
  final String? parametroObjetivo; 

  WeatherAlert({
    required this.idAlerta,
    required this.idUsuario,
    required this.nombreUbicacion,
    required this.tipoAlerta,
    this.valorMinimo,
    this.valorMaximo,
    required this.tipoRepeticion,
    required this.fechaObjetivo,
    this.activa = true,
    this.parametroObjetivo, 
  });

  factory WeatherAlert.fromMap(Map<String, dynamic> map) {
    return WeatherAlert(
      idAlerta: map['id_alerta'] as int,
      idUsuario: map['id_usuario'] as String,
      nombreUbicacion: map['nombre_ubicacion'] as String,
      tipoAlerta: map['tipo_alerta'] as String,
      valorMinimo: map['valor_minimo'] != null
          ? (map['valor_minimo'] as num).toDouble()
          : null,
      valorMaximo: map['valor_maximo'] != null
          ? (map['valor_maximo'] as num).toDouble()
          : null,
      tipoRepeticion: map['tipo_repeticion'] as String? ?? "UNICA",
      fechaObjetivo: DateTime.parse(map['fecha_objetivo'] as String),
      activa: map['activa'] as bool? ?? true,
      parametroObjetivo: map['parametro_objetivo'] as String?, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_alerta': idAlerta,
      'id_usuario': idUsuario,
      'nombre_ubicacion': nombreUbicacion,
      'tipo_alerta': tipoAlerta,
      'valor_minimo': valorMinimo,
      'valor_maximo': valorMaximo,
      'tipo_repeticion': tipoRepeticion,
      'fecha_objetivo': fechaObjetivo.toIso8601String(),
      'activa': activa,
      'parametro_objetivo': parametroObjetivo, 
    };
  }

  WeatherAlert copyWith({
    int? idAlerta,
    String? idUsuario,
    String? nombreUbicacion,
    String? tipoAlerta,
    double? valorMinimo,
    double? valorMaximo,
    String? tipoRepeticion,
    DateTime? fechaObjetivo,
    bool? activa,
    String? parametroObjetivo, // ✅ añadido al copyWith
  }) {
    return WeatherAlert(
      idAlerta: idAlerta ?? this.idAlerta,
      idUsuario: idUsuario ?? this.idUsuario,
      nombreUbicacion: nombreUbicacion ?? this.nombreUbicacion,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      valorMinimo: valorMinimo ?? this.valorMinimo,
      valorMaximo: valorMaximo ?? this.valorMaximo,
      tipoRepeticion: tipoRepeticion ?? this.tipoRepeticion,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      activa: activa ?? this.activa,
      parametroObjetivo: parametroObjetivo ?? this.parametroObjetivo, 
    );
  }
}
