import 'package:flutter/material.dart';
import 'package:ifsc_mobile_av2/models/publicacao.dart';

class TelaExibicao extends StatefulWidget {
  const TelaExibicao({super.key});

  @override
  State<TelaExibicao> createState() => _TelaExibicaoState();
}

class _TelaExibicaoState extends State<TelaExibicao> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final publicacao = ModalRoute.of(context)!.settings.arguments as Publicacao;
    final temCapa = publicacao.miniatura != null &&
        publicacao.miniatura!.isNotEmpty &&
        publicacao.miniatura!.startsWith('http');

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
          // Área principal de leitura
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Conteúdo
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (temCapa)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                publicacao.miniatura!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox(),
                              ),
                            ),
                          if (temCapa) const SizedBox(height: 16),
                          if (publicacao.descricao != null && publicacao.descricao!.isNotEmpty)
                            Text(
                              publicacao.descricao!,
                              style: const TextStyle(fontSize: 14, height: 1.7, color: Color(0xFF333333)),
                            )
                          else
                            Text(
                              'Este arquivo não possui descrição.\n\nAcesse o link abaixo para visualizar o conteúdo completo.',
                              style: TextStyle(fontSize: 14, height: 1.7, color: Colors.grey[600]),
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
                                    publicacao.arquivo,
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
                      left: 0, right: 0, bottom: 0,
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
                                    publicacao.titulo,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    publicacao.nomeUsuario,
                                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                color: const Color(0xFF2D6A4F),
                              ),
                              onPressed: () => setState(() => _bookmarked = !_bookmarked),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Integre com url_launcher para abrir o arquivo')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
