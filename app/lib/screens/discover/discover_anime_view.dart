import 'package:anitrack/screens/discover/providers/discover_state_provider.dart';
import 'package:anitrack/widgets/custom_headline.dart';
import 'package:anitrack/screens/discover/widgets/carousel_section.dart';
import 'package:anitrack/screens/discover/widgets/categories_section.dart';
import 'package:anitrack/screens/discover/widgets/popular_section.dart';
import 'package:anitrack/screens/discover/widgets/upcoming_section.dart';
import 'package:anitrack/utils/app_colors.dart';
import 'package:anitrack/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DiscoverAnimeView extends ConsumerWidget {
  const DiscoverAnimeView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoverAnime = ref.watch(discoverAnimeProvider);
    return discoverAnime.when(
      data: (data) {
        final trendingAnime = data["trendingAnime"];
        final popularAnime = data["popularAnime"];
        final upcomingAnime = data["upcomingAnime"];
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              //carousel
              // const CarouselSection(),
              CarouselSection(data: trendingAnime),

              SizedBox(height: 10),
              QuickActions(),
              //genres
              CustomHeadline(title: "CATEGORIES"),
              CategoriesSection(
                onCategorySelected: (category) {
                  context.push(
                    '${Routes.search}?category=${Uri.encodeComponent(category)}&scope=anime',
                  );
                },
              ),
              CustomHeadline(
                title: "POPULAR THIS SEASON",
              ),
              PopularSection(data: popularAnime!),
              CustomHeadline(
                title: "UPCOMING ANIMES",
              ),
              UpcomingSection(data: upcomingAnime!),
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

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: const [
          Expanded(
            child: _ActionButton(
              icon: Icons.calendar_today,
              label: 'Calendar',
              isActive: true,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.tv,
              label: 'Top Anime',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.local_movies,
              label: 'Top Movies',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? colors.accent : colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? colors.actionText : colors.iconMuted,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isActive ? colors.actionText : colors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

