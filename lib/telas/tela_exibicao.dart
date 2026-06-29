import 'package:flutter/material.dart';
import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'package:ifsc_mobile_av2/widgets/pagina_livro.dart';

class TelaExibicao extends StatefulWidget {
  const TelaExibicao({super.key});

  @override
  State<TelaExibicao> createState() => _TelaExibicaoState();
}

class _TelaExibicaoState extends State<TelaExibicao> {
  bool _bookmarked = false;

  void _abrirArquivo(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo: $url')),
    );
    // TODO: Implementar url_launcher aqui
  }

  void _onBookmarkChanged(bool novoEstado) {
    setState(() {
      _bookmarked = novoEstado;
    });
    // TODO: Salvar estado do bookmark no banco de dados
  }

  @override
  Widget build(BuildContext context) {
    final publicacao = ModalRoute.of(context)!.settings.arguments as Publicacao;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Exibição do arquivo', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PaginaLivro(
                  titulo: publicacao.titulo,
                  descricao: publicacao.descricao ?? '',
                  miniatura: publicacao.miniatura,
                  nomeUsuario: publicacao.nomeUsuario,
                  urlArquivo: publicacao.arquivo,
                  initialBookmarked: _bookmarked,
                  onAbrirArquivo: () => _abrirArquivo(publicacao.arquivo),
                  onBookmarkChanged: _onBookmarkChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
