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
        id
        media {
          id
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
      id
      progress
      media {
        id
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

  static const String saveMediaListEntry = r'''
mutation SaveMediaListEntry(
  $mediaId: Int
  $progress: Int
  $status: MediaListStatus
) {
  SaveMediaListEntry(mediaId: $mediaId, progress: $progress, status: $status) {
    id
    progress
    status
  }
}
''';

  static const String deleteMediaListEntry = r'''
mutation DeleteMediaListEntry($id: Int) {
  DeleteMediaListEntry(id: $id) {
    deleted
  }
}
''';

  static const String mediaDetails = r'''
query MediaDetails($id: Int) {
  Media(id: $id) {
    id
    type
    format
    status
    episodes
    chapters
    volumes
    duration
    averageScore
    popularity
    season
    seasonYear
    description(asHtml: false)
    genres
    coverImage {
      large
    }
    bannerImage
    title {
      english
      romaji
      native
    }
    startDate {
      day
      month
      year
    }
    endDate {
      day
      month
      year
    }
    nextAiringEpisode {
      episode
      airingAt
    }
    studios(isMain: true) {
      nodes {
        name
      }
    }
    mediaListEntry {
      id
      status
      progress
    }
  }
}
''';

  static const String notifications = r'''
query NotificationsPage($page: Int, $perPage: Int) {
  Page(page: $page, perPage: $perPage) {
    notifications(resetNotificationCount: false) {
      __typename
      ... on AiringNotification {
        id
        type
        createdAt
        episode
        media {
          title {
            english
            romaji
          }
          coverImage {
            large
          }
        }
      }
      ... on FollowingNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ActivityMessageNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ActivityMentionNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ActivityReplyNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ActivityReplySubscribedNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ActivityLikeNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ActivityReplyLikeNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
      }
      ... on ThreadCommentMentionNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
        thread {
          title
        }
      }
      ... on ThreadCommentReplyNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
        thread {
          title
        }
      }
      ... on ThreadCommentSubscribedNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
        thread {
          title
        }
      }
      ... on ThreadCommentLikeNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
        thread {
          title
        }
      }
      ... on ThreadLikeNotification {
        id
        type
        createdAt
        user {
          name
          avatar {
            large
          }
        }
        thread {
          title
        }
      }
      ... on RelatedMediaAdditionNotification {
        id
        type
        createdAt
        context
        media {
          title {
            english
            romaji
          }
          coverImage {
            large
          }
        }
      }
      ... on MediaDataChangeNotification {
        id
        type
        createdAt
        context
        reason
        media {
          title {
            english
            romaji
          }
          coverImage {
            large
          }
        }
      }
      ... on MediaMergeNotification {
        id
        type
        createdAt
        context
        media {
          title {
            english
            romaji
          }
          coverImage {
            large
          }
        }
      }
      ... on MediaDeletionNotification {
        id
        type
        createdAt
        context
        deletedMediaTitle
      }
    }
  }
}
''';
}
