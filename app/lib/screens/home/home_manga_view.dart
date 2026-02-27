import 'package:anitrack/models/collection_model.dart';
import 'package:anitrack/screens/home/provider/home_state_provider.dart';
import 'package:anitrack/screens/home/widgets/home_anime_card.dart';
import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CurrentMangaView extends ConsumerStatefulWidget {
  const CurrentMangaView({
    super.key,
    this.showFinished = true,
    this.bottomPadding = 0,
  });

  final bool showFinished;
  final double bottomPadding;

  @override
  ConsumerState<CurrentMangaView> createState() => _CurrentMangaViewState();
}

class _CurrentMangaViewState extends ConsumerState<CurrentMangaView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      ref.read(currentMangaFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(currentMangaFeedProvider);
    final releasingMangas = feed.releasingEntries;
    final finishedMangas = feed.finishedEntries;

    if (feed.isInitialLoading && !feed.hasLoadedAnything) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feed.errorMessage != null && !feed.hasLoadedAnything) {
      return Center(child: Text(feed.errorMessage!));
    }

    final children = <Widget>[
      _sectionHeader(
        context,
        icon: Icons.menu_book_rounded,
        title: 'RELEASING',
      ),
      ...releasingMangas.map(
        (entry) => HomeAnimeCard(
          data: entry,
          onMarkProgress: (nextProgress) =>
              _saveProgress(context, entry, nextProgress),
          onOpenDetails: entry.media?.id == null
              ? null
              : () => context.push(
                    '${Routes.mangaDetail}/${entry.media!.id}',
                  ),
        ),
      ),
    ];

    if (widget.showFinished && feed.showFinishedSection) {
      children.addAll([
        _sectionHeader(
          context,
          icon: Icons.done_all,
          title: 'FINISHED',
        ),
        ...finishedMangas.map(
          (entry) => HomeAnimeCard(
            data: entry,
            onMarkProgress: (nextProgress) =>
                _saveProgress(context, entry, nextProgress),
            onOpenDetails: entry.media?.id == null
                ? null
                : () => context.push(
                      '${Routes.mangaDetail}/${entry.media!.id}',
                    ),
          ),
        ),
      ]);
    }

    if (feed.isLoadingMore) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (feed.errorMessage != null && feed.hasLoadedAnything) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            feed.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    children.add(SizedBox(height: widget.bottomPadding));

    return RefreshIndicator(
      onRefresh: ref.read(currentMangaFeedProvider.notifier).refresh,
      child: ListView(
        controller: _scrollController,
        children: children,
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProgress(
    BuildContext context,
    Entry entry,
    int nextProgress,
  ) async {
    final mediaId = entry.media?.id;
    if (mediaId == null) return;

    final totalChapters = entry.media?.episodes;
    final status = (totalChapters != null &&
            totalChapters > 0 &&
            nextProgress >= totalChapters)
        ? 'COMPLETED'
        : 'CURRENT';

    try {
      await ApiService().request(
        GqlQuery.saveMediaListEntry,
        {
          'mediaId': mediaId,
          'progress': nextProgress,
          'status': status,
        },
      );
      await ref.read(currentMangaFeedProvider.notifier).refresh();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

