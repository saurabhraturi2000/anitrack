import 'dart:async';

import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/auth_provider.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:anitrack/utils/local_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationPollerProvider = Provider<void>((ref) {
  unawaited(LocalNotificationService.instance.initialize());

  Timer? timer;

  Future<void> stopPolling() async {
    timer?.cancel();
    timer = null;
  }

  Future<void> startPolling() async {
    if (timer != null) return;

    await _checkForNewNotifications(ref);
    timer = Timer.periodic(
      const Duration(seconds: 90),
      (_) => _checkForNewNotifications(ref),
    );
  }

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
    next.whenData((state) {
      if (state == AuthState.authenticated) {
        unawaited(startPolling());
      } else {
        unawaited(stopPolling());
      }
    });
  });

  final currentAuth = ref.read(authStateProvider);
  if (currentAuth.hasValue && currentAuth.value == AuthState.authenticated) {
    unawaited(startPolling());
  }

  ref.onDispose(() {
    timer?.cancel();
  });
});

Future<void> _checkForNewNotifications(Ref ref) async {
  try {
    final data = await ApiService().request(
      GqlQuery.notifications,
      {'page': 1, 'perPage': 20},
    );

    final user = ref.read(userProvider);
    final userId = user?.id;
    if (userId == null) return;

    final page = data['Page'] as Map<String, dynamic>?;
    final notifications = (page?['notifications'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
    if (notifications.isEmpty) return;

    final ids = notifications
        .map((n) => (n['id'] as num?)?.toInt())
        .whereType<int>()
        .toList(growable: false);
    if (ids.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'last_seen_notification_id_$userId';
    final lastSeenId = prefs.getInt(key);
    final newestId = ids.reduce((a, b) => a > b ? a : b);

    // First launch baseline: don't spam old notifications.
    if (lastSeenId == null) {
      await prefs.setInt(key, newestId);
      return;
    }

    final fresh = notifications
        .where((n) => ((n['id'] as num?)?.toInt() ?? 0) > lastSeenId)
        .toList(growable: false);

    if (fresh.isNotEmpty) {
      final sorted = [...fresh]
        ..sort((a, b) => ((a['id'] as num?)?.toInt() ?? 0)
            .compareTo((b['id'] as num?)?.toInt() ?? 0));

      for (final n in sorted.take(5)) {
        final id = (n['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch;
        final title = _notificationTitle(n);
        final body = _notificationBody(n);
        await LocalNotificationService.instance.show(
          id: id,
          title: title,
          body: body,
        );
      }
    }

    await prefs.setInt(key, newestId);
  } catch (_) {
    // Polling failures are non-fatal for app flow.
  }
}

String _notificationTitle(Map<String, dynamic> item) {
  final type = item['type']?.toString() ?? 'NOTIFICATION';
  return type.replaceAll('_', ' ');
}

String _notificationBody(Map<String, dynamic> item) {
  final user = (item['user'] as Map<String, dynamic>?)?['name']?.toString();
  final mediaTitleData = (item['media'] as Map<String, dynamic>?)?['title']
      as Map<String, dynamic>?;
  final mediaTitle =
      mediaTitleData?['english']?.toString().trim().isNotEmpty == true
          ? mediaTitleData!['english'].toString()
          : (mediaTitleData?['romaji']?.toString() ?? '');

  if (user != null && mediaTitle.isNotEmpty) return '$user - $mediaTitle';
  if (user != null) return user;
  if (mediaTitle.isNotEmpty) return mediaTitle;
  return 'You have a new AniList notification.';
}
