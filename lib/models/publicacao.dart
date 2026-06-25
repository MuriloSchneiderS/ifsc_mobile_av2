enum TipoPublicacao { imagem, pdf, livro, outro }

class Publicacao {
  final String? id;
  final String titulo;
  final String? descricao;
  final String arquivo;
  final String? miniatura;
  final String nomeUsuario;
  final String uidUsuario;
  final TipoPublicacao tipo;
  final DateTime? criadoEm;

  Publicacao({
    this.id,
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
      tipo = TipoPublicacao.values
          .firstWhere((e) => e.name == (map['tipo'] ?? 'outro'));
    } catch (_) {
      tipo = TipoPublicacao.outro;
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
      criadoEm: map['criadoEm'] != null
          ? DateTime.tryParse(map['criadoEm'])
          : null,
    );
  }
}
