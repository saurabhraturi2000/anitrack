
import React, { useState } from 'react';
import { Search } from 'lucide-react';
import { CATEGORIES, REVIEWS, TRENDING_ANIME } from '@/data/constants';

const Discover: React.FC = () => {
  const [contentTab, setContentTab] = useState<'ANIME' | 'MANGA'>('ANIME');
  const [filterTab, setFilterTab] = useState('trending');

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

      <div className="flex-1 overflow-y-auto px-6 pb-24 lg:pb-8">
        {/* Carousel / Hero */}
        <div className="relative mt-2">
          <div className="rounded-xl overflow-hidden aspect-video relative shadow-2xl">
            <img src={TRENDING_ANIME[0].image} alt="Hero" className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent flex items-end p-4">
              <h2 className="text-sm font-bold text-white uppercase tracking-tight line-clamp-2">
                {TRENDING_ANIME[0].title}
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
        <div className="flex justify-between items-center mt-6">
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
        <div className="mt-8">
          <h3 className="text-lg font-bold mb-4">Categories</h3>
          <div className="grid grid-cols-4 gap-3">
            {CATEGORIES.map((cat) => (
              <div key={cat.name} className="flex flex-col items-center">
                <div className="w-full aspect-square bg-[#151f2e] rounded-xl flex items-center justify-center shadow-md">
                  {cat.icon}
                </div>
                <span className="text-[10px] text-gray-400 mt-2 font-medium">{cat.name}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Reviews */}
        <div className="mt-8 mb-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-bold">Recent Reviews</h3>
            <button className="text-[10px] text-gray-500 font-bold uppercase tracking-wider">More</button>
          </div>
          {REVIEWS.map((review) => (
            <div key={review.id} className="bg-[#151f2e] rounded-xl overflow-hidden shadow-lg border border-gray-800/50">
              <img src={review.image} alt={review.title} className="w-full aspect-video object-cover" />
              <div className="p-4">
                <h4 className="text-xs font-bold uppercase tracking-widest text-[#f0f1f1]">{review.title}</h4>
                <p className="text-[11px] text-gray-500 italic mt-1 font-serif">{review.subtitle}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Discover;
