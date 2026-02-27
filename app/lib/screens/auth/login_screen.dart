import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anitrack/utils/anilist_oauth.dart';
import 'package:anitrack/utils/auth_provider.dart';
import 'package:anitrack/utils/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final credentials = await AniListOAuth.login();
      final expiryDate = DateTime.now().add(
        Duration(seconds: credentials.expiresInSeconds),
      );

      await ref.read(authStateProvider.notifier).saveTokenAndAuthenticate(
            credentials.accessToken,
            expiryDate,
          );
      if (mounted) context.go(Routes.profile);
    } on AniListOAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.live_tv, size: 100.0),
            const SizedBox(height: 20.0),
            const Text(
              'Welcome to the AniList Client',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            TextButton(
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all<TextStyle>(
                  const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              onPressed: _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login with AniList'),
            ),
          ],
        ),
      ),
    );
  }
}

