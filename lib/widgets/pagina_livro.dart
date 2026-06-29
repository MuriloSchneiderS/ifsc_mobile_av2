import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class PaginaLivro extends StatefulWidget {
  final String titulo;
  final String descricao;
  final String? miniatura;
  final String nomeUsuario;
  final String urlArquivo;
  final VoidCallback? onAbrirArquivo;
  final Function(bool)? onBookmarkChanged;
  final bool initialBookmarked;

  const PaginaLivro({
    super.key,
    required this.titulo,
    required this.descricao,
    this.miniatura,
    required this.nomeUsuario,
    required this.urlArquivo,
    this.onAbrirArquivo,
    this.onBookmarkChanged,
    this.initialBookmarked = false,
  });

  @override
  PaginaLivroState createState() => PaginaLivroState();
}

class PaginaLivroState extends State<PaginaLivro> {
  double rotacao = 0.0;
  bool _bookmarked = false;
  bool _estabilizacaoAtiva = false; // Padrão desativado
  final List<double> _historicoGiro = [];
  static const int _tamanhoFiltro = 5;
  StreamSubscription<GyroscopeEvent>? _gyroscopioSubscription;// Assinatura do stream do giroscópio

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.initialBookmarked;
    // Não inicia o giroscópio automaticamente
  }

  void _alternarEstabilizacao() {
    setState(() {
      _estabilizacaoAtiva = !_estabilizacaoAtiva;
    });

    if (_estabilizacaoAtiva) {
      _inicializarGiroscopio();
    } else {
      _pararGiroscopio();
    }
  }

  void _inicializarGiroscopio() {
    _gyroscopioSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        if (_estabilizacaoAtiva) {
          setState(() {
            _aplicarFiltro(event.y);
            rotacao = rotacao.clamp(-0.2, 0.2);
          });
        }
      },
    );
  }

  void _pararGiroscopio() {
    _gyroscopioSubscription?.cancel();
    // Reseta a rotação quando desativar
    setState(() {
      rotacao = 0.0;
      _historicoGiro.clear();
    });
  }

  void _aplicarFiltro(double novoValor) {
    if (novoValor.abs() > 0.05) {
      _historicoGiro.add(novoValor);

      if (_historicoGiro.length > _tamanhoFiltro) {
        _historicoGiro.removeAt(0);
      }

      double media = _historicoGiro.reduce((a, b) => a + b) / _historicoGiro.length;
      rotacao += media * 0.005;
    }
  }

  bool get _temCapa =>
      widget.miniatura != null &&
      widget.miniatura!.isNotEmpty &&
      widget.miniatura!.startsWith('http');

  @override
  void dispose() {
    _pararGiroscopio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotacao,
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Conteúdo da página
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Capa do livro
                  if (_temCapa)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.miniatura!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 40,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                    ),
                  if (_temCapa) const SizedBox(height: 16),

                  // Descrição
                  if (widget.descricao.isNotEmpty)
                    Text(
                      widget.descricao,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Color(0xFF333333),
                      ),
                    )
                  else
                    Text(
                      'Este arquivo não possui descrição.\n\nAcesse o link abaixo para visualizar o conteúdo completo.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Colors.grey[600],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Link do arquivo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Color(0xFF2D6A4F)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.urlArquivo,
                            style: const TextStyle(
                              color: Color(0xFF2D6A4F),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Barra inferior com título e ações
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.nomeUsuario,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botão de estabilização
                    Tooltip(
                      message: _estabilizacaoAtiva
                          ? 'Desativar estabilização'
                          : 'Ativar estabilização',
                      child: IconButton(
                        icon: Icon(
                          _estabilizacaoAtiva
                              ? Icons.videogame_asset
                              : Icons.videogame_asset_outlined,
                          color: _estabilizacaoAtiva
                              ? const Color(0xFF2D6A4F)
                              : Colors.grey[400],
                        ),
                        onPressed: _alternarEstabilizacao,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: const Color(0xFF2D6A4F),
                      ),
                      onPressed: () {
                        setState(() => _bookmarked = !_bookmarked);
                        widget.onBookmarkChanged?.call(_bookmarked);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 20),
                      onPressed: widget.onAbrirArquivo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
