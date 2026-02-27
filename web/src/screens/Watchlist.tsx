
import React, { useEffect, useState } from 'react';
import { Sliders, Bell, Tv, Check, MoreHorizontal } from 'lucide-react';
import { Anime } from '@/types';
import { fetchReleasingWatchlist } from '@/services/anilist';

const Watchlist: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'WATCHLIST' | 'ACTIVITIES'>('WATCHLIST');
  const [contentType, setContentType] = useState<'ANIME' | 'MANGA'>('ANIME');
  const [watchlistData, setWatchlistData] = useState<Anime[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isActive = true;

    const loadWatchlist = async () => {
      setLoading(true);
      setError(null);

      try {
        const data = await fetchReleasingWatchlist(12);
        if (!isActive) {
          return;
        }

        setWatchlistData(data);
      } catch (err) {
        if (!isActive) {
          return;
        }

        setError(err instanceof Error ? err.message : 'Failed to load watchlist');
      } finally {
        if (isActive) {
          setLoading(false);
        }
      }
    };

    void loadWatchlist();
    return () => {
      isActive = false;
    };
  }, []);

  return (
    <div className="relative flex flex-col h-full bg-[#0b1622] text-[#f0f1f1]">
      {/* Top Header */}
      <div className="flex items-center justify-between px-6 pt-6 pb-2">
        <div className="flex space-x-8">
          <button 
            onClick={() => setActiveTab('WATCHLIST')}
            className={`text-sm font-bold tracking-widest ${activeTab === 'WATCHLIST' ? 'text-white border-b-2 border-[#3db4f2] pb-1' : 'text-gray-500'}`}
          >
            WATCHLIST
          </button>
          <button 
            onClick={() => setActiveTab('ACTIVITIES')}
            className={`text-sm font-bold tracking-widest ${activeTab === 'ACTIVITIES' ? 'text-white border-b-2 border-[#3db4f2] pb-1' : 'text-gray-500'}`}
          >
            ACTIVITIES
          </button>
        </div>
        <div className="flex items-center space-x-4 text-gray-400">
          <Sliders size={20} />
          <Bell size={20} />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-6 pt-4 pb-24 lg:pb-8">
        {/* Section Title */}
        <div className="flex items-center justify-center space-x-2 text-[#3db4f2] mb-6">
          <Tv size={24} />
          <span className="font-bold tracking-widest">RELEASING</span>
        </div>

        {/* List of Items */}
        <div className="space-y-6">
          {watchlistData.map((anime) => (
            <div key={anime.id} className="bg-[#151f2e] rounded-lg p-3 flex shadow-lg">
              <div className="w-20 h-28 flex-shrink-0 rounded-md overflow-hidden bg-gray-800">
                <img
                  src={anime.image || 'https://placehold.co/200x300/151f2e/f0f1f1?text=Anime'}
                  alt={anime.title}
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="ml-4 flex-1 flex flex-col justify-between">
                <div>
                  <h3 className="text-sm font-semibold text-gray-100 line-clamp-1">{anime.title}</h3>
                  {anime.nextEpisode && (
                    <p className="text-[10px] text-gray-500 mt-1">
                      Next Ep: {anime.nextEpisode.number} | {anime.nextEpisode.date}, {anime.nextEpisode.time}
                    </p>
                  )}
                </div>
                
                <div className="mt-2">
                  <div className="flex justify-end text-[10px] text-gray-500 mb-1">
                    {anime.progress} / {anime.total}
                  </div>
                  <div className="w-full bg-[#0b1622] rounded-full h-1">
                    <div 
                      className="bg-[#3db4f2] h-1 rounded-full" 
                      style={{ width: `${anime.total > 0 ? (anime.progress / anime.total) * 100 : 0}%` }}
                    />
                  </div>
                </div>

                <div className="flex items-center justify-between mt-2">
                  <div className="flex items-center space-x-1 bg-[#0b1622] px-2 py-1 rounded text-[#3db4f2] text-xs">
                    <span>{anime.progress || 1}</span>
                    <Check size={12} />
                  </div>
                  <div className="bg-[#0b1622] p-1.5 rounded">
                    <MoreHorizontal size={16} className="text-gray-500" />
                  </div>
                </div>
              </div>
            </div>
          ))}
          {loading && <p className="text-xs text-gray-500">Loading releasing anime...</p>}
          {!loading && !error && watchlistData.length === 0 && (
            <p className="text-xs text-gray-500">No releasing anime found.</p>
          )}
          {error && <p className="text-xs text-red-400">Failed to load watchlist: {error}</p>}
        </div>
      </div>

      {/* Floating Toggle Overlay (mobile) */}
      <div className="fixed bottom-24 left-1/2 -translate-x-1/2 flex bg-[#3db4f2]/90 rounded-md overflow-hidden shadow-2xl z-20 lg:hidden">
        <button 
          onClick={() => setContentType('ANIME')}
          className={`px-6 py-2 text-[10px] font-bold tracking-widest ${contentType === 'ANIME' ? 'bg-[#0b1622] text-[#3db4f2]' : 'text-[#0b1622]'}`}
        >
          ANIME
        </button>
        <button 
          onClick={() => setContentType('MANGA')}
          className={`px-6 py-2 text-[10px] font-bold tracking-widest ${contentType === 'MANGA' ? 'bg-[#0b1622] text-[#3db4f2]' : 'text-[#0b1622]'}`}
        >
          MANGA
        </button>
      </div>

      {/* Desktop Toggle */}
      <div className="hidden lg:flex absolute bottom-6 right-6 bg-[#3db4f2]/90 rounded-md overflow-hidden shadow-2xl z-20">
        <button
          onClick={() => setContentType('ANIME')}
          className={`px-6 py-2 text-[10px] font-bold tracking-widest ${contentType === 'ANIME' ? 'bg-[#0b1622] text-[#3db4f2]' : 'text-[#0b1622]'}`}
        >
          ANIME
        </button>
        <button
          onClick={() => setContentType('MANGA')}
          className={`px-6 py-2 text-[10px] font-bold tracking-widest ${contentType === 'MANGA' ? 'bg-[#0b1622] text-[#3db4f2]' : 'text-[#0b1622]'}`}
        >
          MANGA
        </button>
      </div>
    </div>
  );
};

export default Watchlist;
