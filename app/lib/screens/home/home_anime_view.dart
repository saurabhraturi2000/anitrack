import 'package:anitrack/screens/home/provider/home_state_provider.dart';
import 'package:anitrack/screens/home/widgets/home_anime_card.dart';
import 'package:anitrack/models/collection_model.dart';
import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CurrentAnimeView extends ConsumerWidget {
  const CurrentAnimeView({
    super.key,
    this.showFinished = true,
    this.bottomPadding = 0,
  });

  final bool showFinished;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAnimes = ref.watch(currentAnimesProvider);

    return currentAnimes.when(
      data: (data) {
        final releasingAnimes = (data["releasing"] as List?) ?? const [];
        final finishedAnimes = (data["finished"] as List?) ?? const [];
        return RefreshIndicator(
          onRefresh: () => ref.refresh(currentAnimesProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.live_tv_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "RELEASING",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: releasingAnimes.length,
                  itemBuilder: (context, index) {
                    final data = releasingAnimes[index];
                    return HomeAnimeCard(
                      data: data,
                      onMarkProgress: (nextProgress) => _saveProgress(
                        context,
                        ref,
                        data,
                        nextProgress,
                      ),
                      onOpenDetails: data.media?.id == null
                          ? null
                          : () => context.push(
                                '${Routes.animeDetail}/${data.media!.id}',
                              ),
                    );
                  },
                ),
                if (showFinished) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.done_all,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "FINISHED",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: finishedAnimes.length,
                    itemBuilder: (context, index) {
                      final data = finishedAnimes[index];
                      return HomeAnimeCard(
                        data: data,
                        onMarkProgress: (nextProgress) => _saveProgress(
                          context,
                          ref,
                          data,
                          nextProgress,
                        ),
                        onOpenDetails: data.media?.id == null
                            ? null
                            : () => context.push(
                                  '${Routes.animeDetail}/${data.media!.id}',
                                ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
      error: (error, stack) {
        // print(stack);
        return Center(
          child: Text(
            error.toString(),
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _saveProgress(
    BuildContext context,
    WidgetRef ref,
    Entry data,
    int nextProgress,
  ) async {
    final mediaId = data.media?.id;
    if (mediaId == null) return;

    final totalEpisodes = data.media?.episodes;
    final status = (totalEpisodes != null &&
            totalEpisodes > 0 &&
            nextProgress >= totalEpisodes)
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
      ref.invalidate(currentAnimesProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

