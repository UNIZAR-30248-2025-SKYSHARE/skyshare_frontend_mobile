class ChatPreview {
  final int idGrupo;
  final String nombreGrupo;
  final String? ultimoMensajeTexto; 
  final DateTime? ultimoMensajeFecha;
  final String? ultimoMensajeSenderNombre;

  ChatPreview({
    required this.idGrupo,
    required this.nombreGrupo,
    this.ultimoMensajeTexto,
    this.ultimoMensajeFecha,
    this.ultimoMensajeSenderNombre,
  });

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      idGrupo: json['id_grupo'] as int,
      nombreGrupo: json['nombre_grupo'] as String,
      ultimoMensajeTexto: json['ultimo_mensaje_texto'] as String?,
      ultimoMensajeFecha: json['ultimo_mensaje_fecha'] != null
          ? DateTime.parse(json['ultimo_mensaje_fecha'])
          : null,
      ultimoMensajeSenderNombre: json['ultimo_mensaje_sender_nombre'] as String?,
    );
  }
}