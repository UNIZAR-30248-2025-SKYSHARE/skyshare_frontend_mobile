class AppUser {
  final String id;
  final String? username;
  final String? email;
  final String? photoUrl;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id_usuario'] as String,
      username: map['nombre_usuario'] as String?,
      email: map['email'] as String?,
      photoUrl: map['url_foto'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': id,
      'nombre_usuario': username,
      'email': email,
      'url_foto': photoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}