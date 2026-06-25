import 'package:firebase_auth/firebase_auth.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';

class AuthProviderFirebase extends AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthUser? _usuario;
  String? _erro;
  bool _carregando = false;

  @override AuthUser? get usuario => _usuario;
  @override String? get erro => _erro;
  @override bool get carregando => _carregando;
  @override bool get estaAutenticado => _usuario != null;

  AuthProviderFirebase() {
    _auth.authStateChanges().listen((user) {
      _usuario = user == null
          ? null
          : AuthUser(uid: user.uid, email: user.email ?? '',
              displayName: user.displayName);
      notifyListeners();
    });
  }

  @override
  Future<bool> login(String email, String senha) async {
    try {
      _carregando = true; _erro = null; notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _carregando = false; notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = _traduzir(e.code); _carregando = false; notifyListeners();
      return false;
    }
  }

  @override
  Future<bool> cadastrar(String email, String senha) async {
    try {
      _carregando = true; _erro = null; notifyListeners();
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _carregando = false; notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = _traduzir(e.code); _carregando = false; notifyListeners();
      return false;
    }
  }

  @override
  Future<void> logout() async => await _auth.signOut();

  String _traduzir(String code) {
    switch (code) {
      case 'user-not-found': return 'Usuário não encontrado.';
      case 'wrong-password': return 'Senha incorreta.';
      case 'email-already-in-use': return 'E-mail já cadastrado.';
      case 'weak-password': return 'Senha muito fraca (mínimo 6 caracteres).';
      case 'invalid-email': return 'E-mail inválido.';
      case 'too-many-requests': return 'Muitas tentativas. Tente mais tarde.';
      default: return 'Erro de autenticação. Tente novamente.';
    }
  }
}
