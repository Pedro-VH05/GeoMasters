import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> registerUser(String name, String email, String password) async {
    String? usersJson = await _storage.read(key: 'users');
    Map<String, dynamic> users = usersJson != null ? jsonDecode(usersJson) : {};

    if (users.containsKey(email)) {
      throw Exception('El correo ya está registrado.');
    }

    users[email] = {'name': name, 'password': password};

    await _storage.write(key: 'users', value: jsonEncode(users));
  }

  Future<bool> loginUser(String email, String password) async {
    String? usersJson = await _storage.read(key: 'users');
    if (usersJson == null) return false;

    Map<String, dynamic> users = jsonDecode(usersJson);
    if (users.containsKey(email) && users[email]['password'] == password) {
      await _storage.write(key: 'loggedInUser', value: email);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
  String? email = await _storage.read(key: 'loggedInUser');
  if (email == null) return null;

  String? usersJson = await _storage.read(key: 'users');
  if (usersJson == null) return null;

  Map<String, dynamic> users = jsonDecode(usersJson);
  if (users[email] == null) return null;

  // Devuelve todos los datos del usuario, incluyendo 'games'
  return {
    'name': users[email]['name'],
    'email': email,
    'games': users[email]['games'], // Incluye el campo 'games'
  };
}

  Future<void> logout() async {
    await _storage.delete(key: 'loggedInUser');
  }

  Future<bool> isLoggedIn() async {
    String? email = await _storage.read(key: 'loggedInUser');
    return email != null;
  }

  Future<void> saveGameResult(String gameType, int score, int time) async {
  String? email = await _storage.read(key: 'loggedInUser');
  if (email == null) return;

  String? usersJson = await _storage.read(key: 'users');
  if (usersJson == null) return;

  Map<String, dynamic> users = jsonDecode(usersJson);
  if (!users.containsKey(email)) return;

  // Asegurar que el usuario tiene una lista de juegos
  if (users[email]['games'] == null) {
    users[email]['games'] = [];
  }

  // Agregar el nuevo juego al historial
  users[email]['games'].add({
    'game': gameType,
    'score': score,
    'time': time,
    'date': DateTime.now().toIso8601String(),
  });

  await _storage.write(key: 'users', value: jsonEncode(users));
  print('Datos guardados: ${users[email]}');
}

}
