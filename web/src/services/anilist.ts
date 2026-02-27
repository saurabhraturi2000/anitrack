import { Anime, Review } from '@/types';

const ANILIST_API_URL = 'https://graphql.anilist.co';

type GraphQLResponse<T> = {
  data?: T;
  errors?: Array<{ message: string }>;
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

export const anilistRequest = async <T>(
  query: string,
  variables: Record<string, unknown> = {}
): Promise<T> => {
  const response = await fetch(ANILIST_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify({ query, variables }),
  });

  const payload = (await response.json()) as GraphQLResponse<T>;
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
