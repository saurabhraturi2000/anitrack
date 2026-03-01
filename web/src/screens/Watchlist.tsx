import React, { useCallback, useEffect, useRef, useState } from 'react';
import { Check, MoreHorizontal, RefreshCw, Tv } from 'lucide-react';
import {
  CurrentListItem,
  fetchWatchlistPage,
  WatchlistPagePhase,
} from '@/services/anilist';
import { useAuth } from '@/auth/AuthContext';

type FeedPhase = WatchlistPagePhase | 'done';
type CacheEntry = {
  userId: number;
  type: 'ANIME' | 'MANGA';
  releasingData: CurrentListItem[];
  finishedData: CurrentListItem[];
  phase: FeedPhase;
  releasingPage: number;
  finishedPage: number;
};

const watchlistFeedCache: Partial<Record<'ANIME' | 'MANGA', CacheEntry>> = {};

const appendUnique = (prev: CurrentListItem[], incoming: CurrentListItem[]) => {
  const seen = new Set(prev.map((item) => item.id));
  const next = incoming.filter((item) => !seen.has(item.id));
  return [...prev, ...next];
};

const Watchlist: React.FC = () => {
  const { isAuthenticated, viewer, login, authError } = useAuth();
  const [contentType, setContentType] = useState<'ANIME' | 'MANGA'>('ANIME');
  const [loadedType, setLoadedType] = useState<'ANIME' | 'MANGA'>('ANIME');
  const [releasingData, setReleasingData] = useState<CurrentListItem[]>([]);
  const [finishedData, setFinishedData] = useState<CurrentListItem[]>([]);
  const [phase, setPhase] = useState<FeedPhase>('releasing');
  const [releasingPage, setReleasingPage] = useState(0);
  const [finishedPage, setFinishedPage] = useState(0);
  const [initialLoading, setInitialLoading] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [watchlistError, setWatchlistError] = useState<string | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [pullDistance, setPullDistance] = useState(0);
  const [pulling, setPulling] = useState(false);
  const loadingRef = useRef(false);
  const scrollRef = useRef<HTMLDivElement | null>(null);
  const touchStartYRef = useRef(0);
  const pullThreshold = 78;

  const resetFeed = useCallback(() => {
    setReleasingData([]);
    setFinishedData([]);
    setPhase('releasing');
    setReleasingPage(0);
    setFinishedPage(0);
    setInitialLoading(false);
    setLoadingMore(false);
    setWatchlistError(null);
    loadingRef.current = false;
  }, []);

  const saveCache = useCallback(() => {
    if (!viewer) return;
    watchlistFeedCache[loadedType] = {
      userId: viewer.id,
      type: loadedType,
      releasingData,
      finishedData,
      phase,
      releasingPage,
      finishedPage,
    };
  }, [finishedData, finishedPage, loadedType, phase, releasingData, releasingPage, viewer]);

  useEffect(() => {
    saveCache();
  }, [saveCache]);

  const loadNextPage = useCallback(
    async (mode: 'initial' | 'more') => {
      if (!isAuthenticated || !viewer) return;
      if (loadingRef.current) return;
      if (mode !== 'initial' && phase === 'done') return;

      loadingRef.current = true;
      if (mode === 'initial') setInitialLoading(true);
      else setLoadingMore(true);
      setWatchlistError(null);

      try {
        const activePhase: FeedPhase = mode === 'initial' ? 'releasing' : phase;
        const baseReleasingPage = mode === 'initial' ? 0 : releasingPage;
        const baseFinishedPage = mode === 'initial' ? 0 : finishedPage;

        if (activePhase === 'releasing') {
          const nextPage = baseReleasingPage + 1;
          const releasingResult = await fetchWatchlistPage({
            userId: viewer.id,
            type: contentType,
            phase: 'releasing',
            page: nextPage,
            perPage: 15,
          });

          setReleasingData((prev) => appendUnique(prev, releasingResult.items));
          setReleasingPage(nextPage);
          setLoadedType(contentType);

          if (releasingResult.hasNextPage) {
            setPhase('releasing');
          } else {
            // After current releasing is exhausted, automatically begin finished pages.
            const nextFinishedPage = 1;
            const finishedResult = await fetchWatchlistPage({
              userId: viewer.id,
              type: contentType,
              phase: 'finished',
              page: nextFinishedPage,
              perPage: 15,
            });

            setFinishedData((prev) => appendUnique(prev, finishedResult.items));
            setFinishedPage(nextFinishedPage);
            setPhase(finishedResult.hasNextPage ? 'finished' : 'done');
            setLoadedType(contentType);
          }
          return;
        }

        const nextPage = baseFinishedPage + 1;
        const finishedResult = await fetchWatchlistPage({
          userId: viewer.id,
          type: contentType,
          phase: 'finished',
          page: nextPage,
          perPage: 15,
        });

        setFinishedData((prev) => appendUnique(prev, finishedResult.items));
        setFinishedPage(nextPage);
        setPhase(finishedResult.hasNextPage ? 'finished' : 'done');
        setLoadedType(contentType);
      } catch (err) {
        setWatchlistError(err instanceof Error ? err.message : 'Failed to load watchlist');
      } finally {
        loadingRef.current = false;
        setInitialLoading(false);
        setLoadingMore(false);
      }
    },
    [contentType, finishedPage, isAuthenticated, phase, releasingPage, viewer]
  );

  const hardRefresh = useCallback(async () => {
    if (!isAuthenticated || !viewer) return;
    setIsRefreshing(true);
    delete watchlistFeedCache[contentType];
    setReleasingData([]);
    setFinishedData([]);
    setPhase('releasing');
    setReleasingPage(0);
    setFinishedPage(0);
    setWatchlistError(null);
    loadingRef.current = false;
    await loadNextPage('initial');
    setIsRefreshing(false);
  }, [contentType, isAuthenticated, loadNextPage, viewer]);

  useEffect(() => {
    if (!isAuthenticated || !viewer) {
      resetFeed();
      return;
    }

    const cached = watchlistFeedCache[contentType];
    if (cached && cached.userId === viewer.id) {
      setReleasingData(cached.releasingData);
      setFinishedData(cached.finishedData);
      setPhase(cached.phase);
      setReleasingPage(cached.releasingPage);
      setFinishedPage(cached.finishedPage);
      setLoadedType(contentType);
      setInitialLoading(false);
      setLoadingMore(false);
      setWatchlistError(null);
      return;
    }

    resetFeed();
    void loadNextPage('initial');
  }, [contentType, isAuthenticated, viewer, resetFeed, loadNextPage]);

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    if (!isAuthenticated || !viewer) return;
    if (initialLoading || loadingMore || phase === 'done') return;

    if (el.scrollHeight <= el.clientHeight + 40) {
      void loadNextPage('more');
    }
  }, [finishedData, initialLoading, isAuthenticated, loadingMore, loadNextPage, phase, releasingData, viewer]);

  const onScroll = () => {
    const el = scrollRef.current;
    if (!el) return;
    if (initialLoading || loadingMore || phase === 'done') return;

    const nearBottom = el.scrollTop + el.clientHeight >= el.scrollHeight - 220;
    if (nearBottom) {
      void loadNextPage('more');
    }
  };

  const onTouchStart = (e: React.TouchEvent<HTMLDivElement>) => {
    const el = scrollRef.current;
    if (!el) return;
    touchStartYRef.current = e.touches[0].clientY;
    if (el.scrollTop <= 0) {
      setPulling(true);
    }
  };

  const onTouchMove = (e: React.TouchEvent<HTMLDivElement>) => {
    if (!pulling) return;
    const el = scrollRef.current;
    if (!el || el.scrollTop > 0) return;
    const delta = Math.max(0, e.touches[0].clientY - touchStartYRef.current);
    setPullDistance(Math.min(120, delta * 0.55));
  };

  const onTouchEnd = () => {
    if (pulling && pullDistance >= pullThreshold && !initialLoading && !loadingMore && !isRefreshing) {
      void hardRefresh();
    }
    setPulling(false);
    setPullDistance(0);
  };

  const renderWatchItem = (item: CurrentListItem) => (
    <div key={item.id} className="bg-[#151f2e] rounded-lg p-3 flex shadow-lg">
      <div className="w-20 h-28 flex-shrink-0 rounded-md overflow-hidden bg-gray-800">
        <img
          src={item.image || 'https://placehold.co/200x300/151f2e/f0f1f1?text=Anime'}
          alt={item.title}
          className="w-full h-full object-cover"
        />
      </div>
      <div className="ml-4 flex-1 flex flex-col justify-between">
        <div>
          <h3 className="text-sm font-semibold text-gray-100 line-clamp-1">{item.title}</h3>
          {item.nextEpisode && (
            <p className="text-[10px] text-gray-500 mt-1">
              Next Ep: {item.nextEpisode.number} | {item.nextEpisode.date}, {item.nextEpisode.time}
            </p>
          )}
        </div>

        <div className="mt-2">
          <div className="flex justify-end text-[10px] text-gray-500 mb-1">
            {item.progress} / {item.total || '?'}
          </div>
          <div className="w-full bg-[#0b1622] rounded-full h-1">
            <div
              className="bg-[#3db4f2] h-1 rounded-full"
              style={{ width: `${item.total > 0 ? (item.progress / item.total) * 100 : 0}%` }}
            />
          </div>
        </div>

        <div className="flex items-center justify-between mt-2">
          <div className="flex items-center space-x-1 bg-[#0b1622] px-2 py-1 rounded text-[#3db4f2] text-xs">
            <span>{item.progress || 0}</span>
            <Check size={12} />
          </div>
          <div className="bg-[#0b1622] p-1.5 rounded">
            <MoreHorizontal size={16} className="text-gray-500" />
          </div>
        </div>
      </div>
    </div>
  );

  const renderSkeletonItem = (key: string) => (
    <div key={key} className="bg-[#151f2e] rounded-lg p-3 flex shadow-lg animate-pulse">
      <div className="w-20 h-28 flex-shrink-0 rounded-md bg-[#223248]" />
      <div className="ml-4 flex-1 flex flex-col justify-between">
        <div>
          <div className="h-4 w-3/4 rounded bg-[#223248]" />
          <div className="mt-2 h-3 w-2/3 rounded bg-[#1c2a3d]" />
        </div>
        <div className="mt-2">
          <div className="mb-2 ml-auto h-3 w-16 rounded bg-[#1c2a3d]" />
          <div className="h-1 w-full rounded bg-[#1c2a3d]" />
        </div>
        <div className="flex items-center justify-between mt-2">
          <div className="h-6 w-12 rounded bg-[#1c2a3d]" />
          <div className="h-6 w-6 rounded bg-[#1c2a3d]" />
        </div>
      </div>
    </div>
  );

  return (
    <div className="relative flex flex-col h-full bg-[#0b1622] text-[#f0f1f1]">
      <div className="flex items-center justify-between px-6 pt-6 pb-2">
        <div className="flex space-x-8">
          <button
            onClick={() => setContentType('ANIME')}
            className={`text-sm font-bold tracking-widest ${contentType === 'ANIME' ? 'text-white border-b-2 border-[#3db4f2] pb-1' : 'text-gray-500'}`}
          >
            ANIME
          </button>
          <button
            onClick={() => setContentType('MANGA')}
            className={`text-sm font-bold tracking-widest ${contentType === 'MANGA' ? 'text-white border-b-2 border-[#3db4f2] pb-1' : 'text-gray-500'}`}
          >
            MANGA
          </button>
        </div>
        <button
          onClick={() => void hardRefresh()}
          disabled={initialLoading || loadingMore || isRefreshing}
          className="inline-flex items-center gap-2 rounded-md bg-[#11243f] px-3 py-2 text-xs font-semibold text-[#9dc3e8] disabled:opacity-60 hover:bg-[#163151]"
          title={`Refresh ${contentType.toLowerCase()} list`}
        >
          <RefreshCw size={14} className={`${isRefreshing ? 'animate-spin' : ''}`} />
          Refresh
        </button>
      </div>

      <div
        ref={scrollRef}
        onScroll={onScroll}
        onTouchStart={onTouchStart}
        onTouchMove={onTouchMove}
        onTouchEnd={onTouchEnd}
        className="watchlist-scroll flex-1 overflow-y-auto px-7 pt-4 pb-24 lg:px-10 lg:pb-8"
      >
        {(pullDistance > 0 || isRefreshing) && (
          <div
            className="mb-2 flex justify-center transition-all"
            style={{ height: `${isRefreshing ? 34 : Math.min(34, pullDistance / 2)}px` }}
          >
            <p className="text-xs text-[#8fb4d8]">
              {isRefreshing
                ? 'Refreshing...'
                : pullDistance >= pullThreshold
                  ? 'Release to refresh'
                  : 'Pull to refresh'}
            </p>
          </div>
        )}
        {!isAuthenticated && (
          <div className="max-w-md mx-auto rounded-xl border border-[#24354a] bg-[#151f2e]/90 p-5">
            <h3 className="text-lg font-bold">Connect AniList</h3>
            <p className="mt-2 text-sm text-gray-400">
              Login to load your watchlist, activities, and notifications.
            </p>
            {authError && <p className="mt-2 text-xs text-red-400">{authError}</p>}
            <button
              onClick={login}
              className="mt-4 rounded-lg bg-[#3db4f2]/20 px-4 py-2 text-sm font-semibold text-[#3db4f2] hover:bg-[#3db4f2]/30"
            >
              Login with AniList
            </button>
          </div>
        )}

        {isAuthenticated && (
          <div className="space-y-6">
            <div className="flex items-center justify-center space-x-2 text-[#3db4f2] mb-2">
              <Tv size={24} />
              <span className="font-bold tracking-widest">RELEASING</span>
            </div>
            <div className="space-y-6">
              {initialLoading
                ? Array.from({ length: 3 }, (_, i) => renderSkeletonItem(`releasing-skeleton-${i}`))
                : releasingData.map(renderWatchItem)}
              {!initialLoading && !watchlistError && releasingData.length === 0 && (
                <p className="text-xs text-gray-500">No releasing titles found.</p>
              )}
            </div>

            <div className="flex items-center justify-center space-x-2 text-[#3db4f2] mb-2">
              <Check size={20} />
              <span className="font-bold tracking-widest">FINISHED</span>
            </div>
            <div className="space-y-6">
              {initialLoading
                ? Array.from({ length: 2 }, (_, i) => renderSkeletonItem(`finished-skeleton-${i}`))
                : finishedData.map(renderWatchItem)}
              {!initialLoading && !watchlistError && finishedData.length === 0 && phase !== 'releasing' && (
                <p className="text-xs text-gray-500">No finished titles found.</p>
              )}
              {watchlistError && <p className="text-xs text-red-400">Failed to load watchlist: {watchlistError}</p>}
              {loadingMore && (
                <div className="space-y-4">
                  {Array.from({ length: 2 }, (_, i) => renderSkeletonItem(`load-more-${i}`))}
                </div>
              )}
              {!loadingMore && phase === 'done' && (
                <p className="text-xs text-gray-500 text-center pt-2">You have reached the end.</p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Watchlist;
