class AppConfig {
  const AppConfig._();

  // Provide from local run/build config:
  // flutter run --dart-define=ANILIST_CLIENT_ID=xxxxx
  static const String anilistClientId =
      String.fromEnvironment('ANILIST_CLIENT_ID');

  static bool get hasAniListClientId => anilistClientId.trim().isNotEmpty;
}
