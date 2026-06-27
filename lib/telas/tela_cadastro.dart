import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/providers/usuario_provider.dart';
import 'package:ifsc_mobile_av2/models/usuario.dart';
import 'package:ifsc_mobile_av2/util/rotas.dart';
import 'package:ifsc_mobile_av2/widgets/mensagem_erro.dart';

/// Tela de cadastro standalone (acessível pela rota /cadastro se necessário)
/// No fluxo principal o cadastro fica na tab da tela_inicial.
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();
  bool _mostrarSenha = false;
  bool _buscandoGps = false;
  double? _lat, _lon;
  String? _localizacaoMsg;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarLocalizacao() async {
    setState(() { _buscandoGps = true; _localizacaoMsg = null; });
    final pos = await context.read<UsuarioProvider>().obterLocalizacao();
    if (mounted) {
      setState(() {
        _buscandoGps = false;
        if (pos != null) {
          _lat = pos.latitude;
          _lon = pos.longitude;
          _localizacaoMsg = '📍 ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        } else {
          _localizacaoMsg = 'Não foi possível obter localização.';
        }
      });
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_senhaCtrl.text != _confirmaCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')));
      return;
    }

    final auth = context.read<AuthProvider>();
    final usuarioProvider = context.read<UsuarioProvider>();
    final ok = await auth.cadastrar(_emailCtrl.text.trim(), _senhaCtrl.text);

    if (ok && mounted) {
      final uid = auth.usuario!.uid;
      await usuarioProvider.salvarUsuario(Usuario(
        id: uid,
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        latitude: _lat,
        longitude: _lon,
      ));
      if (mounted) Navigator.pushReplacementNamed(context, Rotas.telaHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campo(_nomeCtrl, 'Nome de usuário', Icons.person_outline,
                    validador: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null),
                const SizedBox(height: 12),
                _campo(_emailCtrl, 'E-mail', Icons.email_outlined,
                    tipo: TextInputType.emailAddress,
                    validador: (v) => v == null || v.isEmpty ? 'Informe o e-mail' : null),
                const SizedBox(height: 12),
                _campo(_senhaCtrl, 'Senha', Icons.lock_outline,
                    obscuro: !_mostrarSenha,
                    sufixo: IconButton(
                      icon: Icon(_mostrarSenha ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                    ),
                    validador: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    }),
                const SizedBox(height: 12),
                _campo(_confirmaCtrl, 'Confirmar senha', Icons.lock_outline,
                    obscuro: true,
                    validador: (v) => v == null || v.isEmpty ? 'Confirme a senha' : null),
                const SizedBox(height: 12),

                // GPS
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _buscandoGps ? null : _buscarLocalizacao,
                    icon: _buscandoGps
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.location_on_outlined),
                    label: Text(_buscandoGps ? 'Buscando...' : 'Usar minha localização'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: const BorderSide(color: Color(0xFF2D6A4F)),
                      foregroundColor: const Color(0xFF2D6A4F),
                    ),
                  ),
                ),
                if (_localizacaoMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_localizacaoMsg!,
                        style: TextStyle(color: _lat != null ? Colors.green[700] : Colors.grey[600], fontSize: 13)),
                  ),

                if (auth.erro != null) ...[
                  const SizedBox(height: 8),
                  MensagemErro(mensagem: auth.erro!),
                ],

                const SizedBox(height: 24),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String hint, IconData icone,
      {bool obscuro = false, TextInputType tipo = TextInputType.text,
      Widget? sufixo, String? Function(String?)? validador}) {
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
