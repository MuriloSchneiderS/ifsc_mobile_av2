import 'package:ifsc_mobile_av2/models/usuario.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioProvider with ChangeNotifier {
  final List<Usuario> _usuarios = [];
  final String _url = "https://project-2398835836236741984-default-rtdb.firebaseio.com/usuarios.json";

  List<Usuario> get usuarios => _usuarios;

  Future<void> fetchUsuarios() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _usuarios.clear();
        data.forEach((key, value) {
          _usuarios.add(Usuario.fromMap(value));
        });
        notifyListeners();
      } else {
        throw Exception('Failed to load usuários');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addUsuario(Usuario usuario) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        body: json.encode(usuario.toMap()),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        usuario = Usuario(
          id: data['name'],
          nome: usuario.nome,
          email: usuario.email,
          senha: usuario.senha,
        );
        _usuarios.add(usuario);
        notifyListeners();
      } else {
        throw Exception('Failed to add usuário');
      }
    } catch (e) {
      print(e);
    }
  }
}