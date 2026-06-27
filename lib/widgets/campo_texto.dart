import 'package:flutter/material.dart';

class CampoTexto extends StatelessWidget {
  final String rotulo;
  final String? dica;
  final TextEditingController controlador;
  final bool obscuro;
  final TextInputType tipoTeclado;
  final String? Function(String?)? validador;
  final IconData? icone;
  final int maxLinhas;

  const CampoTexto({
    super.key,
    required this.rotulo,
    this.dica,
    required this.controlador,
    this.obscuro = false,
    this.tipoTeclado = TextInputType.text,
    this.validador,
    this.icone,
    this.maxLinhas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controlador,
        obscureText: obscuro,
        keyboardType: tipoTeclado,
        validator: validador,
        maxLines: obscuro ? 1 : maxLinhas,
        decoration: InputDecoration(
          labelText: rotulo,
          hintText: dica,
          prefixIcon: icone != null ? Icon(icone) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
