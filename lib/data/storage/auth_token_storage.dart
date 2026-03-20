import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _keyAccessToken = 'access_token';

  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _keyAccessToken);
  }
}