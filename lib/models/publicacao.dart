import 'package:ifsc_mobile_av2/models/usuario.dart';

class Publicacao {
  String? _id; //pode ser nulo, pois o id é gerado automaticamente pelo banco de dados
  String titulo;
  String? descricao;
  String arquivo; //caminho do arquivo no firebase storage, pode ser uma imagem/pdf/epub
  String? miniatura; //caminho da miniatura do arquivo no firebase storage, se for nulo a miniatura será a primeira página do arquivo (para pdf) ou a própria imagem (para imagens)
  Usuario usuario;

  Publicacao({
    String? id,
    required this.titulo,
    this.descricao,
    required this.arquivo,
    this.miniatura,
    required this.usuario,
  }) : _id = id;

  String? get id => _id;

  Map<String, dynamic> toMap() {
    if (miniatura == null && (arquivo.endsWith('.pdf') || arquivo.endsWith('.epub'))) {
      miniatura = ''; //caminho da miniatura padrão para arquivos pdf
    } else if (miniatura == null && (arquivo.endsWith('.jpg') || arquivo.endsWith('.jpeg') || arquivo.endsWith('.png'))) {
      miniatura = arquivo; //se for uma imagem, a miniatura é a própria imagem
    }
    return {
      'id': _id,
      'titulo': titulo,
      'descricao': descricao,
      'arquivo': arquivo,
      'miniatura': miniatura,
      'usuario': usuario.toMap(),
    };
  }
  
  factory Publicacao.fromMap(Map<String, dynamic> map) {
    return Publicacao(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      arquivo: map['arquivo'],
      miniatura: map['miniatura'],
      usuario: Usuario.fromMap(map['usuario']),
    );
  }
}
