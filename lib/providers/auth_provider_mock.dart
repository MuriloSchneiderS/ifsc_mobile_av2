import 'package:ifsc_mobile_av2/providers/auth_provider.dart';

/// Implementação fake de AuthProvider — não precisa de Firebase.
/// Use no main.dart para testar as telas normalmente.
class AuthProviderMock extends AuthProvider {
  AuthUser? _usuario;
  bool _carregando = false;
  String? _erro;

  @override AuthUser? get usuario => _usuario;
  @override bool get carregando => _carregando;
  @override String? get erro => _erro;
  @override bool get estaAutenticado => _usuario != null;

  @override
  Future<bool> login(String email, String senha) async {
    _carregando = true; _erro = null; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    if (senha.length < 6) {
      _erro = 'Senha incorreta (mock: use 6+ caracteres)';
      _carregando = false; notifyListeners();
      return false;
    }
    _usuario = AuthUser(
      uid: 'mock-uid-123',
      email: email,
      displayName: email.split('@').first,
    );
    _carregando = false; notifyListeners();
    return true;
  }

  @override
  Future<bool> cadastrar(String email, String senha) => login(email, senha);

  @override
  Future<void> logout() async {
    _usuario = null;
    notifyListeners();
  }
}
