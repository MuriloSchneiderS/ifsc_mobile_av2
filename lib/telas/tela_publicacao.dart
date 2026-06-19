import 'package:flutter/material.dart';
import 'package:ifsc_mobile_av2/models/usuario.dart';
import 'package:ifsc_mobile_av2/providers/usuario_provider.dart';

class TelaPublicacao extends StatelessWidget {
  const TelaPublicacao({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = ModalRoute.of(context)!.settings.arguments as Usuario;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicação'),
      ),
      body: const Center(
        child: Text('formulário de publicação'),
      ),
    );
  }
}