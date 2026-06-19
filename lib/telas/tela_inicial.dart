import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';

class TelaInicial extends StatelessWidget {
  const TelaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    if(authProvider.estaAutenticado) {
      return Scaffold(
      
      );
    }
    return Scaffold(
      
    );
  }
}