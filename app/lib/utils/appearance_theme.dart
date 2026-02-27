import 'package:flutter/material.dart';

enum AppStyle { anilist, komori, crimson }

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.accent,
    required this.textMuted,
    required this.iconMuted,
    required this.divider,
    required this.actionText,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color accent;
  final Color textMuted;
  final Color iconMuted;
  final Color divider;
  final Color actionText;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? accent,
    Color? textMuted,
    Color? iconMuted,
    Color? divider,
    Color? actionText,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      accent: accent ?? this.accent,
      textMuted: textMuted ?? this.textMuted,
      iconMuted: iconMuted ?? this.iconMuted,
      divider: divider ?? this.divider,
      actionText: actionText ?? this.actionText,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t) ?? iconMuted,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      actionText: Color.lerp(actionText, other.actionText, t) ?? actionText,
    );
  }
}

class AppThemeFactory {
  const AppThemeFactory._();

  static AppPalette paletteFor(AppStyle style, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (style) {
      case AppStyle.anilist:
        return isDark
            ? const AppPalette(
                background: Color(0xFF041A2A),
                surface: Color(0xFF16223A),
                surfaceAlt: Color(0xFF1F3657),
                accent: Color(0xFF3DB6FF),
                textMuted: Color(0xFFC0CAD9),
                iconMuted: Color(0xFF9FB0C7),
                divider: Color(0xFF0C1A2F),
                actionText: Color(0xFF071524),
              )
            : const AppPalette(
                background: Color(0xFFEFF7FF),
                surface: Color(0xFFFFFFFF),
                surfaceAlt: Color(0xFFDDEEFF),
                accent: Color(0xFF007EDB),
                textMuted: Color(0xFF4B6178),
                iconMuted: Color(0xFF67829D),
                divider: Color(0xFFD3E3F3),
                actionText: Color(0xFFFFFFFF),
              );
      case AppStyle.komori:
        return isDark
            ? const AppPalette(
                background: Color(0xFF161124),
                surface: Color(0xFF221B35),
                surfaceAlt: Color(0xFF31284C),
                accent: Color(0xFFFF6EB4),
                textMuted: Color(0xFFD8CCE7),
                iconMuted: Color(0xFFB5A8C8),
                divider: Color(0xFF3A2E54),
                actionText: Color(0xFF250E1E),
              )
            : const AppPalette(
                background: Color(0xFFFFF1F8),
                surface: Color(0xFFFFFFFF),
                surfaceAlt: Color(0xFFF9DBEA),
                accent: Color(0xFFD94E95),
                textMuted: Color(0xFF6A4A61),
                iconMuted: Color(0xFF88627D),
                divider: Color(0xFFF0CFE1),
                actionText: Color(0xFFFFFFFF),
              );
      case AppStyle.crimson:
        return isDark
            ? const AppPalette(
                background: Color(0xFF1B0A13),
                surface: Color(0xFF2A1220),
                surfaceAlt: Color(0xFF3A1A2D),
                accent: Color(0xFFFF4D7A),
                textMuted: Color(0xFFE2C4CF),
                iconMuted: Color(0xFFC39CAB),
                divider: Color(0xFF4B2438),
                actionText: Color(0xFF2A0B19),
              )
            : const AppPalette(
                background: Color(0xFFFFF0F4),
                surface: Color(0xFFFFFFFF),
                surfaceAlt: Color(0xFFFBD9E3),
                accent: Color(0xFFD63563),
                textMuted: Color(0xFF72495A),
                iconMuted: Color(0xFF8F6072),
                divider: Color(0xFFF2CBD7),
                actionText: Color(0xFFFFFFFF),
              );
    }
  }

  static ThemeData buildTheme({
    required AppStyle style,
    required Brightness brightness,
    required String fontFamily,
  }) {
    final palette = paletteFor(style, brightness);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: brightness,
      ).copyWith(
        primary: palette.accent,
        secondary: palette.accent,
        surface: palette.surface,
      ),
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.accent,
        unselectedItemColor: palette.iconMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        side: BorderSide(color: palette.divider),
        labelStyle: TextStyle(color: palette.textMuted),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.accent,
        thumbColor: palette.accent,
        inactiveTrackColor: palette.divider,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.actionText
                : palette.textMuted,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.accent
                : palette.surface,
          ),
          side: WidgetStateProperty.all(BorderSide(color: palette.divider)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );

    return base.copyWith(
      extensions: [palette],
    );
  }
}
