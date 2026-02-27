import 'package:anitrack/models/collection_model.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeAnimeCard extends ConsumerStatefulWidget {
  const HomeAnimeCard({
    super.key,
    required this.data,
    this.onMarkProgress,
    this.onOpenDetails,
  });

  final Entry data;
  final Future<void> Function(int nextProgress)? onMarkProgress;
  final VoidCallback? onOpenDetails;

  @override
  ConsumerState<HomeAnimeCard> createState() => _HomeAnimeCardState();
}

class _HomeAnimeCardState extends ConsumerState<HomeAnimeCard> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final media = widget.data.media;
    final coverUrl = media?.coverImage?.large;
    final title = media?.title?.english ?? media?.title?.romaji ?? 'Untitled';
    final progress = widget.data.progress ?? 0;
    final totalEpisodes = media?.episodes;
    final nextEpisode = media?.nextAiringEpisode?.episode;
    final airingAt = media?.nextAiringEpisode?.airingAt;

    double progressValue = 0.0;
    final effectiveTotalEpisodes =
        (totalEpisodes != null && totalEpisodes > 0) ? totalEpisodes : progress;
    if (effectiveTotalEpisodes > 0) {
      progressValue = progress / effectiveTotalEpisodes;
      progressValue = progressValue.clamp(0.0, 1.0);
    }

    final progressText = totalEpisodes != null && totalEpisodes > 0
        ? '$progress / $totalEpisodes'
        : '$progress/?';
    final nextEpText = nextEpisode != null
        ? "Next Ep: $nextEpisode | ${_formatAiringAt(airingAt)}"
        : null;
    final releasedEpisodeCount = nextEpisode != null ? nextEpisode - 1 : -1;
    final isUpToDate = nextEpisode != null && progress >= releasedEpisodeCount;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      color: colors.surface.withValues(alpha: 0.95),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 76,
                height: 114,
                child: coverUrl == null || coverUrl.isEmpty
                    ? ColoredBox(
                        color: colors.surfaceAlt,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: colors.iconMuted,
                          ),
                        ),
                      )
                    : Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: colors.surfaceAlt,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: colors.iconMuted,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (nextEpText != null)
                    Text(
                      nextEpText,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 9,
                            backgroundColor: colors.divider,
                            color: colors.accent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        child: Center(
                          child: Text(
                            progressText,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colors.textMuted,
                                      fontSize: 11,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isUpToDate
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceAlt.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "You're up to date!",
                                style: TextStyle(
                                  color: colors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _isSaving || widget.onMarkProgress == null
                                  ? null
                                  : () async {
                                      setState(() => _isSaving = true);
                                      try {
                                        await widget.onMarkProgress!(progress + 1);
                                      } finally {
                                        if (mounted) {
                                          setState(() => _isSaving = false);
                                        }
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(color: colors.accent),
                                    color: colors.surface.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    Text(
                                      _isSaving ? '...' : (progress + 1).toString(),
                                      style: TextStyle(
                                          color: onSurface, fontSize: 13),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.check,
                                      size: 15,
                                      color: colors.accent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: widget.onOpenDetails ??
                            (media?.id == null
                                ? null
                                : () => context
                                    .push('${Routes.animeDetail}/${media!.id}')),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: colors.divider,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            Icons.more_horiz,
                            color: colors.iconMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAiringAt(int? airingAt) {
    if (airingAt == null) return 'TBA';
    final date = DateTime.fromMillisecondsSinceEpoch(airingAt * 1000).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'pm' : 'am';
    return '${date.day} $month, $hour12:$minute $period';
  }
}

