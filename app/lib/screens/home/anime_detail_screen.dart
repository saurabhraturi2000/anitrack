import 'package:anitrack/screens/home/provider/home_state_provider.dart';
import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animeDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, mediaId) async {
  final data = await ApiService().request(
    GqlQuery.mediaDetails,
    {'id': mediaId},
  );
  return Map<String, dynamic>.from(data['Media'] as Map? ?? const {});
});

class AnimeDetailScreen extends ConsumerStatefulWidget {
  const AnimeDetailScreen({super.key, required this.mediaId});

  final int mediaId;

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  bool _isMutating = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final mediaAsync = ref.watch(animeDetailProvider(widget.mediaId));
    final media = mediaAsync.valueOrNull;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: media == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _isMutating ? null : () => _openUpdateDrawer(media),
              backgroundColor: colors.accent,
              foregroundColor: colors.actionText,
              label: _isMutating
                  ? const Text('UPDATING...')
                  : Text(_statusLabel(media)),
            ),
      body: mediaAsync.when(
        data: (media) => _DetailBody(media: media),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(Map<String, dynamic> media) {
    final entry = media['mediaListEntry'] as Map<String, dynamic>?;
    if (entry == null) return 'ADD TO LIST';
    final status = entry['status']?.toString();
    return (status == null || status.isEmpty) ? 'CURRENT' : status;
  }

  Future<void> _openUpdateDrawer(Map<String, dynamic> media) async {
    final mediaId = (media['id'] as num?)?.toInt();
    if (mediaId == null) return;

    final episodes = (media['episodes'] as num?)?.toInt();
    final entry = media['mediaListEntry'] as Map<String, dynamic>? ?? const {};
    final listEntryId = (entry['id'] as num?)?.toInt();
    var selectedStatus = (entry['status']?.toString().isNotEmpty == true)
        ? entry['status'].toString()
        : 'CURRENT';
    var progress = (entry['progress'] as num?)?.toInt() ?? 0;
    final maxProgress = (episodes != null && episodes > 0) ? episodes : 9999;

    const statuses = <String>[
      'CURRENT',
      'COMPLETED',
      'PAUSED',
      'DROPPED',
      'PLANNING',
      'REPEATING',
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        final colors = AppColors.of(bottomSheetContext);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update List Entry',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: statuses.contains(selectedStatus)
                          ? selectedStatus
                          : 'CURRENT',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Status',
                      ),
                      items: statuses
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _isMutating
                              ? null
                              : () {
                                  setModalState(() {
                                    progress =
                                        (progress - 1).clamp(0, maxProgress);
                                  });
                                },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              episodes != null && episodes > 0
                                  ? '$progress / $episodes'
                                  : '$progress',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isMutating
                              ? null
                              : () {
                                  setModalState(() {
                                    progress =
                                        (progress + 1).clamp(0, maxProgress);
                                  });
                                },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.accent,
                          foregroundColor: colors.actionText,
                        ),
                        onPressed: _isMutating
                            ? null
                            : () async {
                                Navigator.of(bottomSheetContext).pop();
                                await _saveListEntry(
                                  mediaId: mediaId,
                                  status: selectedStatus,
                                  progress: progress,
                                );
                              },
                        child: const Text('Save Changes'),
                      ),
                    ),
                    if (listEntryId != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isMutating
                              ? null
                              : () async {
                                  Navigator.of(bottomSheetContext).pop();
                                  await _removeFromList(listEntryId);
                                },
                          child: const Text('Remove From List'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveListEntry({
    required int mediaId,
    required String status,
    required int progress,
  }) async {
    setState(() => _isMutating = true);
    try {
      await ApiService().request(
        GqlQuery.saveMediaListEntry,
        {
          'mediaId': mediaId,
          'progress': progress,
          'status': status,
        },
      );
      ref.invalidate(animeDetailProvider(widget.mediaId));
      ref.invalidate(currentAnimesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _removeFromList(int listEntryId) async {
    setState(() => _isMutating = true);
    try {
      await ApiService().request(
        GqlQuery.deleteMediaListEntry,
        {'id': listEntryId},
      );
      ref.invalidate(animeDetailProvider(widget.mediaId));
      ref.invalidate(currentAnimesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.media});

  final Map<String, dynamic> media;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final titleData = media['title'] as Map<String, dynamic>? ?? const {};
    final title = (titleData['english']?.toString().trim().isNotEmpty == true)
        ? titleData['english'].toString()
        : (titleData['romaji']?.toString() ?? 'Untitled');
    final nativeTitle = titleData['native']?.toString();
    final cover = (media['coverImage'] as Map<String, dynamic>?)?['large'];
    final banner = media['bannerImage']?.toString();
    final description = _cleanText(media['description']?.toString() ?? '');
    final genres =
        (media['genres'] as List?)?.map((e) => e.toString()).toList() ??
            const <String>[];
    final studiosData =
        (media['studios'] as Map<String, dynamic>?)?['nodes'] as List?;
    final studios = studiosData
            ?.whereType<Map>()
            .map((e) => e['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        const <String>[];
    final nextAiring = media['nextAiringEpisode'] as Map<String, dynamic>?;
    final nextEpisode = nextAiring?['episode']?.toString();
    final nextAiringAt = (nextAiring?['airingAt'] as num?)?.toInt();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          backgroundColor: colors.background,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: banner == null || banner.isEmpty
                ? Container(color: colors.surfaceAlt)
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(banner, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              colors.background.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 108,
                        height: 156,
                        child: cover == null || cover.toString().isEmpty
                            ? ColoredBox(color: colors.surfaceAlt)
                            : Image.network(cover.toString(),
                                fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                              label: media['type']?.toString() ?? 'MEDIA'),
                          _InfoChip(
                            label: media['format']?.toString() ?? 'UNKNOWN',
                          ),
                          _InfoChip(
                            label: media['status']?.toString() ?? 'UNKNOWN',
                          ),
                          _InfoChip(
                            label: media['episodes']?.toString() ??
                                media['duration']?.toString() ??
                                '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (nativeTitle != null && nativeTitle.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    nativeTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textMuted,
                        ),
                  ),
                ],
                const SizedBox(height: 16),
                _StatsRow(
                  score: media['averageScore']?.toString() ?? '-',
                  popularity: media['popularity']?.toString() ?? '-',
                  season:
                      '${media['season']?.toString() ?? ''} ${media['seasonYear']?.toString() ?? ''}'
                          .trim(),
                ),
                if (nextEpisode != null || nextAiringAt != null) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Next Airing'),
                  const SizedBox(height: 8),
                  Text(
                    nextEpisode == null
                        ? _formatDateTime(nextAiringAt)
                        : 'Episode $nextEpisode | ${_formatDateTime(nextAiringAt)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (genres.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Genres'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        genres.map((genre) => _InfoChip(label: genre)).toList(),
                  ),
                ],
                if (studios.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Studios'),
                  const SizedBox(height: 8),
                  Text(
                    studios.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const _SectionTitle(title: 'Overview'),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textMuted,
                          height: 1.45,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _cleanText(String input) {
    if (input.isEmpty) return input;
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('\n\n', '\n')
        .trim();
  }

  static String _formatDateTime(int? epochSeconds) {
    if (epochSeconds == null) return 'TBA';
    final date =
        DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000).toLocal();
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            letterSpacing: 0.7,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.divider),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.textMuted,
            ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.score,
    required this.popularity,
    required this.season,
  });

  final String score;
  final String popularity;
  final String season;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('Score', score),
      ('Popularity', popularity),
      ('Season', season.isEmpty ? '-' : season),
    ];
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.of(context).iconMuted,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
