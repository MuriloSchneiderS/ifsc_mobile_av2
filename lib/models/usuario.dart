class Usuario {
  String? _id; //pode ser nulo, pois o id é gerado automaticamente pelo banco de dados
  String nome;
  String? email;//email e senha podem ser nulos, pois o usuário pode se cadastrar usando o Google Sign-In, nesse caso o email e senha serão nulos
  String? senha; 

  Usuario({
    String? id,
    required this.nome,
    this.email,
    this.senha,
  }) : _id = id;

  String? get id => _id;

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
    );
  }
}