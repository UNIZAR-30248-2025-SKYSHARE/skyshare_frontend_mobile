class EventAlert {
  final int idAlerta;
  final String idUsuario;
  final String nombreUbicacion;
  final String tipoAlerta;
  final String parametroObjetivo;
  final String tipoRepeticion;
  final DateTime? fechaObjetivo;
  final String? horaObjetivo; 
  final bool activa;

  EventAlert({
    required this.idAlerta,
    required this.idUsuario,
    required this.nombreUbicacion,
    required this.tipoAlerta,
    required this.parametroObjetivo,
    this.tipoRepeticion = "UNICA",
    this.fechaObjetivo,
    this.horaObjetivo,
    this.activa = true,
  });

  factory EventAlert.fromMap(Map<String, dynamic> map) {
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

    return EventAlert(
      idAlerta: map['id_alerta'] as int,
      idUsuario: map['id_usuario'] as String,
      nombreUbicacion: map['nombre_ubicacion'] as String,
      tipoAlerta: map['tipo_alerta'] as String,
      parametroObjetivo: map['parametro_objetivo'] as String,
      tipoRepeticion: map['tipo_repeticion'] as String? ?? "UNICA",
      fechaObjetivo: map['fecha_objetivo'] != null
          ? DateTime.parse(map['fecha_objetivo'] as String)
          : null,
      horaObjetivo: horaStr,
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
      'hora_objetivo': horaObjetivo,
      'activa': activa,
    };
  }

  EventAlert copyWith({
    int? idAlerta,
    String? idUsuario,
    String? nombreUbicacion,
    String? tipoAlerta,
    String? parametroObjetivo,
    String? tipoRepeticion,
    DateTime? fechaObjetivo,
    String? horaObjetivo,
    bool? activa,
  }) {
    return EventAlert(
      idAlerta: idAlerta ?? this.idAlerta,
      idUsuario: idUsuario ?? this.idUsuario,
      nombreUbicacion: nombreUbicacion ?? this.nombreUbicacion,
      tipoAlerta: tipoAlerta ?? this.tipoAlerta,
      parametroObjetivo: parametroObjetivo ?? this.parametroObjetivo,
      tipoRepeticion: tipoRepeticion ?? this.tipoRepeticion,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      horaObjetivo: horaObjetivo ?? this.horaObjetivo,
      activa: activa ?? this.activa,
    );
  }
}