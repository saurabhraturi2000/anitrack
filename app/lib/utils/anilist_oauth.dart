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
  static const int _fallbackManualExpirySeconds = 3600;

  static Future<AniListOAuthCredentials> login() async {
    final state = generateState();
    final authUri = buildAuthorizationUri(state: state);

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

  static String generateState() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      32,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static Uri buildAuthorizationUri({String? state}) {
    final params = <String, String>{
      'client_id': clientId,
      'response_type': 'token',
    };
    if (state != null && state.isNotEmpty) {
      params['state'] = state;
    }
    return Uri.https('anilist.co', '/api/v2/oauth/authorize', params);
  }

  static AniListOAuthCredentials parseManualInput({
    required String input,
    String? expectedState,
  }) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw AniListOAuthException(
          'Please paste a callback URL or access token.');
    }

    Map<String, String> params = {};

    if (raw.startsWith('#')) {
      params = Uri.splitQueryString(raw.substring(1));
    } else {
      try {
        final parsedUri = Uri.parse(raw);
        if (parsedUri.fragment.isNotEmpty) {
          params = Uri.splitQueryString(parsedUri.fragment);
        } else if (parsedUri.query.isNotEmpty) {
          params = parsedUri.queryParameters;
        }
      } catch (_) {}
    }

    var token = params['access_token'];
    final expiresFromParams = int.tryParse(params['expires_in'] ?? '');

    if (token == null || token.isEmpty) {
      final looksLikeToken = !raw.contains(RegExp(r'[\s=&?#]'));
      if (!looksLikeToken) {
        throw AniListOAuthException(
          'Could not find access token. Paste callback URL, fragment, or token.',
        );
      }
      token = raw;
    }

    if (expectedState != null &&
        expectedState.isNotEmpty &&
        params['state'] != null &&
        params['state'] != expectedState) {
      throw AniListOAuthException(
        'State mismatch. Regenerate the URL and try again.',
      );
    }

    return AniListOAuthCredentials(
      accessToken: token,
      expiresInSeconds: (expiresFromParams != null && expiresFromParams > 0)
          ? expiresFromParams
          : _fallbackManualExpirySeconds,
    );
  }
}
