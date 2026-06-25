class Usuario {
  final String id; // UID do Firebase Auth
  final String nome;
  final String email;
  final double? latitude;
  final double? longitude;
  final String? fotoPerfil;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.latitude,
    this.longitude,
    this.fotoPerfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'fotoPerfil': fotoPerfil,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      fotoPerfil: map['fotoPerfil'],
    );
  }

  Usuario copyWith({
    String? nome,
    String? email,
    double? latitude,
    double? longitude,
    String? fotoPerfil,
  }) {
    return Usuario(
      id: id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
    );
  }
}
