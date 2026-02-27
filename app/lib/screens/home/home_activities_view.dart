import 'package:anitrack/screens/home/provider/activity_state_provider.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeActivitiesView extends ConsumerWidget {
  const HomeActivitiesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Text(
              'No recent activities yet.',
              style: TextStyle(color: colors.textMuted),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            return _ActivityCard(activity: activities[index]);
          },
        );
      },
      error: (error, _) => Center(
        child: Text(
          error.toString(),
          style: TextStyle(color: colors.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final Map<String, dynamic> activity;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final type = activity['__typename']?.toString() ?? '';
    final createdAt = (activity['createdAt'] as num?)?.toInt();
    final createdText = _timeAgo(createdAt);

    final parsed = _parse(type, activity);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadingAvatar(imageUrl: parsed.imageUrl, icon: parsed.fallbackIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parsed.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  parsed.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            createdText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.iconMuted,
                ),
          ),
        ],
      ),
    );
  }

  _ParsedActivity _parse(String type, Map<String, dynamic> activity) {
    if (type == 'ListActivity') {
      final media = activity['media'] as Map<String, dynamic>?;
      final titleData = media?['title'] as Map<String, dynamic>?;
      final mediaTitle =
          titleData?['english']?.toString().trim().isNotEmpty == true
              ? titleData!['english'].toString()
              : (titleData?['romaji']?.toString() ?? 'Updated list');
      final status = activity['status']?.toString() ?? 'Updated';
      final progress = activity['progress']?.toString() ?? '';
      final subtitle = progress.isEmpty ? status : '$status $progress';
      final cover =
          (media?['coverImage'] as Map<String, dynamic>?)?['large']?.toString();
      final mediaType = media?['type']?.toString() ?? '';
      final icon = mediaType == 'MANGA'
          ? Icons.menu_book_rounded
          : Icons.live_tv_rounded;
      return _ParsedActivity(
        title: mediaTitle,
        subtitle: subtitle,
        imageUrl: cover,
        fallbackIcon: icon,
      );
    }

    if (type == 'TextActivity') {
      final user = activity['user'] as Map<String, dynamic>?;
      final text = activity['text']?.toString().replaceAll('\n', ' ') ?? '';
      return _ParsedActivity(
        title: user?['name']?.toString() ?? 'Text activity',
        subtitle: text.isEmpty ? 'Posted an update' : text,
        imageUrl:
            (user?['avatar'] as Map<String, dynamic>?)?['large']?.toString(),
        fallbackIcon: Icons.edit_note_rounded,
      );
    }

    if (type == 'MessageActivity') {
      final user = activity['messenger'] as Map<String, dynamic>?;
      final message =
          activity['message']?.toString().replaceAll('\n', ' ') ?? '';
      return _ParsedActivity(
        title: user?['name']?.toString() ?? 'Message',
        subtitle: message.isEmpty ? 'Sent a message' : message,
        imageUrl:
            (user?['avatar'] as Map<String, dynamic>?)?['large']?.toString(),
        fallbackIcon: Icons.mark_chat_unread_outlined,
      );
    }

    return const _ParsedActivity(
      title: 'Activity',
      subtitle: 'Recent update',
      imageUrl: null,
      fallbackIcon: Icons.history,
    );
  }

  String _timeAgo(int? epochSeconds) {
    if (epochSeconds == null) return '';
    final now = DateTime.now();
    final then = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    final diff = now.difference(then);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

class _LeadingAvatar extends StatelessWidget {
  const _LeadingAvatar({required this.imageUrl, required this.icon});

  final String? imageUrl;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 44,
        child: imageUrl == null || imageUrl!.isEmpty
            ? ColoredBox(
                color: colors.surfaceAlt,
                child: Icon(icon, color: colors.iconMuted, size: 22),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: colors.surfaceAlt,
                  child: Icon(icon, color: colors.iconMuted, size: 22),
                ),
              ),
      ),
    );
  }
}

class _ParsedActivity {
  const _ParsedActivity({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.fallbackIcon,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData fallbackIcon;
}

