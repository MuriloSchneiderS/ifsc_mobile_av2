import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider_firebase.dart';

import 'package:ifsc_mobile_av2/providers/publicacao_provider.dart';
import 'package:ifsc_mobile_av2/providers/usuario_provider.dart';

import 'package:ifsc_mobile_av2/util/rotas.dart';
import 'package:ifsc_mobile_av2/telas/tela_inicial.dart';
import 'package:ifsc_mobile_av2/telas/tela_exibicao.dart';
import 'package:ifsc_mobile_av2/telas/tela_cadastro.dart';
import 'package:ifsc_mobile_av2/telas/tela_publicacao.dart';
import 'package:ifsc_mobile_av2/telas/tela_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const BookshareApp());
}

class BookshareApp extends StatelessWidget {
  const BookshareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProviderFirebase()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => PublicacaoProvider()),
      ],
      child: MaterialApp(
        title: 'bookshare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        ),
        initialRoute: Rotas.telaInicial,
        routes: {
          Rotas.telaInicial: (_) => const _AuthGuard(),
          Rotas.telaCadastro: (_) => const TelaCadastro(),
          Rotas.telaPublicacao: (_) => const TelaPublicacao(),
          Rotas.telaExibicao: (_) => const TelaExibicao(),
          Rotas.telaHome: (_) => const TelaHome(),
        },
      ),
    );
  }
}

class _AuthGuard extends StatelessWidget {
  const _AuthGuard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.estaAutenticado) return const TelaHome();
    return const TelaInicial();
  }
}
