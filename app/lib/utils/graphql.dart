abstract class GqlQuery {
  static const String getTrendingAnime = r'''query {
  Page(page: 1, perPage: 10) {
    media(type: ANIME, sort: TRENDING_DESC) {
      id
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          bannerImage
          format
          duration
          startDate {
            day
            month
            year
          }
          episodes
    }
  }
}''';

  static const String getPopularAnime =
      r'''query($season: MediaSeason, $seasonYear: Int) {
  Page(page: 1, perPage: 10) {
    media(type: ANIME, sort: POPULARITY_DESC, season: $season, seasonYear: $seasonYear) {
      id
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          bannerImage
          format
          duration
          startDate {
            day
            month
            year
          }
          episodes
          averageScore
    }
  }
}''';

  static const String upcomingAnime =
      r'''query($season: MediaSeason, $seasonYear: Int) {
  Page(page: 1, perPage: 10) {
    media(
      type: ANIME
      sort: START_DATE
      season: $season
      seasonYear: $seasonYear
      status: NOT_YET_RELEASED
      isAdult: false
    ) {
      id
      title {
        romaji
        english
      }
      coverImage {
        large
      }
      bannerImage
      format
      duration
      startDate {
        day
        month
        year
      }
      episodes
    }
  }
}''';

  static const String trendingManga = r'''query {
  Page(page: 1, perPage: 10) {
    media(type: MANGA, sort: TRENDING_DESC) {
      id
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          bannerImage
          format
          duration
          startDate {
            day
            month
            year
          }
          episodes
    }
  }
}''';

  static const String popularManga = r'''query {
  Page(page: 1, perPage: 10) {
    media(type: MANGA, sort: POPULARITY_DESC) {
      id
          title {
            romaji
            english
          }
          coverImage {
            large
          }
          bannerImage
          format
          duration
          startDate {
            day
            month
            year
          }
          episodes  
    }
  }
}''';

  static const String currentAnimes = r'''
query MediaListCollection(
  $type: MediaType
  $status: MediaListStatus
  $userId: Int
) {
  MediaListCollection(type: $type, status: $status, userId: $userId) {
    lists {
      entries {
        media {
          title {
            english
            romaji
          }
          nextAiringEpisode {
            episode
            airingAt
          }
          coverImage {
            large
          }
          episodes
          status
        }
        progress
      }
    }
  }
}
''';

  static const String recentActivities = r'''
query RecentActivities($userId: Int) {
  Page(page: 1, perPage: 20) {
    activities(userId: $userId, sort: ID_DESC) {
      __typename
      ... on ListActivity {
        id
        status
        progress
        createdAt
        media {
          type
          title {
            romaji
            english
          }
          coverImage {
            large
          }
        }
      }
      ... on TextActivity {
        id
        text(asHtml: false)
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on MessageActivity {
        id
        message(asHtml: false)
        createdAt
        messenger {
          name
          avatar {
            large
          }
        }
      }
    }
  }
}
''';

  static const String currentMangaPage = r'''
query CurrentMangaPage($userId: Int, $page: Int, $perPage: Int, $status: MediaListStatus) {
  Page(page: $page, perPage: $perPage) {
    pageInfo {
      currentPage
      hasNextPage
    }
    mediaList(
      userId: $userId
      type: MANGA
      status: $status
      sort: UPDATED_TIME_DESC
    ) {
      progress
      media {
        title {
          english
          romaji
        }
        nextAiringEpisode {
          episode
          airingAt
        }
        coverImage {
          large
        }
        episodes
        status
      }
    }
  }
}
''';
}
