
import React, { useEffect, useMemo, useState } from 'react';
import { Compass, Flame, Ghost, Search, Smile } from 'lucide-react';
import { Review } from '@/types';
import { fetchGenres, fetchRecentReviews, fetchTrendingAnime, TrendingAnimeItem } from '@/services/anilist';

const Discover: React.FC = () => {
  const [contentTab, setContentTab] = useState<'ANIME' | 'MANGA'>('ANIME');
  const [filterTab, setFilterTab] = useState('trending');
  const [trendingAnime, setTrendingAnime] = useState<TrendingAnimeItem[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isActive = true;

    const loadDiscoverData = async () => {
      setLoading(true);
      setError(null);

      try {
        const [trending, genreList, recentReviews] = await Promise.all([
          fetchTrendingAnime(5),
          fetchGenres(8),
          fetchRecentReviews(3),
        ]);

        if (!isActive) {
          return;
        }

        setTrendingAnime(trending);
        setCategories(genreList);
        setReviews(recentReviews);
      } catch (err) {
        if (!isActive) {
          return;
        }

        setError(err instanceof Error ? err.message : 'Failed to load discover data');
      } finally {
        if (isActive) {
          setLoading(false);
        }
      }
    };

    void loadDiscoverData();
    return () => {
      isActive = false;
    };
  }, []);

  const categoryIconByIndex = useMemo(
    () => [Flame, Compass, Smile, Ghost],
    []
  );

  const heroItem = trendingAnime[0];

  return (
    <div className="flex flex-col h-full bg-[#0b1622] text-[#f0f1f1]">
      {/* Top Header */}
      <div className="flex items-center justify-between px-6 pt-6 pb-4">
        <div className="flex space-x-6">
          <button 
            onClick={() => setContentTab('ANIME')}
            className={`text-sm font-bold tracking-widest ${contentTab === 'ANIME' ? 'text-white border-b-2 border-[#3db4f2] pb-1' : 'text-gray-500'}`}
          >
            ANIME
          </button>
          <button 
            onClick={() => setContentTab('MANGA')}
            className={`text-sm font-bold tracking-widest ${contentTab === 'MANGA' ? 'text-white border-b-2 border-[#3db4f2] pb-1' : 'text-gray-500'}`}
          >
            MANGA
          </button>
        </div>
        <Search size={22} className="text-gray-400" />
      </div>

      <div className="flex-1 overflow-y-auto px-4 pb-24 lg:px-6 lg:pb-8">
        <div className="mx-auto w-full max-w-5xl">
        {/* Carousel / Hero */}
        <div className="relative mt-2">
          <div className="rounded-xl overflow-hidden aspect-[21/8] relative shadow-2xl max-h-64">
            <img
              src={heroItem?.image || 'https://placehold.co/800x450/0b1622/f0f1f1?text=No+Image'}
              alt={heroItem?.title || 'Trending anime'}
              className="w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent flex items-end p-4">
              <h2 className="text-sm font-bold text-white uppercase tracking-tight line-clamp-2">
                {heroItem?.title || (loading ? 'Loading trending anime...' : 'No trending anime found')}
              </h2>
            </div>
          </div>
          {/* Indicators */}
          <div className="flex justify-center mt-3 space-x-1.5">
            <div className="w-8 h-1 bg-[#3db4f2] rounded-full" />
            <div className="w-1.5 h-1 bg-gray-600 rounded-full" />
            <div className="w-1.5 h-1 bg-gray-600 rounded-full" />
            <div className="w-1.5 h-1 bg-gray-600 rounded-full" />
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex justify-between items-center mt-4">
          <div className="flex space-x-2 bg-[#151f2e] p-1 rounded-md overflow-x-auto no-scrollbar flex-1 mr-4">
            {['Trending now', 'Popular this season', 'Upcoming next season'].map((tab) => (
              <button
                key={tab}
                onClick={() => setFilterTab(tab.toLowerCase())}
                className={`px-3 py-2 text-[10px] font-semibold whitespace-nowrap rounded-md ${filterTab === tab.toLowerCase() ? 'bg-[#3db4f2] text-white shadow-md' : 'text-gray-400'}`}
              >
                {tab}
              </button>
            ))}
          </div>
          <button className="text-[10px] text-gray-500 font-bold uppercase tracking-wider flex items-center">
            More
          </button>
        </div>

        {/* Categories */}
        <div className="mt-6">
          <h3 className="text-lg font-bold mb-4">Categories</h3>
          <div className="grid grid-cols-4 gap-2 md:grid-cols-6 lg:grid-cols-8">
            {categories.map((name, index) => {
              const Icon = categoryIconByIndex[index % categoryIconByIndex.length];

              return (
                <div key={name} className="flex flex-col items-center">
                  <div className="w-full aspect-square bg-[#151f2e] rounded-lg flex items-center justify-center shadow-md">
                    <Icon className="text-[#3db4f2]" size={18} />
                  </div>
                  <span className="text-[10px] text-gray-400 mt-1.5 font-medium text-center line-clamp-1">{name}</span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Recent Reviews */}
        <div className="mt-6 mb-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-bold">Recent Reviews</h3>
            <button className="text-[10px] text-gray-500 font-bold uppercase tracking-wider">More</button>
          </div>
          <div className="grid grid-cols-1 gap-3 md:grid-cols-2 xl:grid-cols-3">
          {reviews.map((review) => (
            <div key={review.id} className="bg-[#151f2e] rounded-xl overflow-hidden shadow-lg border border-gray-800/50">
              <img
                src={review.image || 'https://placehold.co/800x400/151f2e/f0f1f1?text=Review'}
                alt={review.title}
                className="w-full aspect-[4/3] object-cover"
              />
              <div className="p-3">
                <h4 className="text-[11px] font-bold uppercase tracking-wider text-[#f0f1f1] line-clamp-2">{review.title}</h4>
                <p className="text-[10px] text-gray-500 italic mt-1 font-serif line-clamp-2">{review.subtitle}</p>
              </div>
            </div>
          ))}
          </div>
          {loading && <p className="text-xs text-gray-500">Loading discover content...</p>}
          {!loading && !error && reviews.length === 0 && (
            <p className="text-xs text-gray-500">No recent reviews found.</p>
          )}
          {error && <p className="text-xs text-red-400">Failed to load data: {error}</p>}
        </div>
        </div>
      </div>
    </div>
  );
};

export default Discover;
