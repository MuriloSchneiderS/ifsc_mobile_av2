import 'package:flutter/material.dart';

class BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback? aoTocar;
  final bool carregando;
  final IconData? icone;

  const BotaoPrimario({
    super.key,
    required this.texto,
    this.aoTocar,
    this.carregando = false,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: carregando ? null : aoTocar,
        icon: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : (icone != null ? Icon(icone) : const SizedBox.shrink()),
        label: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
