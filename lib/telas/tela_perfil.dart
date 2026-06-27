import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/providers/publicacao_provider.dart';
import 'package:ifsc_mobile_av2/util/rotas.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pubProvider = context.watch<PublicacaoProvider>();
    final usuario = auth.usuario;
    final nome = usuario?.displayName ?? usuario?.email.split('@').first ?? 'Usuário';
    final email = usuario?.email ?? '';
    final minhasPublicacoes = pubProvider.publicacoes
        .where((p) => p.uidUsuario == usuario?.uid)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Rotas.telaInicial);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho do perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF2D6A4F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: Text(
                      nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(nome,
                      style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  if (email.isNotEmpty)
                    Text(email, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Estatistica(label: 'Publicações', valor: minhasPublicacoes.length.toString()),
                      const SizedBox(width: 32),
                      const _Estatistica(label: 'Bookmarks', valor: '0'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Minhas publicações
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Minhas publicações',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (minhasPublicacoes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.library_books_outlined, size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('Você ainda não publicou nada.',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: minhasPublicacoes.length,
                      itemBuilder: (ctx, i) {
                        final pub = minhasPublicacoes[i];
                        final temCapa = pub.miniatura != null &&
                            pub.miniatura!.isNotEmpty &&
                            pub.miniatura!.startsWith('http');
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(ctx, Rotas.telaExibicao, arguments: pub),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: temCapa
                                      ? Image.network(pub.miniatura!, width: double.infinity, fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => _capaFallback(pub))
                                      : _capaFallback(pub),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(pub.titulo,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _capaFallback(pub) {
    final cores = [
      const Color(0xFF6B4C3B), const Color(0xFF2D6A4F),
      const Color(0xFF1B4F72), const Color(0xFF7D3C98),
    ];
    final cor = cores[pub.titulo.hashCode.abs() % cores.length];
    return Container(
      color: cor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(pub.titulo, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 4, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _Estatistica extends StatelessWidget {
  final String label;
  final String valor;
  const _Estatistica({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}
