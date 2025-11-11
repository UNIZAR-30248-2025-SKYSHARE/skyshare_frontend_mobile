class GroupInfo {
  final int idGrupo;
  final String nombre;
  final String? descripcion;
  final DateTime fechaCreacion;

  GroupInfo({
    required this.idGrupo,
    required this.nombre,
    this.descripcion,
    required this.fechaCreacion,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      idGrupo: json['id_grupo'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}