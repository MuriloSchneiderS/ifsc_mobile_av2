import 'package:flutter/material.dart';
import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'package:ifsc_mobile_av2/providers/publicacao_provider.dart';

class TelaExibicao extends StatelessWidget {
  final Publicacao publicacao;

  const TelaExibicao({Key? key, required this.publicacao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(publicacao.titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(publicacao.descricao ?? ''),
      ),
    );
  }
}