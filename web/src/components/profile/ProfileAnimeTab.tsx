import React, { useEffect, useMemo, useState } from 'react';
import { ChevronDown, List, Search, SlidersHorizontal, Table2 } from 'lucide-react';
import { fetchProfileAnimeList, ProfileAnimeListData, ProfileAnimeListItem } from '@/services/anilist';

type AnimeListView = 'cards' | 'compact' | 'table';
type AnimeListFilter = 'all' | 'watching' | 'completed' | 'paused' | 'dropped' | 'planning';

const ProfileAnimeTab: React.FC<{ userId: number }> = ({ userId }) => {
  const [data, setData] = useState<ProfileAnimeListData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const [activeList, setActiveList] = useState<AnimeListFilter>('watching');
  const [view, setView] = useState<AnimeListView>('table');

  useEffect(() => {
    let isActive = true;

    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await fetchProfileAnimeList(userId);
        if (isActive) setData(res);
      } catch (err) {
        if (isActive) setError(err instanceof Error ? err.message : 'Failed to load anime list.');
      } finally {
        if (isActive) setLoading(false);
      }
    };

    void load();
    return () => {
      isActive = false;
    };
  }, [userId]);

  const listMap: Record<AnimeListFilter, ProfileAnimeListItem[]> = {
    all: data?.all || [],
    watching: data?.watching || [],
    completed: data?.completed || [],
    paused: data?.paused || [],
    dropped: data?.dropped || [],
    planning: data?.planning || [],
  };

  const visibleItems = useMemo(() => {
    const source = listMap[activeList];
    const q = query.trim().toLowerCase();
    if (!q) return source;
    return source.filter((item) => item.title.toLowerCase().includes(q));
  }, [activeList, listMap, query]);

  const sectionTitle =
    activeList === 'watching'
      ? 'Watching'
      : activeList.charAt(0).toUpperCase() + activeList.slice(1);

  const renderRow = (item: ProfileAnimeListItem) => (
    <div
      key={item.id}
      className="grid grid-cols-[1fr_140px_140px_90px] items-center gap-4 border-t border-[#173154] px-5 py-3 text-sm"
    >
      <div className="flex items-center gap-3 min-w-0">
        <div
          className={`h-2.5 w-2.5 shrink-0 rounded-full ${item.status === 'CURRENT' ? 'bg-[#74e04e]' : 'bg-[#365473]'}`}
        />
        <img
          src={item.image || 'https://placehold.co/60x84/10243c/8fb4d8?text=A'}
          alt={item.title}
          className="h-14 w-10 rounded object-cover"
        />
        <p className="line-clamp-2 text-[#9ec2e5]">{item.title}</p>
      </div>
      <p className="text-[#9ec2e5]">{item.score > 0 ? item.score.toFixed(1) : '-'}</p>
      <p className="text-[#9ec2e5]">
        {item.progress}
        {item.total > 0 ? `/${item.total}` : ''}
      </p>
      <p className="text-[#9ec2e5]">{item.format}</p>
    </div>
  );

  return (
    <div className="mx-auto w-full max-w-[1280px] px-6 py-6">
      <div className="grid grid-cols-1 gap-6 xl:grid-cols-[220px_1fr]">
        <aside className="space-y-4">
          <div className="flex items-center rounded bg-[#11243f] px-3">
            <Search size={14} className="text-[#6f93b7]" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Filter"
              className="w-full bg-transparent px-2 py-3 text-sm text-[#c5dcf3] outline-none placeholder:text-[#6f93b7]"
            />
          </div>

          <div>
            <p className="mb-2 text-sm font-semibold text-[#8fb4d8]">Lists</p>
            <div className="space-y-1 text-[#9ec2e5]">
              {[
                ['all', 'All'],
                ['watching', 'Watching'],
                ['completed', 'Completed'],
                ['paused', 'Paused'],
                ['dropped', 'Dropped'],
                ['planning', 'Planning'],
              ].map(([key, label]) => (
                <button
                  key={key}
                  onClick={() => setActiveList(key as AnimeListFilter)}
                  className={`w-full rounded px-3 py-2 text-left text-sm ${
                    activeList === key ? 'bg-[#11243f] text-[#d7ecff]' : 'hover:bg-[#0f2037]'
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          <div>
            <p className="mb-2 text-sm font-semibold text-[#8fb4d8]">Filters</p>
            {['Format', 'Status', 'Genres', 'Country'].map((f) => (
              <button
                key={f}
                className="mb-2 flex w-full items-center justify-between rounded bg-[#11243f] px-3 py-2 text-sm text-[#9ec2e5]"
              >
                <span>{f}</span>
                <ChevronDown size={14} />
              </button>
            ))}
          </div>

          <div>
            <p className="mb-2 text-sm font-semibold text-[#8fb4d8]">Sort</p>
            <button className="flex w-full items-center justify-between rounded bg-[#11243f] px-3 py-2 text-sm text-[#9ec2e5]">
              <span>Title</span>
              <ChevronDown size={14} />
            </button>
          </div>

          <button className="inline-flex h-8 w-8 items-center justify-center rounded bg-[#3db4f2] text-[#10243d]">
            <SlidersHorizontal size={14} />
          </button>
        </aside>

        <section>
          <div className="mb-4 flex items-center justify-between">
            <h3 className="text-3xl font-semibold text-[#9ec2e5]">{sectionTitle}</h3>
            <div className="flex rounded bg-[#11243f] p-1">
              <button
                onClick={() => setView('table')}
                className={`rounded p-2 ${view === 'table' ? 'bg-[#183758] text-[#35c3ff]' : 'text-[#799ec1]'}`}
              >
                <Table2 size={16} />
              </button>
              <button
                onClick={() => setView('compact')}
                className={`rounded p-2 ${view === 'compact' ? 'bg-[#183758] text-[#35c3ff]' : 'text-[#799ec1]'}`}
              >
                <List size={16} />
              </button>
              <button
                onClick={() => setView('cards')}
                className={`rounded p-2 ${view === 'cards' ? 'bg-[#183758] text-[#35c3ff]' : 'text-[#799ec1]'}`}
              >
                <SlidersHorizontal size={16} />
              </button>
            </div>
          </div>

          <div className="overflow-hidden rounded bg-[#11243f]">
            <div className="grid grid-cols-[1fr_140px_140px_90px] gap-4 px-5 py-4 text-lg font-semibold text-[#93b7db]">
              <p>Title</p>
              <p>Score</p>
              <p>Progress</p>
              <p>Type</p>
            </div>

            {loading && (
              <div className="space-y-2 px-5 py-4">
                {Array.from({ length: 10 }, (_, i) => (
                  <div key={i} className="h-12 animate-pulse rounded bg-[#173154]" />
                ))}
              </div>
            )}

            {!loading && error && <p className="px-5 py-4 text-sm text-red-400">{error}</p>}

            {!loading && !error && visibleItems.map(renderRow)}
            {!loading && !error && visibleItems.length === 0 && (
              <p className="px-5 py-4 text-sm text-[#7395b8]">No anime found for this list.</p>
            )}
          </div>
        </section>
      </div>
    </div>
  );
};

export default ProfileAnimeTab;

