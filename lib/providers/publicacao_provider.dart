import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PublicacaoProvider with ChangeNotifier {
  final List<Publicacao> _publicacoes = [];
  bool _carregando = false;
  String? _erro;

  static const String _baseUrl =
      'https://project-2398835836236741984-default-rtdb.firebaseio.com';

  // Dados de demonstração usados quando não há Firebase configurado
  static final List<Map<String, dynamic>> _dadosDemo = [
    {
      'id': 'demo1',
      'titulo': 'Dom Quixote',
      'descricao': 'Considerado o primeiro romance moderno, conta as aventuras do fidalgo Alonso Quijano que, após ler muitos livros de cavalaria, decide se tornar um cavaleiro andante.',
      'arquivo': 'https://www.gutenberg.org/ebooks/996',
      'miniatura': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Cervantes_jauregui.jpg/330px-Cervantes_jauregui.jpg',
      'nomeUsuario': 'Cervantes',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-01T10:00:00.000Z',
    },
    {
      'id': 'demo2',
      'titulo': 'O Pequeno Príncipe',
      'descricao': 'Uma das obras literárias mais lidas e traduzidas de todos os tempos. Um piloto perdido no deserto do Saara encontra um menino misterioso vindo de outro planeta.',
      'arquivo': 'https://www.gutenberg.org/ebooks/45772',
      'miniatura': 'https://upload.wikimedia.org/wikipedia/en/0/05/Littleprince.jpg',
      'nomeUsuario': 'Saint-Exupéry',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-02T10:00:00.000Z',
    },
    {
      'id': 'demo3',
      'titulo': 'Memórias Póstumas de Brás Cubas',
      'descricao': 'Primeiro romance brasileiro da fase realista. Narrado pelo próprio defunto-autor Brás Cubas, conta a história de um membro da elite carioca do século XIX.',
      'arquivo': 'https://www.gutenberg.org/ebooks/54829',
      'miniatura': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Machado_de_Assis_aos_40_anos.jpg/330px-Machado_de_Assis_aos_40_anos.jpg',
      'nomeUsuario': 'Machado de Assis',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-03T10:00:00.000Z',
    },
    {
      'id': 'demo4',
      'titulo': 'A Metamorfose',
      'descricao': 'Gregor Samsa acorda uma manhã transformado em um inseto gigantesco. A obra explora temas de alienação, identidade e desumanização na sociedade moderna.',
      'arquivo': 'https://www.gutenberg.org/ebooks/5200',
      'miniatura': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/FranzKafka.jpg/330px-FranzKafka.jpg',
      'nomeUsuario': 'Franz Kafka',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-04T10:00:00.000Z',
    },
  ];

  List<Publicacao> get publicacoes => List.unmodifiable(_publicacoes);
  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<void> fetchPublicacoes() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/publicacoes.json'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = response.body;
        if (body == 'null' || body.isEmpty) {
          _carregarDemo();
        } else {
          final data = json.decode(body) as Map<String, dynamic>;
          _publicacoes.clear();
          data.forEach((key, value) {
            try {
              _publicacoes.add(Publicacao.fromMap({...value, 'id': key}));
            } catch (_) {}
          });
          _publicacoes.sort((a, b) =>
              (b.criadoEm ?? DateTime(0)).compareTo(a.criadoEm ?? DateTime(0)));
          // Se veio vazio do Firebase, mostra demo
          if (_publicacoes.isEmpty) _carregarDemo();
        }
      } else {
        _carregarDemo();
      }
    } catch (_) {
      // Sem internet ou Firebase não configurado: usa dados demo
      _carregarDemo();
    }

    _carregando = false;
    notifyListeners();
  }

  void _carregarDemo() {
    _publicacoes.clear();
    for (final d in _dadosDemo) {
      _publicacoes.add(Publicacao.fromMap(d));
    }
  }

  Future<bool> addPublicacao(Publicacao publicacao) async {
    try {
      _erro = null;
      final response = await http.post(
        Uri.parse('$_baseUrl/publicacoes.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(publicacao.toMap()),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nova = Publicacao(
          id: data['name'],
          titulo: publicacao.titulo,
          descricao: publicacao.descricao,
          arquivo: publicacao.arquivo,
          miniatura: publicacao.miniatura,
          nomeUsuario: publicacao.nomeUsuario,
          uidUsuario: publicacao.uidUsuario,
          tipo: publicacao.tipo,
          criadoEm: publicacao.criadoEm,
        );
        _publicacoes.insert(0, nova);
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Sem Firebase: adiciona localmente
    }

    // Fallback: salva só em memória
    final local = Publicacao(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      titulo: publicacao.titulo,
      descricao: publicacao.descricao,
      arquivo: publicacao.arquivo,
      miniatura: publicacao.miniatura,
      nomeUsuario: publicacao.nomeUsuario,
      uidUsuario: publicacao.uidUsuario,
      tipo: publicacao.tipo,
      criadoEm: publicacao.criadoEm,
    );
    _publicacoes.insert(0, local);
    notifyListeners();
    return true;
  }

  Future<bool> removerPublicacao(String id) async {
    try {
      await http.delete(Uri.parse('$_baseUrl/publicacoes/$id.json'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
    // Remove localmente independente do resultado do Firebase
    _publicacoes.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }
}
