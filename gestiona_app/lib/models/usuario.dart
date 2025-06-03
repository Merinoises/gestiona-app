class Usuario {
  final String? id;
  final String nombre;
  final String email;
  final String? password;
  final DateTime? createdAt;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    this.createdAt,
  });

  /// Crea un Usuario a partir de un Map (por ejemplo, la respuesta JSON de tu API)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] as String?,           // Mongoose usa “_id”
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      createdAt: json['createdAt'] != null  
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    );
  }

  /// Convierte este Usuario a Map (para enviar como JSON a tu API)
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'email': email,
      if (password != null) 'password': password,
    };
    if (id != null) map['_id'] = id;
    if (createdAt != null) {
      map['createdAt'] = createdAt!.toIso8601String();
    }
    return map;
  }

  /// Copia este Usuario cambiando solo los campos que indiques
  Usuario copyWith({
    String? id,
    String? nombre,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'USUARIO: {id: $id, nombre: $nombre, email: $email, password: $password, createdAt: $createdAt}';
  }
}