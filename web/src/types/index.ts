
export interface Anime {
  id: string;
  title: string;
  image: string;
  progress: number;
  total: number;
  nextEpisode?: {
    number: number;
    date: string;
    time: string;
  };
}

export interface Review {
  id: string;
  title: string;
  subtitle: string;
  image: string;
}

export type TabType = 'home' | 'discover' | 'profile';
export type ContentType = 'anime' | 'manga';
