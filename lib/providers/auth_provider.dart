import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool get estaAutenticado => false;

  Future<void> login(String email, String password) async {
    // Simula uma chamada de login
    await Future.delayed(Duration(seconds: 2));
    print('Usuário logado: $email');
  }

  Future<void> cadastra(String email, String password) async {
    // Simula uma chamada de registro
    await Future.delayed(Duration(seconds: 2));
    print('Usuário registrado: $email');
  }
}