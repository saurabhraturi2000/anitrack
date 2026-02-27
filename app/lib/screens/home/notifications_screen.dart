import 'package:anitrack/screens/home/provider/notifications_state_provider.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(notificationsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: colors.textMuted),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(notificationsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _NotificationCard(notification: notifications[index]);
              },
            ),
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error.toString(),
              style: TextStyle(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final parsed = _parse(notification);
    final createdAt = (notification['createdAt'] as num?)?.toInt();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadingAvatar(imageUrl: parsed.imageUrl, icon: parsed.icon),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _timeAgo(createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.iconMuted,
                ),
          ),
        ],
      ),
    );
  }

  _ParsedNotification _parse(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? item['__typename']?.toString() ?? '';
    final user = item['user'] as Map<String, dynamic>?;
    final media = item['media'] as Map<String, dynamic>?;
    final thread = item['thread'] as Map<String, dynamic>?;

    final userName = user?['name']?.toString();
    final userAvatar =
        (user?['avatar'] as Map<String, dynamic>?)?['large']?.toString();

    final mediaTitleData = media?['title'] as Map<String, dynamic>?;
    final mediaTitle =
        mediaTitleData?['english']?.toString().trim().isNotEmpty == true
            ? mediaTitleData!['english'].toString()
            : (mediaTitleData?['romaji']?.toString() ?? 'Media');
    final mediaCover =
        (media?['coverImage'] as Map<String, dynamic>?)?['large']?.toString();

    switch (type) {
      case 'AIRING':
        final episode = item['episode']?.toString() ?? '';
        return _ParsedNotification(
          title: mediaTitle,
          subtitle: episode.isEmpty
              ? 'New episode aired.'
              : 'Episode $episode is now available.',
          imageUrl: mediaCover,
          icon: Icons.live_tv_rounded,
        );
      case 'FOLLOWING':
        return _ParsedNotification(
          title: userName ?? 'New follower',
          subtitle: 'Started following you.',
          imageUrl: userAvatar,
          icon: Icons.person_add_alt_1_rounded,
        );
      case 'ACTIVITY_MESSAGE':
      case 'ACTIVITY_MENTION':
      case 'ACTIVITY_REPLY':
      case 'ACTIVITY_REPLY_SUBSCRIBED':
        return _ParsedNotification(
          title: userName ?? 'Activity update',
          subtitle: 'Interacted with your activity.',
          imageUrl: userAvatar,
          icon: Icons.mark_chat_unread_outlined,
        );
      case 'ACTIVITY_LIKE':
      case 'ACTIVITY_REPLY_LIKE':
        return _ParsedNotification(
          title: userName ?? 'New like',
          subtitle: 'Liked your activity.',
          imageUrl: userAvatar,
          icon: Icons.favorite_border_rounded,
        );
      case 'THREAD_COMMENT_MENTION':
      case 'THREAD_COMMENT_REPLY':
      case 'THREAD_COMMENT_SUBSCRIBED':
      case 'THREAD_COMMENT_LIKE':
      case 'THREAD_LIKE':
      case 'THREAD_SUBSCRIBED':
        return _ParsedNotification(
          title: thread?['title']?.toString() ?? 'Thread update',
          subtitle: userName != null ? '$userName interacted on a thread.' : 'Thread interaction.',
          imageUrl: userAvatar,
          icon: Icons.forum_outlined,
        );
      case 'RELATED_MEDIA_ADDITION':
      case 'MEDIA_DATA_CHANGE':
      case 'MEDIA_MERGE':
      case 'MEDIA_DELETION':
        return _ParsedNotification(
          title: item['deletedMediaTitle']?.toString() ?? mediaTitle,
          subtitle: item['context']?.toString() ?? 'Media update.',
          imageUrl: mediaCover,
          icon: Icons.auto_awesome_motion_rounded,
        );
      default:
        return _ParsedNotification(
          title: userName ?? mediaTitle,
          subtitle: type.isEmpty ? 'Notification' : type.replaceAll('_', ' '),
          imageUrl: userAvatar ?? mediaCover,
          icon: Icons.notifications_none_rounded,
        );
    }
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

class _ParsedNotification {
  const _ParsedNotification({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData icon;
}
