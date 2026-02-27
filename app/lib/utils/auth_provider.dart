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
  static const _viewerIdKey = 'viewer_id';
  static const _viewerNameKey = 'viewer_name';
  static const _viewerAvatarKey = 'viewer_avatar';
  static const _viewerBannerKey = 'viewer_banner';

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

    final cachedViewer = _readCachedViewer(prefs);
    if (cachedViewer != null) {
      ref.read(userProvider.notifier).state = cachedViewer;
    }

    try {
      final viewerData = await _fetchViewerData(token);
      ref.read(userProvider.notifier).state = viewerData;
      await _cacheViewer(viewerData);
    } catch (e) {
      // Keep user logged in if token is still valid, even if profile fetch fails.
    }

    return AuthState.authenticated;
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
      await _cacheViewer(viewerData);
      state = AsyncData(AuthState.authenticated);
    } catch (e) {
      // Token is already stored and valid; do not force logout on transient API failure.
      state = AsyncData(AuthState.authenticated);
    }
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_viewerIdKey);
    await prefs.remove(_viewerNameKey);
    await prefs.remove(_viewerAvatarKey);
    await prefs.remove(_viewerBannerKey);
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
      final viewer = json['data']?['Viewer'];
      if (viewer is Map<String, dynamic>) {
        return Viewer.fromJson(viewer);
      }
      throw Exception('Invalid viewer response');
    } else {
      throw Exception('Failed to fetch viewer data');
    }
  }

  Future<void> _cacheViewer(Viewer viewer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_viewerIdKey, viewer.id);
    await prefs.setString(_viewerNameKey, viewer.name);
    await prefs.setString(_viewerAvatarKey, viewer.avatarUrl);
    await prefs.setString(_viewerBannerKey, viewer.bannerImage ?? '');
  }

  Viewer? _readCachedViewer(SharedPreferences prefs) {
    final id = prefs.getInt(_viewerIdKey);
    final name = prefs.getString(_viewerNameKey);
    final avatar = prefs.getString(_viewerAvatarKey);
    final banner = prefs.getString(_viewerBannerKey);

    if (id == null || name == null || avatar == null) {
      return null;
    }

    return Viewer(
      id: id,
      name: name,
      avatarUrl: avatar,
      bannerImage: banner,
    );
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
