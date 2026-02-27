import 'package:anilist_client/utils/appearance_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppearanceState {
  const AppearanceState({
    required this.style,
    required this.themeMode,
    required this.fontScale,
  });

  final AppStyle style;
  final ThemeMode themeMode;
  final double fontScale;

  AppearanceState copyWith({
    AppStyle? style,
    ThemeMode? themeMode,
    double? fontScale,
  }) {
    return AppearanceState(
      style: style ?? this.style,
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

class AppearanceNotifier extends StateNotifier<AppearanceState> {
  AppearanceNotifier()
      : super(
          const AppearanceState(
            style: AppStyle.anilist,
            themeMode: ThemeMode.dark,
            fontScale: 1,
          ),
        ) {
    _load();
  }

  static const _styleKey = 'appearance.style';
  static const _modeKey = 'appearance.mode';
  static const _fontScaleKey = 'appearance.fontScale';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt(_styleKey) ?? 0;
    final modeIndex = prefs.getInt(_modeKey) ?? ThemeMode.dark.index;
    final fontScale = prefs.getDouble(_fontScaleKey) ?? 1;

    state = AppearanceState(
      style: AppStyle.values[styleIndex.clamp(0, AppStyle.values.length - 1)],
      themeMode: ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
      fontScale: fontScale.clamp(0.8, 1.4),
    );
  }

  Future<void> setStyle(AppStyle style) async {
    state = state.copyWith(style: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_styleKey, style.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
  }

  Future<void> setFontScale(double scale) async {
    final normalized = scale.clamp(0.8, 1.4);
    state = state.copyWith(fontScale: normalized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, normalized);
  }
}

final appearanceProvider = StateNotifierProvider<AppearanceNotifier, AppearanceState>(
  (ref) => AppearanceNotifier(),
);
