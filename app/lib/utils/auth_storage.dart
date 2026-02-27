import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  AuthStorage._();

  static final AuthStorage instance = AuthStorage._();

  static const _accessTokenKey = 'token';
  static const _tokenExpiryKey = 'token_expiry';

  static const _storage = FlutterSecureStorage();

  Future<void> saveSession(String token, int expiryTimestampMs) async {
    await _storage.write(key: _accessTokenKey, value: token);
    await _storage.write(
      key: _tokenExpiryKey,
      value: expiryTimestampMs.toString(),
    );
  }

  Future<String?> readAccessToken() async {
    var token = await _storage.read(key: _accessTokenKey);
    if (token != null && token.isNotEmpty) return token;

    // One-time migration from older shared preferences storage.
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_accessTokenKey);
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: _accessTokenKey, value: token);
      await prefs.remove(_accessTokenKey);
      return token;
    }
    return null;
  }

  Future<int?> readExpiryTimestamp() async {
    final raw = await _storage.read(key: _tokenExpiryKey);
    if (raw != null) return int.tryParse(raw);

    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getInt(_tokenExpiryKey);
    if (old != null) {
      await _storage.write(key: _tokenExpiryKey, value: old.toString());
      await prefs.remove(_tokenExpiryKey);
      return old;
    }
    return null;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
  }
}
