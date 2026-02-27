import 'package:anilist_client/screens/discover/discover_anime_view.dart';
import 'package:anilist_client/screens/discover/discover_manga_view.dart';
import 'package:anilist_client/utils/app_colors.dart';
import 'package:anilist_client/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colors.background,
          automaticallyImplyLeading: true,
          centerTitle: false,
          title: TabBar(
            tabAlignment: TabAlignment.start,
            dividerHeight: 0,
            labelColor: Colors.white,
            unselectedLabelColor: colors.textMuted,
            indicatorColor: colors.accent,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            isScrollable: true,
            tabs: const [
              Tab(text: 'ANIME'),
              Tab(text: 'MANGA'),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(Icons.search, color: colors.textMuted),
                onPressed: () => context.push(Routes.search),
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
                const Color(0xFF021325),
              ],
            ),
          ),
          child: const TabBarView(
            children: [
              DiscoverAnimeView(),
              DiscoverMangaView(),
            ],
          ),
        ),
      ),
    );
  }
}
