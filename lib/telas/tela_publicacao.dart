import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'package:ifsc_mobile_av2/providers/publicacao_provider.dart';
import 'package:ifsc_mobile_av2/providers/auth_provider.dart';
import 'package:ifsc_mobile_av2/widgets/mensagem_erro.dart';

class TelaPublicacao extends StatefulWidget {
  const TelaPublicacao({super.key});

  @override
  State<TelaPublicacao> createState() => _TelaPublicacaoState();
}

class _TelaPublicacaoState extends State<TelaPublicacao> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _arquivoCtrl = TextEditingController();
  final _miniaturaCtrl = TextEditingController();
  TipoPublicacao _tipoSelecionado = TipoPublicacao.pdf;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _arquivoCtrl.dispose();
    _miniaturaCtrl.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _enviando = true; _erro = null; });

    final auth = context.read<AuthProvider>();
    final fireUser = auth.usuario;

    final publicacao = Publicacao(
      id: '', // O ID será gerado pelo Firestore
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim().isEmpty ? null : _descricaoCtrl.text.trim(),
      arquivo: _arquivoCtrl.text.trim(),
      miniatura: _miniaturaCtrl.text.trim().isEmpty ? null : _miniaturaCtrl.text.trim(),
      nomeUsuario: fireUser?.displayName ?? fireUser?.email.split('@').first ?? 'Anônimo',
      uidUsuario: fireUser?.uid ?? '',
      tipo: _tipoSelecionado,
      criadoEm: DateTime.now(),
    );

    final ok = await context.read<PublicacaoProvider>().criarPublicacao(publicacao);

    if (mounted) {
      setState(() => _enviando = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicado com sucesso!')));
        Navigator.pop(context);
      } else {
        setState(() => _erro = context.read<PublicacaoProvider>().erro ?? 'Erro ao publicar');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Nova publicação', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Área de upload (visual — sem upload real ainda)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Upload de arquivo: integre com file_picker')),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_rounded, size: 48, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      const Text('Enviar arquivo', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Formatos aceitos: PDF, epub',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tipo
              Wrap(
                spacing: 8,
                children: TipoPublicacao.values.map((tipo) {
                  final labels = {
                    TipoPublicacao.imagem: 'Imagem',
                    TipoPublicacao.pdf: 'PDF',
                    TipoPublicacao.livro: 'Livro',
                    TipoPublicacao.outro: 'Outro',
                  };
                  return FilterChip(
                    label: Text(labels[tipo]!),
                    selected: tipo == _tipoSelecionado,
                    onSelected: (_) => setState(() => _tipoSelecionado = tipo),
                    selectedColor: const Color(0xFF2D6A4F).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2D6A4F),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Campos
              _campo(_tituloCtrl, 'Título',
                  validador: (v) => v == null || v.isEmpty ? 'Informe o título' : null),
              const SizedBox(height: 10),
              _campo(_descricaoCtrl, 'Descrição', maxLinhas: 4),
              const SizedBox(height: 10),
              _campo(_arquivoCtrl, 'URL do arquivo (PDF, epub...)',
                  validador: (v) => v == null || v.isEmpty ? 'Informe a URL' : null),
              const SizedBox(height: 10),
              _campo(_miniaturaCtrl, 'URL da capa (opcional)'),

              if (_erro != null) ...[
                const SizedBox(height: 8),
                MensagemErro(mensagem: _erro!),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _publicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _enviando
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Publicar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label,
      {String? Function(String?)? validador, int maxLinhas = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLinhas,
      validator: validador,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2D6A4F))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
      ),
    );
  }
}
