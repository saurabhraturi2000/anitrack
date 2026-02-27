import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class ThemeNotifier extends StateNotifier<int> {
  ThemeNotifier() : super(0) {
    _loadTheme();
  }

  ThemeData get currentTheme => AppThemes.themes[state];

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('themeIndex') ?? 0;
  }

  void changeTheme(int index) async {
    state = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', state);
  }
}

// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, int>(
  (ref) => ThemeNotifier(),
);
