
import React from 'react';
import { Flame, Compass, Ghost, Smile } from 'lucide-react';
import { Anime, Review } from '@/types';

export const WATCHLIST_DATA: Anime[] = [
  {
    id: '1',
    title: 'Kunon the Sorcerer Can See',
    image: 'https://picsum.photos/seed/anime1/200/300',
    progress: 0,
    total: 13,
    nextEpisode: { number: 7, date: '8 Feb', time: '6:30 pm' }
  },
  {
    id: '2',
    title: 'Noble Reincarnation: Born Blessed, So I\'ll...',
    image: 'https://picsum.photos/seed/anime2/200/300',
    progress: 1,
    total: 5,
    nextEpisode: { number: 6, date: '8 Feb', time: '8:30 pm' }
  },
  {
    id: '3',
    title: 'Easygoing Territory Defense by the Opti...',
    image: 'https://picsum.photos/seed/anime3/200/300',
    progress: 4,
    total: 5,
    nextEpisode: { number: 6, date: '11 Feb', time: '6:30 pm' }
  },
  {
    id: '4',
    title: 'Sentenced to Be a Hero',
    image: 'https://picsum.photos/seed/anime4/200/300',
    progress: 0,
    total: 12,
    nextEpisode: { number: 6, date: '12 Feb', time: '7:00 pm' }
  }
];

export const CATEGORIES = [
  { name: 'Action', icon: <Flame className="text-red-500" size={20} /> },
  { name: 'Adventure', icon: <Compass className="text-orange-500" size={20} /> },
  { name: 'Comedy', icon: <Smile className="text-yellow-500" size={20} /> },
  { name: 'Drama', icon: <Ghost className="text-blue-400" size={20} /> },
];

export const REVIEWS: Review[] = [
  {
    id: 'r1',
    title: 'ALL YOU NEED IS KILL',
    subtitle: 'Ball knower goes to the movies',
    image: 'https://picsum.photos/seed/review1/800/400'
  }
];

export const TRENDING_ANIME = [
  {
    id: 't1',
    title: 'JUJUTSU KAISEN Season 3: The Culling Game',
    image: 'https://picsum.photos/seed/jujutsu/800/450',
  }
];
