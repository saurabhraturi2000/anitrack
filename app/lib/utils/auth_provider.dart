import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Auth state provider
final authStateProvider =
    AsyncNotifierProvider<CurrentAuthState, AuthState>(CurrentAuthState.new);

// User provider (stores Viewer data)
final userProvider = StateProvider<Viewer?>((ref) => null);

class CurrentAuthState extends AsyncNotifier<AuthState> {
  static const _accessTokenKey = 'token';
  static const _tokenExpiryKey = 'token_expiry';

  @override
  Future<AuthState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);

    if (token == null || expiryTimestamp == null) {
      return AuthState.unauthenticated;
    }

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    if (DateTime.now().isAfter(expiryDate)) {
      await _clearToken();
      return AuthState.unauthenticated;
    }

    try {
      final viewerData = await _fetchViewerData(token);

      // Store user data in userProvider
      ref.read(userProvider.notifier).state = viewerData;

      return AuthState.authenticated;
    } catch (e) {
      return AuthState.unauthenticated;
    }
  }

  /// **Function to save token, expiry date, and authenticate the user**
  Future<void> saveTokenAndAuthenticate(
      String token, DateTime expiryDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    await prefs.setInt(_tokenExpiryKey, expiryDate.millisecondsSinceEpoch);

    try {
      final viewerData = await _fetchViewerData(token);
      ref.read(userProvider.notifier).state = viewerData;
      state = AsyncData(AuthState.authenticated);
    } catch (e) {
      state = AsyncData(AuthState.unauthenticated);
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_tokenExpiryKey);
    ref.read(userProvider.notifier).state = null;
  }

  Future<void> logout() async {
    await _clearToken();
    state = const AsyncData(AuthState.unauthenticated);
  }

  Future<Viewer> _fetchViewerData(String token) async {
    const url = 'https://graphql.anilist.co';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'query': '''
          query {
            Viewer {
              id
              name
              avatar {
                large
              }
              bannerImage
            }
          }
        '''
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Viewer.fromJson(json['data']['Viewer']);
    } else {
      throw Exception('Failed to fetch viewer data');
    }
  }
}

class Viewer {
  final int id;
  final String name;
  final String avatarUrl;
  final String? bannerImage;

  Viewer(
      {required this.id,
      required this.name,
      required this.avatarUrl,
      this.bannerImage});

  factory Viewer.fromJson(Map<String, dynamic> json) {
    return Viewer(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatar']['large'] ?? '',
      bannerImage: json['bannerImage'] ?? "",
    );
  }
}

enum AuthState { authenticated, unauthenticated }
