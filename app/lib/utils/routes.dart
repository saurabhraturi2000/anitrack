import 'dart:developer';

import 'package:anilist_client/screens/profile/profile_screen.dart';
import 'package:anilist_client/utils/auth_provider.dart';
import 'package:anilist_client/widgets/scaffold_with_navbar.dart';
import 'package:anilist_client/screens/auth/login_screen.dart';
import 'package:anilist_client/screens/discover/discover_screen.dart';
import 'package:anilist_client/screens/discover/search_screen.dart';
import 'package:anilist_client/screens/home/home_screen.dart';
import 'package:anilist_client/screens/settings/appearance_screen.dart';
import 'package:anilist_client/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Routes {
  const Routes._();

  static const String _accessTokenKey = 'token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String notFound = '/404';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String discover = '/discover';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String appearance = '/appearance';

  static GoRouter buildRouter() {
    onExit(context, state) async {
      var exit = false;
      await ConfirmationDialog.show(
        context,
        title: 'Exit?',
        primaryAction: 'Yes',
        secondaryAction: 'No',
        onConfirm: () => exit = true,
      );

      return exit;
    }

    final routes = [
      GoRoute(
        path: "/",
        redirect: (context, state) async {
          final isAuthenticated = await _hasValidSession();
          return isAuthenticated ? Routes.home : Routes.discover;
        },
      ),
      GoRoute(
        path: splash,
        builder: (context, state) => const _SplashView(),
      ),
      GoRoute(
          path: "/auth",
          builder: (context, state) {
            final fragment = state.uri.fragment;
            log(fragment);
            if (fragment.isEmpty) return const _AuthView(null);

            final params = Uri.splitQueryString(fragment);
            final token = params['access_token'] ?? '';
            final expiration = int.tryParse(params['expires_in'] ?? '') ?? -1;
            if (token.isEmpty || expiration <= 0) return const _AuthView(null);

            return _AuthView((token, expiration));
          }),
      GoRoute(
        path: notFound,
        builder: (context, state) => const NotFoundView(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: discover,
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: search,
            builder: (context, state) => SearchScreen(
              initialCategory: state.uri.queryParameters['category'],
              scope: state.uri.queryParameters['scope'],
            ),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: appearance,
            builder: (context, state) => const AppearanceScreen(),
          ),
        ],
      ),
    ];
    return GoRouter(
      routes: routes,
      initialLocation: splash,
      errorBuilder: (context, state) => const NotFoundView(),
      debugLogDiagnostics: true,
    );
  }

  static Future<bool> _hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);
    if (token == null || expiryTimestamp == null) {
      return false;
    }

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    return DateTime.now().isBefore(expiryDate);
  }
}

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '404 Not Found',
              style: TextTheme.of(context).titleMedium,
            ),
            TextButton(
              child: const Text('Go Home'),
              onPressed: () => context.go(Routes.home),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => __SplashViewState();
}

class __SplashViewState extends State<_SplashView> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 900));
    final isAuthenticated = await Routes._hasValidSession();
    if (!mounted) return;
    context.go(isAuthenticated ? Routes.home : Routes.discover);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(
          Icons.flutter_dash,
          size: 92,
        ),
      ),
    );
  }
}

class _AuthView extends ConsumerStatefulWidget {
  const _AuthView(this.credentials);

  final (String token, int secondsUntilExpiration)? credentials;

  @override
  ConsumerState<_AuthView> createState() => __AuthViewState();
}

class __AuthViewState extends ConsumerState<_AuthView> {
  @override
  void initState() {
    super.initState();

    // On iOS the in app browser doesn't automatically close after login.
    closeInAppWebView().onError((_, __) {});

    if (widget.credentials == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        log('No credentials');
        // await ConfirmationDialog.show(context, title: 'Invalid credentials');
        // show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
          ),
        );
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) context.go(Routes.login);
      });
    }

    _attemptToFinishAccountSetup();
  }

  // @override
  // void didUpdateWidget(covariant _AuthView oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.credentials?.$1 != oldWidget.credentials?.$1 ||
  //       widget.credentials?.$2 != oldWidget.credentials?.$2) {
  //     // _attemptToFinishAccountSetup();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final expiration = DateTime.now().add(
      Duration(seconds: widget.credentials?.$2 ?? 0),
    );
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Authenticating, please wait...'),
            // show credentials
            SizedBox(height: 20),
            // Text('accesstoken: ${widget.credentials?.$1}'),
            // Text('accesstoken: ${expiration}'),
            CircularProgressIndicator()
            // Loader(),
          ],
        ),
      ),
    );
  }

  void _attemptToFinishAccountSetup() async {
    //save credentials
    if (widget.credentials == null) {
      return;
    }

    final token = widget.credentials!.$1;
    final expiration = DateTime.now().add(
      Duration(seconds: widget.credentials?.$2 ?? 0),
    );

    await ref
        .read(authStateProvider.notifier)
        .saveTokenAndAuthenticate(token, expiration);
    if (mounted) context.go(Routes.profile);
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog._({
    required this.title,
    required this.content,
    required this.primaryAction,
    required this.secondaryAction,
  });

  final String title;
  final String? content;
  final String primaryAction;
  final String? secondaryAction;

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? content,
    String primaryAction = 'Ok',
    String? secondaryAction,
    void Function()? onConfirm,
  }) =>
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog._(
          title: title,
          content: content,
          primaryAction: primaryAction,
          secondaryAction: secondaryAction,
        ),
      ).then((ok) => ok == true ? onConfirm?.call() : null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content != null ? Text(content!) : null,
      actions: [
        if (secondaryAction != null)
          TextButton(
            child: Text(secondaryAction!),
            onPressed: () => Navigator.pop(context, false),
          ),
        TextButton(
          child: Text(primaryAction),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
