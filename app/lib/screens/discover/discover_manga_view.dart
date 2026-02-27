import 'package:anitrack/screens/discover/providers/discover_state_provider.dart';
import 'package:anitrack/widgets/custom_headline.dart';
import 'package:anitrack/screens/discover/widgets/carousel_section.dart';
import 'package:anitrack/screens/discover/widgets/categories_section.dart';
import 'package:anitrack/screens/discover/widgets/popular_section.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverMangaView extends ConsumerWidget {
  const DiscoverMangaView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoverManga = ref.watch(discoverMangaProvider);

    return discoverManga.when(
      data: (data) {
        final trendingManga = data["trendingManga"];
        final popularManga = data["popularManga"];
        return SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            //carousel
            CarouselSection(
              data: trendingManga!,
              detailRouteBasePath: Routes.mangaDetail,
            ),
            SizedBox(height: 10),
            // QuickActions(),
            //genres
            CustomHeadline(title: "CATEGORIES"),
            CategoriesSection(
              onCategorySelected: (category) {
                context.push(
                  '${Routes.search}?category=${Uri.encodeComponent(category)}&scope=manga',
                );
              },
            ),
            CustomHeadline(
              title: "POPULAR",
            ),
            PopularSection(
              data: popularManga!,
              detailRouteBasePath: Routes.mangaDetail,
            ),
          ],
        ));
      },
      error: (error, stack) {
        return Center(child: Text(error.toString()));
      },
      loading: () {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

