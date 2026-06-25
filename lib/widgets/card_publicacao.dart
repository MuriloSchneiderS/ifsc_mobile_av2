import 'package:flutter/material.dart';
import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'package:intl/intl.dart';

class CardPublicacao extends StatelessWidget {
  final Publicacao publicacao;
  final VoidCallback? aoTocar;
  final VoidCallback? aoRemover;

  const CardPublicacao({
    Key? key,
    required this.publicacao,
    this.aoTocar,
    this.aoRemover,
  }) : super(key: key);

  IconData get _icone {
    switch (publicacao.tipo) {
      case TipoPublicacao.imagem:
        return Icons.image;
      case TipoPublicacao.pdf:
        return Icons.picture_as_pdf;
      case TipoPublicacao.livro:
        return Icons.menu_book;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final temMiniatura = publicacao.miniatura != null &&
        publicacao.miniatura!.isNotEmpty &&
        (publicacao.miniatura!.startsWith('http'));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: aoTocar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura / ícone
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: temMiniatura
                  ? Image.network(
                      publicacao.miniatura!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    )
                  : _placeholder(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  Icon(_icone,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      publicacao.titulo,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (aoRemover != null)
                    IconButton(
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: aoRemover,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
            if (publicacao.descricao != null &&
                publicacao.descricao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  publicacao.descricao!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 14),
                  const SizedBox(width: 4),
                  Text(publicacao.nomeUsuario,
                      style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  if (publicacao.criadoEm != null)
                    Text(
                      DateFormat('dd/MM/yyyy').format(publicacao.criadoEm!),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(_icone,
          size: 48,
          color: Theme.of(context).colorScheme.onPrimaryContainer),
    );
  }
}
