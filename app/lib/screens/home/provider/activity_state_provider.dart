import 'package:anilist_client/utils/api_service.dart';
import 'package:anilist_client/utils/auth_provider.dart';
import 'package:anilist_client/utils/graphql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recentActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final user = ref.watch(userProvider);
    if (user == null) return const <Map<String, dynamic>>[];

    final data = await ApiService().request(
      GqlQuery.recentActivities,
      {'userId': user.id},
    );

    final page = data['Page'] as Map<String, dynamic>?;
    final activities = page?['activities'] as List<dynamic>? ?? [];
    return activities
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  },
);
