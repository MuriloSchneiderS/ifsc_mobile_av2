import 'package:flutter/material.dart';

class TelaBookmarks extends StatelessWidget {
  const TelaBookmarks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0E8),
        elevation: 0,
        title: const Text('Bookmarks'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_outline, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Nenhum bookmark ainda.',
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            Text('Salve publicações tocando em 🔖 na tela de leitura.',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
