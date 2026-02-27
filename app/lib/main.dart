import 'package:anitrack/utils/routes.dart';
import 'package:anitrack/utils/appearance_provider.dart';
import 'package:anitrack/utils/appearance_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static final GoRouter _router = Routes.buildRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'anitrack',
      theme: AppThemeFactory.buildTheme(
        style: appearance.style,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
      ),
      darkTheme: AppThemeFactory.buildTheme(
        style: appearance.style,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: appearance.themeMode,
      routerConfig: _router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(appearance.fontScale),
          ),
          child: child!,
        );
      },
    );
  }
}


