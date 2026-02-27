import 'dart:math';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class AniListOAuthException implements Exception {
  AniListOAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AniListOAuthCredentials {
  const AniListOAuthCredentials({
    required this.accessToken,
    required this.expiresInSeconds,
  });

  final String accessToken;
  final int expiresInSeconds;
}

class AniListOAuth {
  const AniListOAuth._();

  static const String clientId = '24352';
  static const String callbackUrlScheme = 'app';
  static const String _redirectUri = 'app://anisync/auth';

  static Future<AniListOAuthCredentials> login() async {
    final state = _randomState();
    final authUri = Uri.https('anilist.co', '/api/v2/oauth/authorize', {
      'client_id': clientId,
      'response_type': 'token',
      'state': state,
    });

    final callback = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: callbackUrlScheme,
      options: const FlutterWebAuth2Options(),
    );

    final callbackUri = Uri.parse(callback);
    final fragment = callbackUri.fragment;
    if (fragment.isEmpty) {
      throw AniListOAuthException('Missing OAuth token in callback URL.');
    }

    final params = Uri.splitQueryString(fragment);
    if (params['state'] != state) {
      throw AniListOAuthException('Invalid OAuth state.');
    }

    final token = params['access_token'];
    final expiresIn = int.tryParse(params['expires_in'] ?? '');
    if (token == null || token.isEmpty || expiresIn == null || expiresIn <= 0) {
      throw AniListOAuthException('Invalid OAuth response.');
    }

    return AniListOAuthCredentials(
      accessToken: token,
      expiresInSeconds: expiresIn,
    );
  }

  static String _randomState() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      32,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
