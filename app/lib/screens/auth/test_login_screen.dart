import 'package:anitrack/utils/anilist_oauth.dart';
import 'package:anitrack/utils/auth_provider.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class TestLoginScreen extends ConsumerStatefulWidget {
  const TestLoginScreen({super.key});

  @override
  ConsumerState<TestLoginScreen> createState() => _TestLoginScreenState();
}

class _TestLoginScreenState extends ConsumerState<TestLoginScreen> {
  final _manualInputController = TextEditingController();
  late Uri _authUri;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _regenerateAuthUrl();
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  void _regenerateAuthUrl() {
    _authUri = AniListOAuth.buildAuthorizationUri();
  }

  Future<void> _openInBrowser() async {
    final launched = await launchUrl(
      _authUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open browser. Copy URL manually.')),
      );
    }
  }

  Future<void> _submitManualLogin() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final credentials = AniListOAuth.parseManualInput(
        input: _manualInputController.text,
      );
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
        const SnackBar(content: Text('Manual login failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Login')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test-only emulator login',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '1) Open URL in browser and login.\n'
            '2) Copy full callback URL (or access token).\n'
            '3) Paste below and submit.',
          ),
          const SizedBox(height: 16),
          SelectableText(_authUri.toString()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open in Browser'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _authUri.toString()),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login URL copied')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy URL'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(_regenerateAuthUrl);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate URL'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _manualInputController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Callback URL / fragment / token',
              hintText: 'app://anitrack/auth#access_token=...',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitManualLogin,
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Complete Test Login'),
          ),
        ],
      ),
    );
  }
}
