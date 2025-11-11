class ChatMessage {
  final BigInt id;
  final DateTime createdAt;
  final String idUsuario;
  final String texto;
  final String nombreUsuario;
  bool isMe; 

  ChatMessage({
    required this.id,
    required this.createdAt,
    required this.idUsuario,
    required this.texto,
    required this.nombreUsuario,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: BigInt.parse(json['id'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      
      idUsuario: json['id_usuario'] as String? ?? 'id_usuario_nulo',
  
      texto: json['texto'] as String? ?? '', 
      nombreUsuario: json['nombre_usuario'] as String? ?? 'Usuario Desconocido',
    );
  }
}