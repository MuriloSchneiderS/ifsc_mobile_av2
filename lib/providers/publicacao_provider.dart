import 'dart:async';

import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PublicacaoProvider with ChangeNotifier {
  final List<Publicacao> _publicacoes = [];
  bool _carregando = false;
  String? _erro;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSubscription<QuerySnapshot>? _streamSubscription;

  static const String _colecao = 'publicacoes';
  static const String _bucketPrefixo = 'publicacoes/';

  // Dados de demonstração usados quando não há Firebase configurado
  static final List<Map<String, dynamic>> _dadosDemo = [
    //Mock
    {
      'id': 'demo1',
      'titulo': 'Dom Quixote',
      'descricao':
          'Considerado o primeiro romance moderno, conta as aventuras do fidalgo Alonso Quijano que, após ler muitos livros de cavalaria, decide se tornar um cavaleiro andante.',
      'arquivo': 'https://www.gutenberg.org/ebooks/996',
      'miniatura':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Cervantes_jauregui.jpg/330px-Cervantes_jauregui.jpg',
      'nomeUsuario': 'Cervantes',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-01T10:00:00.000Z',
    },
    {
      'id': 'demo2',
      'titulo': 'O Pequeno Príncipe',
      'descricao':
          'Uma das obras literárias mais lidas e traduzidas de todos os tempos. Um piloto perdido no deserto do Saara encontra um menino misterioso vindo de outro planeta.',
      'arquivo': 'https://www.gutenberg.org/ebooks/45772',
      'miniatura':
          'https://upload.wikimedia.org/wikipedia/en/0/05/Littleprince.jpg',
      'nomeUsuario': 'Saint-Exupéry',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-02T10:00:00.000Z',
    },
    {
      'id': 'demo3',
      'titulo': 'Memórias Póstumas de Brás Cubas',
      'descricao':
          'Primeiro romance brasileiro da fase realista. Narrado pelo próprio defunto-autor Brás Cubas, conta a história de um membro da elite carioca do século XIX.',
      'arquivo': 'https://www.gutenberg.org/ebooks/54829',
      'miniatura':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Machado_de_Assis_aos_40_anos.jpg/330px-Machado_de_Assis_aos_40_anos.jpg',
      'nomeUsuario': 'Machado de Assis',
      'uidUsuario': 'demo',
      'tipo': 'livro',
      'criadoEm': '2024-03-03T10:00:00.000Z',
    },
  ];
  List<Publicacao> get publicacoes => List.unmodifiable(_publicacoes);
  bool get carregando => _carregando;
  String? get erro => _erro;

  /// Carrega publicações com Stream em tempo real
  Future<void> fetchPublicacoes() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _streamSubscription = _firestore
          .collection(_colecao)
          .orderBy('criadoEm', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              _publicacoes.clear();

              if (snapshot.docs.isEmpty) {
                _carregarDemo();
              } else {
                for (var doc in snapshot.docs) {
                  try {
                    _publicacoes.add(
                      Publicacao.fromMap({...doc.data(), 'id': doc.id}),
                    );
                  } catch (e) {
                    debugPrint('Erro ao carregar publicação: $e');
                  }
                }
              }

              _carregando = false;
              notifyListeners();
            },
            onError: (e) {
              debugPrint('Erro ao ouvir publicações: $e');
              _erro = 'Erro ao carregar publicações: $e';
              _carregarDemo();
              _carregando = false;
              notifyListeners();
            },
          );
    } catch (e) {
      debugPrint('Erro ao inicializar Stream: $e');
      _erro = 'Erro ao inicializar Stream: $e';
      _carregarDemo();
      _carregando = false;
      notifyListeners();
    }
  }

  /// Cria uma nova publicação
  Future<bool> criarPublicacao(Publicacao publicacao) async {
    try {
      _erro = null;

      final doc = await _firestore.collection(_colecao).add({
        'titulo': publicacao.titulo,
        'descricao': publicacao.descricao,
        'tipo': publicacao.tipo,
        'uidUsuario': publicacao.uidUsuario,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      debugPrint('Publicação criada com ID: ${doc.id}');
      return true;
    } catch (e) {
      _erro = 'Erro ao criar publicação: $e';
      debugPrint(_erro);
      notifyListeners();
      return false;
    }
  }

  /// Atualiza uma publicação existente
  Future<bool> atualizarPublicacao(Publicacao publicacao) async {
    try {
      _erro = null;

      await _firestore.collection(_colecao).doc(publicacao.id).update({
        'titulo': publicacao.titulo,
        'descricao': publicacao.descricao,
        'tipo': publicacao.tipo,
      });

      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar publicação: $e';
      debugPrint(_erro);
      notifyListeners();
      return false;
    }
  }

  /// Deleta uma publicação
  Future<bool> deletarPublicacao(String publicacaoId) async {
    try {
      _erro = null;

      await _firestore.collection(_colecao).doc(publicacaoId).delete();

      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Erro ao deletar publicação: $e';
      debugPrint(_erro);
      notifyListeners();
      return false;
    }
  }

  /// Upload de arquivo para Firebase Storage
  Future<String> _uploadArquivo(String caminhoLocal, String pasta) async {
    try {
      final arquivo = File(caminhoLocal);
      if (!arquivo.existsSync()) {
        throw Exception('Arquivo não encontrado: $caminhoLocal');
      }

      final nomeArquivo =
          '${DateTime.now().millisecondsSinceEpoch}_${arquivo.path.split('/').last}';
      final ref = _storage.ref('$_bucketPrefixo$pasta/$nomeArquivo');

      await ref.putFile(arquivo);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint('Erro ao fazer upload de arquivo: $e');
      rethrow;
    }
  }

  /// Deleta arquivo do Firebase Storage a partir da URL
  Future<void> _deletarArquivo(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('Erro ao deletar arquivo: $e');
    }
  }

  /// Carrega dados de demonstração
  void _carregarDemo() {
    _publicacoes.clear();
    for (final d in _dadosDemo) {
      _publicacoes.add(Publicacao.fromMap(d));
    }
  }

  /// Busca publicações de um usuário específico
  Future<List<Publicacao>> buscarPorUsuario(String uidUsuario) async {
    try {
      final snapshot = await _firestore
          .collection(_colecao)
          .where('uidUsuario', isEqualTo: uidUsuario)
          .orderBy('criadoEm', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Publicacao.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar publicações do usuário: $e');
      return [];
    }
  }

  /// Busca publicações por título
  Future<List<Publicacao>> buscarPorTitulo(String termo) async {
    try {
      final snapshot = await _firestore
          .collection(_colecao)
          .where('titulo', isGreaterThanOrEqualTo: termo)
          .where('titulo', isLessThan: '${termo}z')
          .get();

      return snapshot.docs
          .map((doc) => Publicacao.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar publicações: $e');
      return [];
    }
  }
}
