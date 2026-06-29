import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoPublicacao { imagem, pdf, livro, outro }

class Publicacao {
  final String id;
  final String titulo;
  final String? descricao;
  final String arquivo;
  final String? miniatura;
  final String nomeUsuario;
  final String uidUsuario;
  final TipoPublicacao tipo;
  final DateTime? criadoEm;

  Publicacao({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.arquivo,
    this.miniatura,
    required this.nomeUsuario,
    required this.uidUsuario,
    this.tipo = TipoPublicacao.outro,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    String miniaturaFinal = miniatura ?? '';
    if (miniaturaFinal.isEmpty) {
      final lower = arquivo.toLowerCase();
      if (lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp')) {
        miniaturaFinal = arquivo;
      }
    }
    return {
      'titulo': titulo,
      'descricao': descricao ?? '',
      'arquivo': arquivo,
      'miniatura': miniaturaFinal,
      'nomeUsuario': nomeUsuario,
      'uidUsuario': uidUsuario,
      'tipo': tipo.name,
      'criadoEm': (criadoEm ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Publicacao.fromMap(Map<String, dynamic> map) {
    TipoPublicacao tipo;
    try {
      tipo = TipoPublicacao.values.firstWhere(
        (e) => e.name == (map['tipo'] ?? 'outro'),
      );
    } catch (_) {
      tipo = TipoPublicacao.outro;
    }

    DateTime? dataCriacao;
    if (map['criadoEm'] != null) {
      final criadoEm = map['criadoEm'];
      if (criadoEm is String) {
        // Se for String, faz parse normalmente
        dataCriacao = DateTime.tryParse(criadoEm);
      } else if (criadoEm is Timestamp) {
        // Se for Timestamp do Firebase, converte para DateTime
        dataCriacao = criadoEm.toDate();
      }
    }

    return Publicacao(
      id: map['id'],
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'],
      arquivo: map['arquivo'] ?? '',
      miniatura: map['miniatura'],
      nomeUsuario: map['nomeUsuario'] ?? 'Anônimo',
      uidUsuario: map['uidUsuario'] ?? '',
      tipo: tipo,
      criadoEm: dataCriacao,
    );
  }
}
