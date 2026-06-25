import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/util/rotas.dart';
import 'package:ifsc_mobile_av2/widgets/mensagem_erro.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({Key? key}) : super(key: key);

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _loginFormKey = GlobalKey<FormState>();
  final _cadFormKey = GlobalKey<FormState>();

  final _loginEmailCtrl = TextEditingController();
  final _loginSenhaCtrl = TextEditingController();
  final _cadNomeCtrl = TextEditingController();
  final _cadEmailCtrl = TextEditingController();
  final _cadSenhaCtrl = TextEditingController();

  bool _mostrarSenhaLogin = false;
  bool _mostrarSenhaCad = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginSenhaCtrl.dispose();
    _cadNomeCtrl.dispose();
    _cadEmailCtrl.dispose();
    _cadSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_loginEmailCtrl.text.trim(), _loginSenhaCtrl.text);
    if (ok && mounted) Navigator.pushReplacementNamed(context, Rotas.telaHome);
  }

  Future<void> _cadastrar() async {
    if (!_cadFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.cadastrar(_cadEmailCtrl.text.trim(), _cadSenhaCtrl.text);
    if (ok && mounted) Navigator.pushReplacementNamed(context, Rotas.telaHome);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 28, color: Colors.grey[700]),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Login/Cadastro',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),

              // Botões sociais
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BotaoSocial(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login Google: integre com google_sign_in'))),
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                      width: 32, height: 32,
                      errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _BotaoSocial(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login Microsoft: integre com msal_flutter'))),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0078D4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.mail, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tabs Login / Cadastro
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: const Color(0xFF2D6A4F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  tabs: const [Tab(text: 'Login'), Tab(text: 'Cadastro')],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // ---- LOGIN ----
                    Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          _CampoAuth(ctrl: _loginEmailCtrl, hint: 'E-mail', icone: Icons.email_outlined,
                            tipo: TextInputType.emailAddress,
                            validador: (v) => v == null || v.isEmpty ? 'Informe o e-mail' : null),
                          const SizedBox(height: 12),
                          _CampoAuth(
                            ctrl: _loginSenhaCtrl, hint: 'Senha', icone: Icons.lock_outline,
                            obscuro: !_mostrarSenhaLogin,
                            sufixo: IconButton(
                              icon: Icon(_mostrarSenhaLogin ? Icons.visibility_off : Icons.visibility, size: 20),
                              onPressed: () => setState(() => _mostrarSenhaLogin = !_mostrarSenhaLogin),
                            ),
                            validador: (v) => v == null || v.isEmpty ? 'Informe a senha' : null,
                          ),
                          if (auth.erro != null && _tabCtrl.index == 0) ...[
                            const SizedBox(height: 8),
                            MensagemErro(mensagem: auth.erro!),
                          ],
                          const Spacer(),
                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton(
                              onPressed: auth.carregando ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D6A4F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: auth.carregando
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---- CADASTRO ----
                    Form(
                      key: _cadFormKey,
                      child: Column(
                        children: [
                          _CampoAuth(ctrl: _cadNomeCtrl, hint: 'Nome de usuário', icone: Icons.person_outline,
                            validador: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null),
                          const SizedBox(height: 10),
                          _CampoAuth(ctrl: _cadEmailCtrl, hint: 'E-mail', icone: Icons.email_outlined,
                            tipo: TextInputType.emailAddress,
                            validador: (v) => v == null || v.isEmpty ? 'Informe o e-mail' : null),
                          const SizedBox(height: 10),
                          _CampoAuth(
                            ctrl: _cadSenhaCtrl, hint: 'Senha', icone: Icons.lock_outline,
                            obscuro: !_mostrarSenhaCad,
                            sufixo: IconButton(
                              icon: Icon(_mostrarSenhaCad ? Icons.visibility_off : Icons.visibility, size: 20),
                              onPressed: () => setState(() => _mostrarSenhaCad = !_mostrarSenhaCad),
                            ),
                            validador: (v) {
                              if (v == null || v.isEmpty) return 'Informe a senha';
                              if (v.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          if (auth.erro != null && _tabCtrl.index == 1) ...[
                            const SizedBox(height: 8),
                            MensagemErro(mensagem: auth.erro!),
                          ],
                          const Spacer(),
                          SizedBox(
                            width: double.infinity, height: 50,
                            child: ElevatedButton(
                              onPressed: auth.carregando ? null : _cadastrar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D6A4F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: auth.carregando
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Cadastrar-se', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoSocial extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BotaoSocial({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _CampoAuth extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icone;
  final bool obscuro;
  final TextInputType tipo;
  final Widget? sufixo;
  final String? Function(String?)? validador;

  const _CampoAuth({
    required this.ctrl, required this.hint, required this.icone,
    this.obscuro = false, this.tipo = TextInputType.text,
    this.sufixo, this.validador,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscuro,
      keyboardType: tipo,
      validator: validador,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icone, size: 20),
        suffixIcon: sufixo,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D6A4F))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }
}
