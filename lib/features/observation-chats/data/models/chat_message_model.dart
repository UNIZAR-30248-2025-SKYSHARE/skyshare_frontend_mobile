class ChatMessage {
  final BigInt id;
  final DateTime createdAt;
  final String idUsuario;
  String texto;
  String nombreUsuario;
  bool isMe;
  final bool isEncrypted;
  final String? ciphertext;
  final String? senderDevice;
  final String? senderKeyId;
  final int? idGrupo;

  ChatMessage({
    required this.id,
    required this.createdAt,
    required this.idUsuario,
    required this.texto,
    required this.nombreUsuario,
    this.isMe = false,
    this.isEncrypted = false,
    this.ciphertext,
    this.senderDevice,
    this.senderKeyId,
    this.idGrupo,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final parsedId = json['id'] != null ? BigInt.parse(json['id'].toString()) : BigInt.from(0);
    DateTime parsedDate;
    try {
      parsedDate = json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final idUsuario = (json['id_usuario'] as String?) ??
        (json['idUsuario'] as String?) ??
        'id_usuario_nulo';

    final dynamic isEncRaw = json['is_encrypted'] ?? json['isEncrypted'] ?? json['encrypted'] ?? false;
    final bool isEnc = _toBool(isEncRaw);

    final ciphertext = (json['ciphertext'] as String?) ?? (json['ciphertext_b64'] as String?);

    String textoValue;
    if (isEnc) {
      textoValue = '[Mensaje cifrado]';
    } else {
      textoValue = (json['texto'] as String?) ??
          (json['text'] as String?) ??
          '';
    }

    final nombreUsuario = (json['nombre_usuario'] as String?) ??
        (json['nombreUsuario'] as String?) ??
        'Usuario Desconocido';

    final senderDevice = (json['sender_device'] as String?) ?? (json['senderDevice'] as String?);
    final senderKeyId = (json['sender_key_id'] as String?) ?? (json['senderKeyId'] as String?);
    final idGrupo = json['id_grupo'] != null ? int.tryParse(json['id_grupo'].toString()) : (json['group_id'] != null ? int.tryParse(json['group_id'].toString()) : null);

    return ChatMessage(
      id: parsedId,
      createdAt: parsedDate,
      idUsuario: idUsuario,
      texto: textoValue,
      nombreUsuario: nombreUsuario,
      isMe: false,
      isEncrypted: isEnc,
      ciphertext: ciphertext,
      senderDevice: senderDevice,
      senderKeyId: senderKeyId,
      idGrupo: idGrupo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'created_at': createdAt.toIso8601String(),
      'id_usuario': idUsuario,
      'texto': texto,
      'nombre_usuario': nombreUsuario,
      'is_encrypted': isEncrypted,
      'ciphertext': ciphertext,
      'sender_device': senderDevice,
      'sender_key_id': senderKeyId,
      'id_grupo': idGrupo,
    };
  }

  static bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == 't' || s == '1' || s == 'yes' || s == 'y';
  }
}