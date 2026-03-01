import { Anime, Review } from '@/types';

const ANILIST_API_URL =
  import.meta.env.DEV
    ? '/api/anilist'
    : (import.meta.env.VITE_ANILIST_GRAPHQL_URL as string | undefined) || 'https://graphql.anilist.co';

type GraphQLResponse<T> = {
  data?: T;
  errors?: Array<{ message: string }>;
};

const ACCESS_TOKEN_KEY = 'anitrack.auth.access_token';
const EXPIRES_AT_KEY = 'anitrack.auth.expires_at';

const readAccessToken = (): string | null => {
  const token = localStorage.getItem(ACCESS_TOKEN_KEY);
  const expiresAtRaw = localStorage.getItem(EXPIRES_AT_KEY);
  if (!token || !expiresAtRaw) return null;
  const expiresAt = Number(expiresAtRaw);
  if (!Number.isFinite(expiresAt) || Date.now() >= expiresAt) {
    return null;
  }
  return token;
};

const formatDate = (unixSeconds: number) =>
  new Date(unixSeconds * 1000).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
  });

const formatTime = (unixSeconds: number) =>
  new Date(unixSeconds * 1000).toLocaleTimeString(undefined, {
    hour: 'numeric',
    minute: '2-digit',
  });

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

export const anilistRequest = async <T>(
  query: string,
  variables: Record<string, unknown> = {},
  options: { authenticated?: boolean } = {}
): Promise<T> => {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  };

  if (options.authenticated) {
    const token = readAccessToken();
    if (!token) {
      throw new Error('AniList authentication required.');
    }
    headers.Authorization = `Bearer ${token}`;
  }

  const maxAttempts = 3;
  let response: Response | null = null;
  let payload: GraphQLResponse<T> | null = null;

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      response = await fetch(ANILIST_API_URL, {
        method: 'POST',
        headers,
        body: JSON.stringify({ query, variables }),
      });
    } catch {
      if (attempt < maxAttempts) {
        await sleep(400 * attempt);
        continue;
      }
      throw new Error('Network request to AniList failed. Check internet/VPN/firewall and try again.');
    }

    if (response.status === 429 && attempt < maxAttempts) {
      await sleep(700 * attempt);
      continue;
    }

    try {
      payload = (await response.json()) as GraphQLResponse<T>;
    } catch {
      throw new Error(`AniList returned a non-JSON response (HTTP ${response.status}).`);
    }
    break;
  }

  if (!response || !payload) {
    throw new Error('AniList request failed.');
  }

  if (response.status === 429) {
    throw new Error('AniList rate limit hit. Please wait a moment and try again.');
  }
  if (!response.ok || payload.errors?.length) {
    const message = payload.errors?.[0]?.message || 'AniList API request failed';
    throw new Error(message);
  }

  if (!payload.data) {
    throw new Error('AniList API returned no data');
  }

  return payload.data;
};

type TrendingAnimeResponse = {
  Page: {
    media: Array<{
      id: number;
      title: {
        romaji?: string | null;
        english?: string | null;
      };
      bannerImage?: string | null;
      coverImage?: {
        large?: string | null;
        extraLarge?: string | null;
      } | null;
    }>;
  };
};

export type TrendingAnimeItem = {
  id: string;
  title: string;
  image: string;
};

export type DiscoverMediaItem = {
  id: string;
  title: string;
  image: string;
  status: string;
};

export type DiscoverFilters = {
  type?: 'ANIME' | 'MANGA';
  search?: string;
  genre?: string;
  year?: number;
  season?: 'WINTER' | 'SPRING' | 'SUMMER' | 'FALL';
  format?:
    | 'TV'
    | 'TV_SHORT'
    | 'MOVIE'
    | 'SPECIAL'
    | 'OVA'
    | 'ONA'
    | 'MUSIC'
    | 'MANGA'
    | 'NOVEL'
    | 'ONE_SHOT';
  status?:
    | 'FINISHED'
    | 'RELEASING'
    | 'NOT_YET_RELEASED'
    | 'CANCELLED'
    | 'HIATUS';
};

export const fetchTrendingAnime = async (limit = 5): Promise<TrendingAnimeItem[]> => {
  const query = `
    query TrendingAnime($perPage: Int!) {
      Page(page: 1, perPage: $perPage) {
        media(type: ANIME, isAdult: false, sort: TRENDING_DESC) {
          id
          title {
            romaji
            english
          }
          bannerImage
          coverImage {
            extraLarge
            large
          }
        }
      }
    }
  `;

  const data = await anilistRequest<TrendingAnimeResponse>(query, { perPage: limit });
  return data.Page.media.map((item) => ({
    id: String(item.id),
    title: item.title.english || item.title.romaji || 'Untitled',
    image: item.bannerImage || item.coverImage?.extraLarge || item.coverImage?.large || '',
  }));
};

type GenreCollectionResponse = {
  GenreCollection: string[];
};

export const fetchGenres = async (limit = 8): Promise<string[]> => {
  const query = `
    query Genres {
      GenreCollection
    }
  `;

  const data = await anilistRequest<GenreCollectionResponse>(query);
  return data.GenreCollection.slice(0, limit);
};

type DiscoverMediaResponse = {
  Page: {
    media: Array<{
      id: number;
      status?: string | null;
      title?: {
        romaji?: string | null;
        english?: string | null;
      } | null;
      coverImage?: {
        extraLarge?: string | null;
        large?: string | null;
      } | null;
      bannerImage?: string | null;
    }>;
  };
};

const getCurrentSeasonYear = () => {
  const now = new Date();
  const month = now.getMonth() + 1;
  let season: 'WINTER' | 'SPRING' | 'SUMMER' | 'FALL' = 'WINTER';
  if (month >= 3 && month <= 5) season = 'SPRING';
  else if (month >= 6 && month <= 8) season = 'SUMMER';
  else if (month >= 9 && month <= 11) season = 'FALL';
  return { season, year: now.getFullYear() };
};

const mapDiscoverMedia = (items: DiscoverMediaResponse['Page']['media']): DiscoverMediaItem[] =>
  items.map((item) => ({
    id: String(item.id),
    title: item.title?.english || item.title?.romaji || 'Untitled',
    image: item.coverImage?.extraLarge || item.coverImage?.large || item.bannerImage || '',
    status: item.status || 'UNKNOWN',
  }));

export const fetchTrendingNow = async (
  filters: DiscoverFilters = {},
  limit = 6
): Promise<DiscoverMediaItem[]> => {
  const query = `
    query TrendingNow(
      $perPage: Int!
      $type: MediaType
      $search: String
      $genre: String
      $seasonYear: Int
      $season: MediaSeason
      $format: MediaFormat
      $status: MediaStatus
    ) {
      Page(page: 1, perPage: $perPage) {
        media(
          type: $type
          isAdult: false
          search: $search
          genre: $genre
          seasonYear: $seasonYear
          season: $season
          format: $format
          status: $status
          sort: TRENDING_DESC
        ) {
          id
          status
          title {
            romaji
            english
          }
          bannerImage
          coverImage {
            extraLarge
            large
          }
        }
      }
    }
  `;

  const data = await anilistRequest<DiscoverMediaResponse>(query, {
    perPage: limit,
    type: filters.type || 'ANIME',
    search: filters.search || undefined,
    genre: filters.genre || undefined,
    seasonYear: filters.year || undefined,
    season: filters.season || undefined,
    format: filters.format || undefined,
    status: filters.status || undefined,
  });

  return mapDiscoverMedia(data.Page.media);
};

export const fetchPopularThisSeason = async (
  filters: DiscoverFilters = {},
  limit = 6
): Promise<DiscoverMediaItem[]> => {
  const query = `
    query PopularSeason(
      $perPage: Int!
      $type: MediaType
      $search: String
      $genre: String
      $seasonYear: Int
      $season: MediaSeason
      $format: MediaFormat
      $status: MediaStatus
    ) {
      Page(page: 1, perPage: $perPage) {
        media(
          type: $type
          isAdult: false
          search: $search
          genre: $genre
          seasonYear: $seasonYear
          season: $season
          format: $format
          status: $status
          sort: POPULARITY_DESC
        ) {
          id
          status
          title {
            romaji
            english
          }
          bannerImage
          coverImage {
            extraLarge
            large
          }
        }
      }
    }
  `;

  const current = getCurrentSeasonYear();
  const data = await anilistRequest<DiscoverMediaResponse>(query, {
    perPage: limit,
    type: filters.type || 'ANIME',
    search: filters.search || undefined,
    genre: filters.genre || undefined,
    seasonYear: filters.year || current.year,
    season: filters.season || current.season,
    format: filters.format || undefined,
    status: filters.status || undefined,
  });

  return mapDiscoverMedia(data.Page.media);
};

type DiscoverSectionsResponse = {
  trending: {
    media: DiscoverMediaResponse['Page']['media'];
  };
  popular: {
    media: DiscoverMediaResponse['Page']['media'];
  };
};

export const fetchDiscoverSections = async (
  filters: DiscoverFilters = {},
  limit = 6
): Promise<{ trending: DiscoverMediaItem[]; popular: DiscoverMediaItem[] }> => {
  const query = `
    query DiscoverSections(
      $perPage: Int!
      $type: MediaType
      $search: String
      $genre: String
      $seasonYear: Int
      $season: MediaSeason
      $format: MediaFormat
      $status: MediaStatus
    ) {
      trending: Page(page: 1, perPage: $perPage) {
        media(
          type: $type
          isAdult: false
          search: $search
          genre: $genre
          seasonYear: $seasonYear
          season: $season
          format: $format
          status: $status
          sort: TRENDING_DESC
        ) {
          id
          status
          title {
            romaji
            english
          }
          bannerImage
          coverImage {
            extraLarge
            large
          }
        }
      }
      popular: Page(page: 1, perPage: $perPage) {
        media(
          type: $type
          isAdult: false
          search: $search
          genre: $genre
          seasonYear: $seasonYear
          season: $season
          format: $format
          status: $status
          sort: POPULARITY_DESC
        ) {
          id
          status
          title {
            romaji
            english
          }
          bannerImage
          coverImage {
            extraLarge
            large
          }
        }
      }
    }
  `;

  const current = getCurrentSeasonYear();
  const data = await anilistRequest<DiscoverSectionsResponse>(query, {
    perPage: limit,
    type: filters.type || 'ANIME',
    search: filters.search || undefined,
    genre: filters.genre || undefined,
    seasonYear: filters.year || current.year,
    season: filters.season || current.season,
    format: filters.format || undefined,
    status: filters.status || undefined,
  });

  return {
    trending: mapDiscoverMedia(data.trending.media),
    popular: mapDiscoverMedia(data.popular.media),
  };
};

type RecentReviewsResponse = {
  Page: {
    reviews: Array<{
      id: number;
      summary?: string | null;
      media?: {
        title?: {
          romaji?: string | null;
          english?: string | null;
        } | null;
        coverImage?: {
          extraLarge?: string | null;
          large?: string | null;
        } | null;
      } | null;
    }>;
  };
};

export const fetchRecentReviews = async (limit = 3): Promise<Review[]> => {
  const query = `
    query RecentReviews($perPage: Int!) {
      Page(page: 1, perPage: $perPage) {
        reviews(sort: ID_DESC) {
          id
          summary
          media {
            title {
              romaji
              english
            }
            coverImage {
              extraLarge
              large
            }
          }
        }
      }
    }
  `;

  const data = await anilistRequest<RecentReviewsResponse>(query, { perPage: limit });
  return data.Page.reviews.map((review) => ({
    id: String(review.id),
    title:
      review.media?.title?.english ||
      review.media?.title?.romaji ||
      'Untitled Review',
    subtitle: review.summary || 'No summary available.',
    image: review.media?.coverImage?.extraLarge || review.media?.coverImage?.large || '',
  }));
};

type AiringScheduleResponse = {
  Page: {
    airingSchedules: Array<{
      episode: number;
      airingAt: number;
      media: {
        id: number;
        episodes?: number | null;
        title: {
          romaji?: string | null;
          english?: string | null;
        };
        coverImage?: {
          large?: string | null;
          extraLarge?: string | null;
        } | null;
      };
    }>;
  };
};

export const fetchReleasingWatchlist = async (limit = 10): Promise<Anime[]> => {
  const query = `
    query ReleasingSchedule($perPage: Int!) {
      Page(page: 1, perPage: $perPage) {
        airingSchedules(sort: TIME, notYetAired: true) {
          episode
          airingAt
          media {
            id
            episodes
            title {
              romaji
              english
            }
            coverImage {
              extraLarge
              large
            }
          }
        }
      }
    }
  `;

  const data = await anilistRequest<AiringScheduleResponse>(query, { perPage: limit });
  const byMedia = new Map<number, Anime>();

  for (const item of data.Page.airingSchedules) {
    if (byMedia.has(item.media.id)) {
      continue;
    }

    byMedia.set(item.media.id, {
      id: String(item.media.id),
      title: item.media.title.english || item.media.title.romaji || 'Untitled',
      image: item.media.coverImage?.extraLarge || item.media.coverImage?.large || '',
      progress: Math.max(0, item.episode - 1),
      total: item.media.episodes || item.episode,
      nextEpisode: {
        number: item.episode,
        date: formatDate(item.airingAt),
        time: formatTime(item.airingAt),
      },
    });
  }

  return Array.from(byMedia.values());
};

export interface CurrentListItem {
  id: string;
  mediaId: number;
  title: string;
  image: string;
  progress: number;
  total: number;
  status: 'RELEASING' | 'FINISHED' | 'OTHER';
  nextEpisode?: {
    number: number;
    date: string;
    time: string;
  };
}

export type WatchlistPagePhase = 'releasing' | 'finished';

export interface WatchlistPageResult {
  items: CurrentListItem[];
  hasNextPage: boolean;
}

type WatchlistPageResponse = {
  Page?: {
    pageInfo?: {
      hasNextPage?: boolean | null;
    } | null;
    mediaList?: Array<{
      id: number;
      progress?: number | null;
      media?: {
        id: number;
        status?: string | null;
        episodes?: number | null;
        chapters?: number | null;
        title?: {
          romaji?: string | null;
          english?: string | null;
        } | null;
        coverImage?: {
          large?: string | null;
          extraLarge?: string | null;
        } | null;
        nextAiringEpisode?: {
          episode?: number | null;
          airingAt?: number | null;
        } | null;
      } | null;
    }> | null;
  } | null;
};

const mapCurrentListItems = (
  entries: NonNullable<NonNullable<WatchlistPageResponse['Page']>['mediaList']>,
  type: 'ANIME' | 'MANGA'
): CurrentListItem[] =>
  entries
    .filter((entry) => entry.media?.id)
    .map((entry) => {
      const media = entry.media!;
      const next = media.nextAiringEpisode;
      const total = type === 'MANGA' ? media.chapters || 0 : media.episodes || 0;

      return {
        id: String(entry.id),
        mediaId: media.id,
        title: media.title?.english || media.title?.romaji || 'Untitled',
        image: media.coverImage?.extraLarge || media.coverImage?.large || '',
        progress: entry.progress || 0,
        total,
        status:
          media.status === 'RELEASING'
            ? 'RELEASING'
            : media.status === 'FINISHED'
              ? 'FINISHED'
              : 'OTHER',
        nextEpisode:
          next?.episode && next?.airingAt
            ? {
                number: next.episode,
                date: formatDate(next.airingAt),
                time: formatTime(next.airingAt),
              }
            : undefined,
      };
    });

export const fetchWatchlistPage = async (args: {
  userId: number;
  type: 'ANIME' | 'MANGA';
  phase: WatchlistPagePhase;
  page: number;
  perPage?: number;
}): Promise<WatchlistPageResult> => {
  const query = `
    query WatchlistPage(
      $userId: Int
      $type: MediaType
      $status: MediaListStatus
      $page: Int
      $perPage: Int
    ) {
      Page(page: $page, perPage: $perPage) {
        pageInfo {
          hasNextPage
        }
        mediaList(
          userId: $userId
          type: $type
          status: $status
          sort: UPDATED_TIME_DESC
        ) {
          id
          progress
          media {
            id
            status
            episodes
            chapters
            title {
              english
              romaji
            }
            nextAiringEpisode {
              episode
              airingAt
            }
            coverImage {
              extraLarge
              large
            }
          }
        }
      }
    }
  `;

  const status = args.phase === 'releasing' ? 'CURRENT' : 'COMPLETED';
  const data = await anilistRequest<WatchlistPageResponse>(
    query,
    {
      userId: args.userId,
      type: args.type,
      status,
      page: args.page,
      perPage: args.perPage || 15,
    },
    { authenticated: true }
  );

  const entries = data.Page?.mediaList || [];
  const mapped = mapCurrentListItems(entries, args.type);
  const items =
    args.phase === 'releasing'
      ? mapped.filter((item) => item.status === 'RELEASING')
      : mapped;

  return {
    items,
    hasNextPage: data.Page?.pageInfo?.hasNextPage === true,
  };
};

type CurrentMediaListResponse = {
  MediaListCollection?: {
    lists?: Array<{
      entries?: Array<{
        id: number;
        progress?: number | null;
        media?: {
          id: number;
          status?: string | null;
          episodes?: number | null;
          chapters?: number | null;
          title?: {
            romaji?: string | null;
            english?: string | null;
          } | null;
          coverImage?: {
            large?: string | null;
            extraLarge?: string | null;
          } | null;
          nextAiringEpisode?: {
            episode?: number | null;
            airingAt?: number | null;
          } | null;
        } | null;
      }>;
    }>;
  };
};

export const fetchCurrentMediaList = async (
  userId: number,
  type: 'ANIME' | 'MANGA'
): Promise<{ releasing: CurrentListItem[]; finished: CurrentListItem[] }> => {
  const query = `
    query MediaListCollection($type: MediaType, $status: MediaListStatus, $userId: Int) {
      MediaListCollection(type: $type, status: $status, userId: $userId) {
        lists {
          entries {
            id
            progress
            media {
              id
              status
              episodes
              chapters
              title {
                english
                romaji
              }
              nextAiringEpisode {
                episode
                airingAt
              }
              coverImage {
                extraLarge
                large
              }
            }
          }
        }
      }
    }
  `;

  const mapEntries = (entries: Array<NonNullable<NonNullable<CurrentMediaListResponse['MediaListCollection']>['lists']>[number]['entries'][number]>): CurrentListItem[] =>
    entries
      .filter((entry) => entry.media?.id)
      .map((entry) => {
        const media = entry.media!;
        const next = media.nextAiringEpisode;
        const total = type === 'MANGA' ? media.chapters || 0 : media.episodes || 0;

        return {
          id: String(entry.id),
          mediaId: media.id,
          title: media.title?.english || media.title?.romaji || 'Untitled',
          image: media.coverImage?.extraLarge || media.coverImage?.large || '',
          progress: entry.progress || 0,
          total,
          status:
            media.status === 'RELEASING'
              ? 'RELEASING'
              : media.status === 'FINISHED'
                ? 'FINISHED'
                : 'OTHER',
          nextEpisode:
            next?.episode && next?.airingAt
              ? {
                  number: next.episode,
                  date: formatDate(next.airingAt),
                  time: formatTime(next.airingAt),
                }
              : undefined,
        };
      });

  if (type === 'MANGA') {
    const [currentData, completedData] = await Promise.all([
      anilistRequest<CurrentMediaListResponse>(
        query,
        { userId, type, status: 'CURRENT' },
        { authenticated: true }
      ),
      anilistRequest<CurrentMediaListResponse>(
        query,
        { userId, type, status: 'COMPLETED' },
        { authenticated: true }
      ),
    ]);

    const currentEntries =
      currentData.MediaListCollection?.lists?.flatMap((list) => list.entries || []) || [];
    const completedEntries =
      completedData.MediaListCollection?.lists?.flatMap((list) => list.entries || []) || [];

    return {
      releasing: mapEntries(currentEntries),
      finished: mapEntries(completedEntries),
    };
  }

  const data = await anilistRequest<CurrentMediaListResponse>(
    query,
    { userId, type, status: 'CURRENT' },
    { authenticated: true }
  );

  const entries =
    data.MediaListCollection?.lists?.flatMap((list) => list.entries || []) || [];
  const normalized = mapEntries(entries);

  return {
    releasing: normalized.filter((item) => item.status !== 'FINISHED'),
    finished: normalized.filter((item) => item.status === 'FINISHED'),
  };
};

export interface ActivityFeedItem {
  id: string;
  title: string;
  subtitle: string;
  image?: string;
  createdAt?: number;
  kind: 'anime' | 'manga' | 'text' | 'message' | 'other';
}

type RecentActivitiesResponse = {
  Page: {
    activities: Array<{
      __typename?: string;
      id: number;
      createdAt?: number;
      status?: string | null;
      progress?: string | number | null;
      text?: string | null;
      message?: string | null;
      user?: {
        name?: string | null;
        avatar?: { large?: string | null } | null;
      } | null;
      messenger?: {
        name?: string | null;
        avatar?: { large?: string | null } | null;
      } | null;
      media?: {
        type?: 'ANIME' | 'MANGA' | null;
        title?: {
          english?: string | null;
          romaji?: string | null;
        } | null;
        coverImage?: {
          large?: string | null;
          extraLarge?: string | null;
        } | null;
      } | null;
    }>;
  };
};

const sanitize = (value?: string | null) => value?.replace(/\s+/g, ' ').trim() || '';

export const fetchRecentActivities = async (
  userId: number,
  limit = 20
): Promise<ActivityFeedItem[]> => {
  const query = `
    query RecentActivities($userId: Int!, $perPage: Int!) {
      Page(page: 1, perPage: $perPage) {
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
                extraLarge
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
  `;

  const data = await anilistRequest<RecentActivitiesResponse>(
    query,
    { userId, perPage: limit },
    { authenticated: true }
  );
  return data.Page.activities.map((item) => {
    const type = item.__typename || '';

    if (type === 'ListActivity') {
      const mediaTitle =
        item.media?.title?.english ||
        item.media?.title?.romaji ||
        'Updated list';
      const status = sanitize(item.status);
      const progress = sanitize(String(item.progress || ''));

      return {
        id: String(item.id),
        title: mediaTitle,
        subtitle: [status, progress].filter(Boolean).join(' '),
        image: item.media?.coverImage?.extraLarge || item.media?.coverImage?.large || undefined,
        createdAt: item.createdAt,
        kind: item.media?.type === 'MANGA' ? 'manga' : 'anime',
      };
    }

    if (type === 'TextActivity') {
      return {
        id: String(item.id),
        title: item.user?.name || 'Text activity',
        subtitle: sanitize(item.text) || 'Posted an update',
        image: item.user?.avatar?.large || undefined,
        createdAt: item.createdAt,
        kind: 'text',
      };
    }

    if (type === 'MessageActivity') {
      return {
        id: String(item.id),
        title: item.messenger?.name || 'Message',
        subtitle: sanitize(item.message) || 'Sent a message',
        image: item.messenger?.avatar?.large || undefined,
        createdAt: item.createdAt,
        kind: 'message',
      };
    }

    return {
      id: String(item.id),
      title: 'Activity',
      subtitle: 'Recent update',
      createdAt: item.createdAt,
      kind: 'other',
    };
  });
};

export interface NotificationFeedItem {
  id: string;
  title: string;
  subtitle: string;
  image?: string;
  createdAt?: number;
  type: string;
}

type NotificationsResponse = {
  Page: {
    notifications: Array<{
      __typename?: string;
      id: number;
      type?: string;
      createdAt?: number;
      episode?: number | null;
      context?: string | null;
      deletedMediaTitle?: string | null;
      user?: {
        name?: string | null;
        avatar?: { large?: string | null } | null;
      } | null;
      media?: {
        title?: {
          english?: string | null;
          romaji?: string | null;
        } | null;
        coverImage?: {
          large?: string | null;
          extraLarge?: string | null;
        } | null;
      } | null;
      thread?: {
        title?: string | null;
      } | null;
    }>;
  };
};

export const fetchNotifications = async (limit = 20): Promise<NotificationFeedItem[]> => {
  const query = `
    query Notifications($page: Int!, $perPage: Int!) {
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
                extraLarge
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
          ... on MediaDataChangeNotification {
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
                extraLarge
                large
              }
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
                extraLarge
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
  `;

  const data = await anilistRequest<NotificationsResponse>(
    query,
    { page: 1, perPage: limit },
    { authenticated: true }
  );

  return data.Page.notifications.map((item) => {
    const mediaTitle =
      item.media?.title?.english ||
      item.media?.title?.romaji ||
      item.deletedMediaTitle ||
      'Media update';
    const image = item.user?.avatar?.large || item.media?.coverImage?.extraLarge || item.media?.coverImage?.large || undefined;
    const userName = item.user?.name || 'Someone';
    const type = item.type || '';

    let subtitle = 'New notification';
    if (type === 'AIRING') {
      subtitle = item.episode ? `Episode ${item.episode} is now available.` : 'New episode aired.';
    } else if (type === 'FOLLOWING') {
      subtitle = 'Started following you.';
    } else if (type.includes('LIKE')) {
      subtitle = 'Liked your activity.';
    } else if (type.includes('ACTIVITY')) {
      subtitle = 'Interacted with your activity.';
    } else if (type.includes('THREAD')) {
      subtitle = item.thread?.title ? `${userName} on "${item.thread.title}"` : 'Thread interaction.';
    } else if (item.context) {
      subtitle = item.context;
    }

    return {
      id: String(item.id),
      title: type === 'AIRING' ? mediaTitle : userName || mediaTitle,
      subtitle,
      image,
      createdAt: item.createdAt,
      type,
    };
  });
};

export interface ProfileGenreItem {
  genre: string;
  count: number;
}

export interface ProfileStatSummary {
  count: number;
  meanScore: number;
  minutesWatched?: number;
  episodesWatched?: number;
  chaptersRead?: number;
  volumesRead?: number;
  genres: ProfileGenreItem[];
}

export interface ProfileActivityItem {
  id: string;
  title: string;
  subtitle: string;
  image?: string;
  createdAt: number;
}

export interface ProfileOverviewData {
  anime: ProfileStatSummary;
  manga: ProfileStatSummary;
  activities: ProfileActivityItem[];
  historyTimestamps: number[];
}

type ProfileOverviewResponse = {
  User?: {
    statistics?: {
      anime?: {
        count?: number | null;
        meanScore?: number | null;
        minutesWatched?: number | null;
        episodesWatched?: number | null;
        genres?: Array<{
          genre?: string | null;
          count?: number | null;
        }> | null;
      } | null;
      manga?: {
        count?: number | null;
        meanScore?: number | null;
        chaptersRead?: number | null;
        volumesRead?: number | null;
        genres?: Array<{
          genre?: string | null;
          count?: number | null;
        }> | null;
      } | null;
    } | null;
  } | null;
  recent: {
    activities: Array<{
      __typename?: string;
      id: number;
      createdAt?: number | null;
      status?: string | null;
      progress?: string | number | null;
      text?: string | null;
      message?: string | null;
      user?: {
        name?: string | null;
        avatar?: { large?: string | null } | null;
      } | null;
      messenger?: {
        name?: string | null;
        avatar?: { large?: string | null } | null;
      } | null;
      media?: {
        title?: {
          english?: string | null;
          romaji?: string | null;
        } | null;
        coverImage?: {
          large?: string | null;
          extraLarge?: string | null;
        } | null;
      } | null;
    }>;
  };
  history: {
    activities: Array<{
      __typename?: string;
      createdAt?: number | null;
    }>;
  };
};

export const fetchProfileOverview = async (
  userId: number,
  options: { recentPerPage?: number; historyPerPage?: number } = {}
): Promise<ProfileOverviewData> => {
  const recentPerPage = options.recentPerPage ?? 8;
  const historyPerPage = options.historyPerPage ?? 250;

  const query = `
    query ProfileOverview($userId: Int!, $recentPerPage: Int!, $historyPerPage: Int!) {
      User(id: $userId) {
        statistics {
          anime {
            count
            meanScore
            minutesWatched
            episodesWatched
            genres(sort: COUNT_DESC) {
              genre
              count
            }
          }
          manga {
            count
            meanScore
            chaptersRead
            volumesRead
            genres(sort: COUNT_DESC) {
              genre
              count
            }
          }
        }
      }
      recent: Page(page: 1, perPage: $recentPerPage) {
        activities(userId: $userId, sort: ID_DESC) {
          __typename
          ... on ListActivity {
            id
            status
            progress
            createdAt
            media {
              title {
                english
                romaji
              }
              coverImage {
                extraLarge
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
      history: Page(page: 1, perPage: $historyPerPage) {
        activities(userId: $userId, sort: ID_DESC) {
          __typename
          ... on ListActivity {
            createdAt
          }
          ... on TextActivity {
            createdAt
          }
          ... on MessageActivity {
            createdAt
          }
        }
      }
    }
  `;

  const data = await anilistRequest<ProfileOverviewResponse>(
    query,
    { userId, recentPerPage, historyPerPage },
    { authenticated: true }
  );

  const animeStats = data.User?.statistics?.anime;
  const mangaStats = data.User?.statistics?.manga;

  const mapGenres = (genres?: Array<{ genre?: string | null; count?: number | null }> | null): ProfileGenreItem[] =>
    (genres || [])
      .filter((item) => item.genre && item.count)
      .map((item) => ({
        genre: item.genre as string,
        count: item.count as number,
      }))
      .slice(0, 8);

  const activities: ProfileActivityItem[] = data.recent.activities
    .map((item) => {
      const createdAt = item.createdAt || 0;
      const type = item.__typename || '';

      if (type === 'ListActivity') {
        const title =
          item.media?.title?.english ||
          item.media?.title?.romaji ||
          'List update';
        const status = sanitize(item.status);
        const progress = sanitize(String(item.progress || ''));
        return {
          id: String(item.id),
          title,
          subtitle: [status, progress].filter(Boolean).join(' '),
          image: item.media?.coverImage?.extraLarge || item.media?.coverImage?.large || undefined,
          createdAt,
        };
      }

      if (type === 'TextActivity') {
        return {
          id: String(item.id),
          title: item.user?.name || 'Status',
          subtitle: sanitize(item.text) || 'Posted a status.',
          image: item.user?.avatar?.large || undefined,
          createdAt,
        };
      }

      if (type === 'MessageActivity') {
        return {
          id: String(item.id),
          title: item.messenger?.name || 'Message',
          subtitle: sanitize(item.message) || 'Sent a message.',
          image: item.messenger?.avatar?.large || undefined,
          createdAt,
        };
      }

      return {
        id: String(item.id),
        title: 'Activity',
        subtitle: 'Recent update',
        createdAt,
      };
    })
    .filter((item) => item.createdAt > 0);

  const historyTimestamps = data.history.activities
    .map((item) => item.createdAt || 0)
    .filter((ts) => ts > 0);

  return {
    anime: {
      count: animeStats?.count || 0,
      meanScore: animeStats?.meanScore || 0,
      minutesWatched: animeStats?.minutesWatched || 0,
      episodesWatched: animeStats?.episodesWatched || 0,
      genres: mapGenres(animeStats?.genres),
    },
    manga: {
      count: mangaStats?.count || 0,
      meanScore: mangaStats?.meanScore || 0,
      chaptersRead: mangaStats?.chaptersRead || 0,
      volumesRead: mangaStats?.volumesRead || 0,
      genres: mapGenres(mangaStats?.genres),
    },
    activities,
    historyTimestamps,
  };
};
