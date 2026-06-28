import 'package:flutter/material.dart';

/// Interface comum para autenticação.
/// Tanto o AuthProviderFirebase quanto o AuthProviderMock a implementam.
abstract class AuthProvider extends ChangeNotifier {
  bool get estaAutenticado;
  bool get carregando;
  String? get erro;

  /// Retorna um objeto com uid, email e displayName (ou null se não autenticado).
  AuthUser? get usuario;

  Future<bool> login(String email, String senha);
  Future<bool> cadastrar(String nome, String email, String senha);
  Future<void> logout();
}

/// Dados básicos do usuário autenticado (independente do Firebase).
class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  const AuthUser({required this.uid, required this.email, this.displayName});
}
