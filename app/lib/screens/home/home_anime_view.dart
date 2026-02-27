import 'package:anilist_client/screens/home/provider/home_state_provider.dart';
import 'package:anilist_client/screens/home/widgets/home_anime_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        return SingleChildScrollView(
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
                  return HomeAnimeCard(data: data);
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
                  itemCount: finishedAnimes.length,
                  itemBuilder: (context, index) {
                    final data = finishedAnimes[index];
                    return HomeAnimeCard(data: data);
                  },
                ),
              ],
            ],
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
}
