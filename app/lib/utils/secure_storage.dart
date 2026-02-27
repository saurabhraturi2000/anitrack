import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Saving Access Token
  Future setUserAccessToken(String key, String accessToken) async {
    await storage.write(key: key, value: accessToken);
  }

  // Fetching Access Token
  Future<String> getUserAccessToken(String key) async {
    String value = await storage.read(key: key) ?? "";
    return value;
  }
}
