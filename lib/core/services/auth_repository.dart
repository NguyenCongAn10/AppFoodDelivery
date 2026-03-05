import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() => _instance;

  AuthRepository._internal();

  final _storage = const FlutterSecureStorage();
  String? _accessToken;

  Future<String?> getToken() async {
    if (_accessToken != null) return _accessToken;
    _accessToken = await _storage.read(key: 'jwt_token');
    return _accessToken;
  }

  Future<void> saveToken(String token) async {
    _accessToken = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> saveFirebaseToken(String token) async {
    await saveToken(token);
  }

  Future<void> logout() async {
    _accessToken = null;
    await _storage.delete(key: 'jwt_token');
  }

  bool get hasToken => _accessToken != null;
}
