import 'package:ifsc_mobile_av2/models/usuario.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class UsuarioProvider with ChangeNotifier {
  Usuario? _usuarioAtual;
  bool _carregando = false;
  String? _erro;

  static const String _baseUrl =
      'https://project-2398835836236741984-default-rtdb.firebaseio.com';

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<void> salvarUsuario(Usuario usuario) async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      // Salva ou atualiza pelo UID no Firebase
      final response = await http.put(
        Uri.parse('$_baseUrl/usuarios/${usuario.id}.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toMap()),
      );

      if (response.statusCode == 200) {
        _usuarioAtual = usuario;
      } else {
        _erro = 'Falha ao salvar perfil (${response.statusCode})';
      }
    } catch (e) {
      _erro = 'Erro ao salvar perfil: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<Usuario?> buscarUsuario(String uid) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/usuarios/$uid.json'));
      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _usuarioAtual = Usuario.fromMap(data);
        notifyListeners();
        return _usuarioAtual;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Obtém a localização atual do usuário (GPS)
  Future<Position?> obterLocalizacao() async {
    try {
      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) return null;
      }
      if (permissao == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void limpar() {
    _usuarioAtual = null;
    notifyListeners();
  }
}
