import React, { useEffect, useMemo, useState } from 'react';
import { ChevronDown, Search, SlidersHorizontal } from 'lucide-react';
import {
  DiscoverFilters,
  DiscoverMediaItem,
  fetchDiscoverSections,
  fetchGenres,
} from '@/services/anilist';

type FilterState = {
  search: string;
  genre: string;
  year: string;
  season: string;
  format: string;
  status: string;
};

const Discover: React.FC = () => {
  const [genres, setGenres] = useState<string[]>([]);
  const [trending, setTrending] = useState<DiscoverMediaItem[]>([]);
  const [popular, setPopular] = useState<DiscoverMediaItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<FilterState>({
    search: '',
    genre: '',
    year: '',
    season: '',
    format: '',
    status: '',
  });

  useEffect(() => {
    let isActive = true;

    const loadGenres = async () => {
      try {
        const items = await fetchGenres(50);
        if (isActive) setGenres(items);
      } catch {
        if (isActive) setGenres([]);
      }
    };

    void loadGenres();
    return () => {
      isActive = false;
    };
  }, []);

  const mappedFilters = useMemo<DiscoverFilters>(() => {
    const yearNum = Number(filters.year);
    return {
      type: 'ANIME',
      search: filters.search.trim() || undefined,
      genre: filters.genre || undefined,
      year: Number.isFinite(yearNum) && yearNum > 0 ? yearNum : undefined,
      season: (filters.season || undefined) as DiscoverFilters['season'],
      format: (filters.format || undefined) as DiscoverFilters['format'],
      status: (filters.status || undefined) as DiscoverFilters['status'],
    };
  }, [filters]);

  const debouncedFilters = useMemo(() => mappedFilters, [mappedFilters]);

  const [queryKey, setQueryKey] = useState('');
  useEffect(() => {
    const timer = setTimeout(() => {
      setQueryKey(JSON.stringify(debouncedFilters));
    }, 450);
    return () => clearTimeout(timer);
  }, [debouncedFilters]);

  useEffect(() => {
    if (!queryKey) return;
    let isActive = true;

    const loadDiscoverData = async () => {
      setLoading(true);
      setError(null);
      try {
        const sections = await fetchDiscoverSections(JSON.parse(queryKey) as DiscoverFilters, 6);

        if (!isActive) return;
        setTrending(sections.trending);
        setPopular(sections.popular);
      } catch (err) {
        if (!isActive) return;
        setError(err instanceof Error ? err.message : 'Failed to load discover data.');
      } finally {
        if (isActive) setLoading(false);
      }
    };

    void loadDiscoverData();
    return () => {
      isActive = false;
    };
  }, [queryKey]);

  const handleFilterChange = (key: keyof FilterState, value: string) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
  };

  const renderCard = (item: DiscoverMediaItem) => (
    <div key={item.id} className="min-w-0">
      <div className="aspect-[3/4] overflow-hidden rounded bg-[#12263f]">
        <img
          src={item.image || 'https://placehold.co/360x480/12263f/eaf4ff?text=Ani'}
          alt={item.title}
          className="h-full w-full object-cover"
        />
      </div>
      <div className="mt-2 flex items-start gap-2">
        <span
          className={`mt-1 inline-block h-3 w-3 shrink-0 rounded-full ${
            item.status === 'RELEASING' ? 'bg-[#f2a166]' : 'bg-[#3db4f2]'
          }`}
        />
        <p className="line-clamp-2 text-sm leading-5 text-[#9ec2e5]">{item.title}</p>
      </div>
    </div>
  );

  const renderSkeletonRow = (prefix: string) => (
    <div className="grid grid-cols-2 gap-5 md:grid-cols-3 xl:grid-cols-6">
      {Array.from({ length: 6 }, (_, idx) => (
        <div key={`${prefix}-${idx}`} className="animate-pulse">
          <div className="aspect-[3/4] rounded bg-[#12263f]" />
          <div className="mt-2 h-4 w-5/6 rounded bg-[#12263f]" />
          <div className="mt-2 h-4 w-3/4 rounded bg-[#12263f]" />
        </div>
      ))}
    </div>
  );

  return (
    <div className="h-full overflow-y-auto bg-[#06162b] px-7 pb-24 pt-8 text-[#eaf4ff] lg:px-10 lg:pb-10">
      <div className="mx-auto w-full max-w-[1280px]">
        <div className="grid grid-cols-1 gap-3 md:grid-cols-3 xl:grid-cols-7">
          <div className="xl:col-span-1">
            <label className="mb-2 block text-xs font-semibold uppercase tracking-widest text-[#9cc2e5]">Search</label>
            <div className="flex items-center rounded bg-[#11243f] px-3">
              <Search size={15} className="text-[#5a7ea3]" />
              <input
                value={filters.search}
                onChange={(e) => handleFilterChange('search', e.target.value)}
                placeholder="Search"
                className="w-full bg-transparent px-2 py-3 text-sm text-[#d6e9ff] outline-none placeholder:text-[#5a7ea3]"
              />
            </div>
          </div>

          {[
            { key: 'genre', label: 'Genres', options: ['Any', ...genres] },
            { key: 'year', label: 'Year', options: ['Any', '2026', '2025', '2024', '2023', '2022'] },
            { key: 'season', label: 'Season', options: ['Any', 'WINTER', 'SPRING', 'SUMMER', 'FALL'] },
            {
              key: 'format',
              label: 'Format',
              options: ['Any', 'TV', 'TV_SHORT', 'MOVIE', 'ONA', 'OVA', 'SPECIAL', 'MUSIC'],
            },
            {
              key: 'status',
              label: 'Airing Status',
              options: ['Any', 'RELEASING', 'FINISHED', 'NOT_YET_RELEASED', 'HIATUS', 'CANCELLED'],
            },
          ].map((item) => (
            <div key={item.key} className="xl:col-span-1">
              <label className="mb-2 block text-xs font-semibold uppercase tracking-widest text-[#9cc2e5]">{item.label}</label>
              <div className="relative">
                <select
                  value={(filters[item.key as keyof FilterState] || 'Any') as string}
                  onChange={(e) =>
                    handleFilterChange(item.key as keyof FilterState, e.target.value === 'Any' ? '' : e.target.value)
                  }
                  className="w-full appearance-none rounded bg-[#11243f] px-4 py-3 text-sm text-[#9ec2e5] outline-none"
                >
                  {item.options.map((opt) => (
                    <option key={opt} value={opt}>
                      {opt}
                    </option>
                  ))}
                </select>
                <ChevronDown size={16} className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-[#5a7ea3]" />
              </div>
            </div>
          ))}

          <div className="flex items-end xl:col-span-1">
            <button
              className="h-[46px] w-[46px] rounded bg-[#11243f] text-[#8fb4d8] hover:bg-[#163151]"
              aria-label="More filters"
            >
              <SlidersHorizontal size={18} className="mx-auto" />
            </button>
          </div>
        </div>

        <section className="mt-12">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-2xl font-bold uppercase tracking-wide text-[#b8d5f2]">Trending Now</h2>
            <button className="text-sm font-semibold text-[#8fb4d8] hover:text-[#b8d5f2]">View All</button>
          </div>
          {loading ? renderSkeletonRow('trend') : <div className="grid grid-cols-2 gap-5 md:grid-cols-3 xl:grid-cols-6">{trending.map(renderCard)}</div>}
        </section>

        <section className="mt-12">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-2xl font-bold uppercase tracking-wide text-[#b8d5f2]">Popular This Season</h2>
            <button className="text-sm font-semibold text-[#8fb4d8] hover:text-[#b8d5f2]">View All</button>
          </div>
          {loading ? renderSkeletonRow('pop') : <div className="grid grid-cols-2 gap-5 md:grid-cols-3 xl:grid-cols-6">{popular.map(renderCard)}</div>}
        </section>

        {!loading && error && (
          <p className="mt-6 text-sm text-red-400">Failed to load discover data: {error}</p>
        )}
      </div>
    </div>
  );
};

export default Discover;
