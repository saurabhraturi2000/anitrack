import 'package:anilist_client/screens/auth/login_screen.dart';
import 'package:anilist_client/screens/home/home_activities_view.dart';
import 'package:anilist_client/screens/home/home_anime_view.dart';
import 'package:anilist_client/screens/home/home_manga_view.dart';
import 'package:anilist_client/utils/app_colors.dart';
import 'package:anilist_client/utils/appearance_theme.dart';
import 'package:anilist_client/utils/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _WatchType { anime, manga }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _topTabController;
  _WatchType _watchType = _WatchType.anime;

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _topTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        toolbarHeight: 86,
        titleSpacing: 16,
        title: TabBar(
          controller: _topTabController,
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.only(right: 24),
          labelStyle: const TextStyle(
            fontSize: 15,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelColor: colors.iconMuted,
          labelColor: Theme.of(context).colorScheme.onSurface,
          tabs: const [
            Tab(text: 'WATCHLIST'),
            Tab(text: 'ACTIVITIES'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.tune, color: colors.iconMuted),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: colors.iconMuted,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.background,
              colors.background.withValues(alpha: 0.96),
            ],
          ),
        ),
        child: authState.when(
          data: (data) {
            if (data != AuthState.authenticated) {
              return const LoginScreen();
            }
            return TabBarView(
              controller: _topTabController,
              children: [
                _buildWatchlistBody(colors),
                const HomeActivitiesView(),
              ],
            );
          },
          error: (error, stack) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildWatchlistBody(AppPalette colors) {
    final content = _watchType == _WatchType.anime
        ? const CurrentAnimeView(showFinished: true, bottomPadding: 100)
        : const CurrentMangaView(showFinished: true, bottomPadding: 100);

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: slide,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<_WatchType>(_watchType),
              child: content,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: Container(
              width: 220,
              height: 44,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildWatchTypeButton(_WatchType.anime, 'ANIME', colors),
                  _buildWatchTypeButton(_WatchType.manga, 'MANGA', colors),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchTypeButton(
    _WatchType type,
    String label,
    AppPalette colors,
  ) {
    final selected = _watchType == type;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            if (_watchType != type) {
              setState(() => _watchType = type);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? colors.background : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: selected ? colors.accent : colors.actionText,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
