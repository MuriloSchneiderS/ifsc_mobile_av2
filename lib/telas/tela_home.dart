import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/providers/publicacao_provider.dart';
import 'package:ifsc_mobile_av2/telas/tela_bookmarks.dart';
import 'package:ifsc_mobile_av2/telas/tela_perfil.dart';
import 'package:ifsc_mobile_av2/util/rotas.dart';
import 'package:ifsc_mobile_av2/models/publicacao.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _abaSelecionada = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PublicacaoProvider>().fetchPublicacoes();
    });
  }

  Future<void> _confirmarRemover(BuildContext context, Publicacao pub) async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario?.uid != pub.uidUsuario) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover publicação?'),
        content: Text('Deseja remover "${pub.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<PublicacaoProvider>().deletarPublicacao(pub.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Troca o body conforme a aba
    final List<Widget> abas = [
      _FeedBody(onConfirmarRemover: _confirmarRemover),
      const TelaBookmarks(),
      const TelaPerfil(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: abas[_abaSelecionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        onTap: (i) => setState(() => _abaSelecionada = i),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2D6A4F),
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Bookmarks'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Feed (aba Início)
// ──────────────────────────────────────────────
class _FeedBody extends StatelessWidget {
  final Future<void> Function(BuildContext, Publicacao) onConfirmarRemover;
  const _FeedBody({required this.onConfirmarRemover});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pubProvider = context.watch<PublicacaoProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.menu_book, color: theme.colorScheme.primary, size: 26),
            const SizedBox(width: 8),
            Text('BOOKSHARE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: pubProvider.fetchPublicacoes,
        child: CustomScrollView(
          slivers: [
            // Botão Publicar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                      context, Rotas.telaPublicacao,
                      arguments: auth.usuario),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Publicar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),

            // Grid
            if (pubProvider.carregando && pubProvider.publicacoes.isEmpty)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (pubProvider.publicacoes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text('Nenhuma publicação ainda.', style: TextStyle(color: Colors.grey[600])),
                      TextButton(onPressed: pubProvider.fetchPublicacoes, child: const Text('Recarregar')),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      print('Construindo card do livro ${pubProvider.publicacoes[i].titulo}');
                      final pub = pubProvider.publicacoes[i];
                      final eMeu = auth.usuario?.uid == pub.uidUsuario;
                      return _CardLivro(
                        publicacao: pub,
                        eMeu: eMeu,
                        aoTocar: () => Navigator.pushNamed(ctx, Rotas.telaExibicao, arguments: pub),
                        aoRemover: eMeu ? () => onConfirmarRemover(context, pub) : null,
                      );
                    },
                    childCount: pubProvider.publicacoes.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Card do livro no grid
// ──────────────────────────────────────────────
class _CardLivro extends StatelessWidget {
  final Publicacao publicacao;
  final bool eMeu;
  final VoidCallback aoTocar;
  final VoidCallback? aoRemover;

  const _CardLivro({
    required this.publicacao,
    required this.eMeu,
    required this.aoTocar,
    this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final temCapa = publicacao.miniatura != null &&
        publicacao.miniatura!.isNotEmpty &&
        publicacao.miniatura!.startsWith('http');

    return GestureDetector(
      onTap: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: temCapa
                      ? Image.network(
                          publicacao.miniatura!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _capaPlaceholder(),
                        )
                      : _capaPlaceholder(),
                ),
                if (eMeu && aoRemover != null)
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: aoRemover,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(publicacao.titulo,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(publicacao.nomeUsuario,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _capaPlaceholder() {
    final cores = [
      const Color(0xFF6B4C3B), const Color(0xFF2D6A4F),
      const Color(0xFF1B4F72), const Color(0xFF7D3C98), const Color(0xFFB7950B),
    ];
    final cor = cores[publicacao.titulo.hashCode.abs() % cores.length];
    return Container(
      width: double.infinity,
      color: cor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(publicacao.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 4, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
