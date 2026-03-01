import React, { useEffect, useMemo, useState } from "react";
import { ChevronDown, Heart, LogIn, LogOut, MessageCircle } from "lucide-react";
import { useAuth } from "@/auth/AuthContext";
import { fetchProfileOverview, ProfileOverviewData } from "@/services/anilist";

type ProfileTabKey =
  | "overview"
  | "anime-list"
  | "manga-list"
  | "favorites"
  | "stats"
  | "social"
  | "reviews"
  | "submissions";

const profileTabs: Array<{ key: ProfileTabKey; label: string }> = [
  { key: "overview", label: "Overview" },
  { key: "anime-list", label: "Anime List" },
  { key: "manga-list", label: "Manga List" },
  { key: "favorites", label: "Favorites" },
  { key: "stats", label: "Stats" },
  { key: "social", label: "Social" },
  { key: "reviews", label: "Reviews" },
  { key: "submissions", label: "Submissions" },
];

const timeAgo = (epochSeconds: number) => {
  const diff = Math.max(0, Math.floor(Date.now() / 1000) - epochSeconds);
  if (diff < 60) return "now";
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
  if (diff < 604800) return `${Math.floor(diff / 86400)}d ago`;
  return `${Math.floor(diff / 604800)}w ago`;
};

const formatNumber = (value: number) =>
  new Intl.NumberFormat().format(Math.round(value));
const formatOneDecimal = (value: number) => value.toFixed(1);

const genreColors = [
  "#73e043",
  "#1db4ff",
  "#8c5cff",
  "#ff7ac2",
  "#ff6584",
  "#f3a857",
  "#40e0cf",
  "#60a5fa",
];

const Profile: React.FC = () => {
  const { isAuthenticated, viewer, login, logout, authError } = useAuth();
  const [activeTab, setActiveTab] = useState<ProfileTabKey>("overview");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [overview, setOverview] = useState<ProfileOverviewData | null>(null);

  useEffect(() => {
    if (!isAuthenticated || !viewer) {
      setOverview(null);
      setError(null);
      setLoading(false);
      return;
    }

    let isActive = true;
    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await fetchProfileOverview(viewer.id, {
          recentPerPage: 8,
          historyPerPage: 260,
        });
        if (isActive) {
          setOverview(data);
        }
      } catch (err) {
        if (isActive) {
          setError(
            err instanceof Error
              ? err.message
              : "Failed to load profile overview.",
          );
        }
      } finally {
        if (isActive) {
          setLoading(false);
        }
      }
    };

    void load();
    return () => {
      isActive = false;
    };
  }, [isAuthenticated, viewer]);

  const historyCells = useMemo(() => {
    const cellCount = 270;
    const dayMs = 86400000;
    const today = new Date();
    const start = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate() - (cellCount - 1),
    );
    const countsByDay = new Map<number, number>();

    for (const ts of overview?.historyTimestamps || []) {
      const date = new Date(ts * 1000);
      const key = new Date(
        date.getFullYear(),
        date.getMonth(),
        date.getDate(),
      ).getTime();
      countsByDay.set(key, (countsByDay.get(key) || 0) + 1);
    }

    let maxCount = 0;
    for (const count of countsByDay.values()) {
      if (count > maxCount) maxCount = count;
    }

    return Array.from({ length: cellCount }, (_, idx) => {
      const day = start.getTime() + idx * dayMs;
      const count = countsByDay.get(day) || 0;
      if (count === 0) return "#020b19";
      if (maxCount <= 1) return "#24c8ff";
      const ratio = count / maxCount;
      if (ratio < 0.25) return "#1a3251";
      if (ratio < 0.5) return "#2d4b73";
      if (ratio < 0.8) return "#5f7ca2";
      return "#24c8ff";
    });
  }, [overview?.historyTimestamps]);

  if (!isAuthenticated) {
    return (
      <div className="flex h-full flex-col items-center justify-center bg-[#0b1622] px-6 text-[#f0f1f1]">
        <h2 className="text-2xl font-bold">Connect AniList</h2>
        <p className="mt-2 text-center text-sm text-gray-400">
          Sign in to sync your watchlist, activities, and profile data.
        </p>
        {authError && (
          <p className="mt-2 text-center text-xs text-red-400">{authError}</p>
        )}
        <button
          onClick={login}
          className="mt-6 inline-flex items-center gap-2 rounded-lg bg-[#3db4f2]/20 px-4 py-2 text-sm font-semibold text-[#3db4f2] hover:bg-[#3db4f2]/30"
        >
          <LogIn size={16} />
          Login with AniList
        </button>
      </div>
    );
  }

  const renderMockTab = () => (
    <div className="mx-auto w-full max-w-[1280px] px-6 py-6">
      <div className="rounded bg-[#11243f] p-8">
        <h3 className="text-2xl font-bold text-[#8db2d7]">
          {profileTabs.find((tab) => tab.key === activeTab)?.label}
        </h3>
        <p className="mt-2 text-sm text-[#7395b8]">
          This tab is wired and functional. Share the desired content for this
          section and I will implement it.
        </p>
      </div>
    </div>
  );

  return (
    <div className="profile-scroll h-full overflow-y-auto bg-[#051325] text-[#eaf4ff]">
      <div className="relative h-64 w-full overflow-hidden">
        <img
          src={
            viewer?.bannerImage ||
            "https://picsum.photos/seed/bannerfx/1920/420"
          }
          alt="Profile banner"
          className="h-full w-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-black/10 via-[#07182f]/40 to-[#06162b]" />
        <div className="absolute bottom-0 left-0 right-0 mx-auto flex w-full max-w-[1280px] items-end gap-4 px-6 pb-4">
          <div className="h-44 w-36 overflow-hidden rounded-md border border-[#2f4c6e] bg-[#0f233c] shadow-xl">
            <img
              src={
                viewer?.avatarUrl || "https://picsum.photos/seed/user/240/300"
              }
              alt="Profile avatar"
              className="h-full w-full object-cover"
            />
          </div>
          <h1 className="pb-4 text-4xl font-bold tracking-tight text-white">
            {viewer?.name || "AniList User"}
          </h1>
        </div>
      </div>

      <div className="border-y border-[#183353] bg-[#0f2037]">
        <div className="mx-auto flex w-full max-w-[1280px] flex-wrap items-center justify-between px-6">
          <div className="flex flex-wrap">
            {profileTabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`px-5 py-4 text-sm font-semibold ${
                  activeTab === tab.key
                    ? "text-[#34c3ff]"
                    : "text-[#84a7cb] hover:text-[#bcd3eb]"
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
          <button
            onClick={logout}
            className="mb-2 mt-2 inline-flex items-center gap-2 rounded-md bg-[#132844] px-3 py-2 text-xs font-semibold text-[#8db4dc] hover:bg-[#1a3352]"
          >
            <LogOut size={14} />
            Logout
          </button>
        </div>
      </div>

      {activeTab !== "overview" && renderMockTab()}

      {activeTab === "overview" && (
        <div className="mx-auto grid w-full max-w-[1280px] grid-cols-1 gap-6 px-6 py-6 xl:grid-cols-[44%_56%]">
          <div className="space-y-5">
            <div className="rounded bg-[#11243f] p-4">
              <p className="mb-3 text-xl font-bold text-[#8db2d7]">
                Activity History
              </p>
              <div className="grid grid-cols-[repeat(30,minmax(0,1fr))] gap-2 rounded bg-[#0d1d34] p-3">
                {historyCells.map((color, idx) => (
                  <span
                    key={idx}
                    className="h-3 w-3 rounded-sm"
                    style={{ backgroundColor: color }}
                  />
                ))}
              </div>
            </div>

            <div className="rounded bg-[#11243f] p-4">
              <p className="mb-4 text-xl font-bold text-[#8db2d7]">
                Genre Overview
              </p>
              <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
                {(overview?.anime.genres || [])
                  .slice(0, 8)
                  .map((genre, idx) => (
                    <div key={genre.genre} className="rounded bg-[#10213a] p-2">
                      <p
                        className="inline-block rounded px-3 py-1 text-xs font-semibold text-white"
                        style={{
                          backgroundColor:
                            genreColors[idx % genreColors.length],
                        }}
                      >
                        {genre.genre}
                      </p>
                      <p
                        className="mt-2 text-lg font-bold"
                        style={{ color: genreColors[idx % genreColors.length] }}
                      >
                        {genre.count}
                        <span className="ml-1 text-xs font-medium text-[#5f7b9a]">
                          Entries
                        </span>
                      </p>
                    </div>
                  ))}
              </div>
              {(overview?.anime.genres?.length || 0) > 0 && (
                <div className="mt-4 flex h-3 w-full overflow-hidden rounded">
                  {(overview?.anime.genres || [])
                    .slice(0, 8)
                    .map((genre, idx) => {
                      const total = (overview?.anime.genres || [])
                        .slice(0, 8)
                        .reduce((acc, item) => acc + item.count, 0);
                      return (
                        <span
                          key={genre.genre}
                          style={{
                            backgroundColor:
                              genreColors[idx % genreColors.length],
                            width: `${total > 0 ? (genre.count / total) * 100 : 0}%`,
                          }}
                        />
                      );
                    })}
                </div>
              )}
            </div>
          </div>

          <div className="space-y-5">
            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
              <div className="rounded bg-[#11243f] p-4">
                <div className="grid grid-cols-3 gap-2 text-center">
                  <div>
                    <p className="text-2xl font-bold text-[#36c2ff]">
                      {formatNumber(overview?.anime.count || 0)}
                    </p>
                    <p className="text-xs text-[#6f92b5]">Total Anime</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#36c2ff]">
                      {formatOneDecimal(
                        (overview?.anime.minutesWatched || 0) / 1440,
                      )}
                    </p>
                    <p className="text-xs text-[#6f92b5]">Days Watched</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#36c2ff]">
                      {formatOneDecimal(overview?.anime.meanScore || 0)}
                    </p>
                    <p className="text-xs text-[#6f92b5]">Mean Score</p>
                  </div>
                </div>
              </div>
              <div className="rounded bg-[#11243f] p-4">
                <div className="grid grid-cols-3 gap-2 text-center">
                  <div>
                    <p className="text-2xl font-bold text-[#36c2ff]">
                      {formatNumber(overview?.manga.count || 0)}
                    </p>
                    <p className="text-xs text-[#6f92b5]">Total Manga</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#36c2ff]">
                      {formatNumber(overview?.manga.chaptersRead || 0)}
                    </p>
                    <p className="text-xs text-[#6f92b5]">Chapters Read</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-[#36c2ff]">
                      {formatOneDecimal(overview?.manga.meanScore || 0)}
                    </p>
                    <p className="text-xs text-[#6f92b5]">Mean Score</p>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <div className="mb-2 flex items-center justify-between">
                <p className="text-xl font-bold text-[#8db2d7]">Activity</p>
                <button className="inline-flex items-center gap-1 text-sm font-semibold text-[#8db2d7] hover:text-[#c2d8ef]">
                  Filter <ChevronDown size={14} />
                </button>
              </div>
              <div className="mb-4 rounded bg-[#11243f] px-4 py-3 text-sm text-[#5d7ea3]">
                Write a status...
              </div>

              {loading && (
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  {Array.from({ length: 6 }, (_, idx) => (
                    <div
                      key={idx}
                      className="flex gap-3 rounded bg-[#11243f] p-3 animate-pulse"
                    >
                      <div className="h-28 w-20 rounded bg-[#1d3350]" />
                      <div className="flex-1 space-y-3">
                        <div className="h-4 w-5/6 rounded bg-[#1d3350]" />
                        <div className="h-4 w-4/6 rounded bg-[#1d3350]" />
                        <div className="h-3 w-2/6 rounded bg-[#1d3350]" />
                      </div>
                    </div>
                  ))}
                </div>
              )}

              {!loading && error && (
                <p className="text-sm text-red-400">{error}</p>
              )}

              {!loading && !error && (
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  {(overview?.activities || []).map((item) => (
                    <div
                      key={item.id}
                      className="flex gap-3 rounded bg-[#11243f] p-3"
                    >
                      <img
                        src={
                          item.image ||
                          "https://placehold.co/90x120/0f2138/9bb4cf?text=Ani"
                        }
                        alt=""
                        className="h-28 w-20 rounded object-cover"
                      />
                      <div className="flex flex-1 flex-col justify-between">
                        <p className="line-clamp-3 text-sm text-[#32bdff]">
                          {item.title}
                        </p>
                        <p className="line-clamp-1 text-xs text-[#8db2d7]">
                          {item.subtitle}
                        </p>
                        <div className="flex items-center justify-between">
                          <p className="text-xs font-semibold text-[#7997b6]">
                            {timeAgo(item.createdAt)}
                          </p>
                          <div className="flex items-center gap-2 text-[#8aaace]">
                            <MessageCircle size={14} />
                            <Heart size={14} />
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                  {(overview?.activities.length || 0) === 0 && (
                    <p className="text-sm text-[#7395b8]">
                      No recent activity.
                    </p>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Profile;
