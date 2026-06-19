import 'package:ifsc_mobile_av2/models/publicacao.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PublicacaoProvider with ChangeNotifier {
  final List<Publicacao> _publicacoes = [];
  final String _url = "https://project-2398835836236741984-default-rtdb.firebaseio.com/publicacoes.json";

  List<Publicacao> get publicacoes => _publicacoes;

  Future<void> fetchPublicacoes() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _publicacoes.clear();
        data.forEach((key, value) {
          _publicacoes.add(Publicacao.fromMap(value));
        });
        notifyListeners();
      } else {
        throw Exception('Failed to load publicações');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addPublicacao(Publicacao publicacao) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: json.encode(publicacao.toMap()),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        publicacao = Publicacao(
          id: data['name'],
          titulo: publicacao.titulo,
          descricao: publicacao.descricao,
          arquivo: publicacao.arquivo,
          miniatura: publicacao.miniatura,
          usuario: publicacao.usuario,
        );
        _publicacoes.add(publicacao);
        notifyListeners();
      } else {
        throw Exception('Failed to add publicação');
      }
    } catch (e) {
      print(e);
    }
  }
}