import 'package:anitrack/models/media_model.dart';
import 'package:anitrack/utils/api_service.dart';
import 'package:anitrack/utils/graphql.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final discoverAnimeProvider = FutureProvider((ref) async {
  final now = DateTime.now();
  final currentSeason = _seasonForMonth(now.month);
  final nextSeasonInfo = _nextSeason(now);

  final trendingData = await ApiService().request(
    GqlQuery.getTrendingAnime,
  );
  final popularData = await ApiService().request(
    GqlQuery.getPopularAnime,
    {
      'season': currentSeason,
      'seasonYear': now.year,
    },
  );
  final upcomingData = await ApiService().request(
    GqlQuery.upcomingAnime,
    {
      'season': nextSeasonInfo.$1,
      'seasonYear': nextSeasonInfo.$2,
    },
  );
  final trendingAnime = MediaModel.fromJson(trendingData['Page']);
  final popularAnime = MediaModel.fromJson(popularData['Page']);
  final upcomingAnime = MediaModel.fromJson(upcomingData['Page']);
  return {
    "trendingAnime": trendingAnime,
    "popularAnime": popularAnime,
    "upcomingAnime": upcomingAnime,
  };
});

final discoverMangaProvider = FutureProvider((ref) async {
  final trendingData = await ApiService().request(
    GqlQuery.trendingManga,
  );
  final popularData = await ApiService().request(
    GqlQuery.popularManga,
  );
  final trendingManga = MediaModel.fromJson(trendingData['Page']);
  final popularManga = MediaModel.fromJson(popularData['Page']);
  return {
    "trendingManga": trendingManga,
    "popularManga": popularManga,
  };
});

String _seasonForMonth(int month) {
  if (month >= 1 && month <= 3) return 'WINTER';
  if (month >= 4 && month <= 6) return 'SPRING';
  if (month >= 7 && month <= 9) return 'SUMMER';
  return 'FALL';
}

(String, int) _nextSeason(DateTime now) {
  final current = _seasonForMonth(now.month);
  switch (current) {
    case 'WINTER':
      return ('SPRING', now.year);
    case 'SPRING':
      return ('SUMMER', now.year);
    case 'SUMMER':
      return ('FALL', now.year);
    default:
      return ('WINTER', now.year + 1);
  }
}

