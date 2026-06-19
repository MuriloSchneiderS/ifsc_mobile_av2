import 'package:ifsc_mobile_av2/providers/publicacao_provider.dart';
import 'package:ifsc_mobile_av2/providers/usuario_provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/telas/tela_inicial.dart';
import 'package:ifsc_mobile_av2/telas/tela_exibicao.dart';
import 'package:ifsc_mobile_av2/telas/tela_cadastro.dart';
import 'package:ifsc_mobile_av2/telas/tela_publicacao.dart';
import 'package:ifsc_mobile_av2/util/rotas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UsuarioProvider()),
          ChangeNotifierProvider(create: (_) => PublicacaoProvider()),
        ],
        child: MaterialApp(
          title: 'bookshare',
          theme: ThemeData(
            primarySwatch: Colors.teal,
          ),
          routes: {
            Rotas.telaInicial: (context) => const TelaInicial(),
            Rotas.telaExibicao: (context) => const TelaExibicao(),
            Rotas.telaCadastro: (context) => const TelaCadastro(),
            Rotas.telaPublicacao: (context) => const TelaPublicacao(),
          }
        ),
      );
  }
}