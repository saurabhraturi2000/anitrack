import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final data = await ApiService().request(
      GqlQuery.notifications,
      {'page': 1, 'perPage': 50},
    );

    final page = data['Page'] as Map<String, dynamic>?;
    final notifications = page?['notifications'] as List<dynamic>? ?? [];
    return notifications
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  },
);
