import React from 'react';
import { ArrowRight, Download, LayoutGrid, Play, Smartphone, UserRound } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useAuth } from '@/auth/AuthContext';

const APP_DOWNLOAD_URL =
  'https://github.com/saurabhraturi2000/anitrack/releases/latest/download/app-release.apk';
const WEB_DASHBOARD_SCREENSHOT = `${import.meta.env.BASE_URL}screenshots/web-dashboard.png`;
const MOBILE_HOME_SCREENSHOT = `${import.meta.env.BASE_URL}screenshots/mobile-home.png`;

const previewItems = [
  { title: 'Watchlist sync', icon: <LayoutGrid className="h-4 w-4" /> },
  { title: 'Profile view', icon: <UserRound className="h-4 w-4" /> },
  { title: 'Android app', icon: <Smartphone className="h-4 w-4" /> },
];

const Landing: React.FC = () => {
  const { isAuthenticated } = useAuth();
  const continuePath = isAuthenticated ? '/dashboard/watchlist' : '/dashboard/discover';

  return (
    <div className="landing-scroll h-screen overflow-y-auto bg-[#0b1622] text-[#f0f1f1]">
      <div className="mx-auto flex min-h-full w-full max-w-6xl flex-col px-5 pb-12 pt-5 sm:px-6 lg:px-8">
        <header className="flex items-center justify-between gap-4">
          <Link to="/" className="flex items-center gap-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-2xl bg-[#3db4f2] text-[#0b1622]">
              <Play className="h-4 w-4 fill-current" />
            </span>
            <div>
              <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[#7f93a8]">AniTrack</p>
            </div>
          </Link>

          <div className="flex items-center gap-3">
            <a
              href={APP_DOWNLOAD_URL}
              className="rounded-xl border border-[#24354a] bg-[#151f2e] px-4 py-2.5 text-sm font-semibold text-[#f0f1f1] transition hover:bg-[#1a2a3c]"
            >
              Download
            </a>
            <Link
              to={continuePath}
              className="rounded-xl bg-[#3db4f2] px-4 py-2.5 text-sm font-semibold text-[#0b1622] transition hover:bg-[#67c7ff]"
            >
              Continue on web
            </Link>
          </div>
        </header>

        <main className="flex flex-1 items-center">
          <section className="mx-auto grid w-full max-w-5xl gap-10 py-12 lg:grid-cols-[minmax(0,1fr)_300px] lg:items-start">
            <div className="max-w-2xl">
              <p className="text-sm font-semibold uppercase tracking-[0.25em] text-[#3db4f2]">
                Watch. Discover. Repeat.
              </p>

              <h1 className="mt-4 text-4xl font-bold leading-tight text-[#f0f1f1] sm:text-5xl">
                One place for your anime tracking on web and Android.
              </h1>

              <p className="mt-5 max-w-xl text-lg leading-8 text-[#93a8bd]">
                AniTrack helps you continue your watchlist, explore new shows, and keep your AniList profile close whether you are on desktop or mobile.
              </p>

              <div className="mt-8 flex flex-col gap-3 sm:flex-row">
                <Link
                  to={continuePath}
                  className="inline-flex items-center justify-center gap-2 rounded-xl bg-[#3db4f2] px-5 py-3 text-sm font-semibold text-[#0b1622] transition hover:bg-[#67c7ff]"
                >
                  Continue to website
                  <ArrowRight className="h-4 w-4" />
                </Link>
                <a
                  href={APP_DOWNLOAD_URL}
                  className="inline-flex items-center justify-center gap-2 rounded-xl border border-[#24354a] bg-[#151f2e] px-5 py-3 text-sm font-semibold text-[#f0f1f1] transition hover:bg-[#1a2a3c]"
                >
                  Download Android app
                  <Download className="h-4 w-4" />
                </a>
              </div>

              <div className="mt-10 grid gap-4 sm:grid-cols-3">
                {previewItems.map((item) => (
                  <div key={item.title} className="rounded-2xl border border-[#24354a] bg-[#151f2e] p-4">
                    <div className="inline-flex h-10 w-10 items-center justify-center rounded-xl bg-[#0f1a27] text-[#3db4f2]">
                      {item.icon}
                    </div>
                    <p className="mt-4 text-sm font-semibold text-[#f0f1f1]">{item.title}</p>
                    <p className="mt-2 text-sm leading-6 text-[#93a8bd]">
                      Browse your synced lists, jump into the web dashboard, or continue from the Android app.
                    </p>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex justify-center lg:justify-end">
              <img
                src={MOBILE_HOME_SCREENSHOT}
                alt="AniTrack Android app screenshot"
                className="h-auto max-h-[620px] w-auto max-w-full rounded-[18px] border border-[#24354a] shadow-2xl"
              />
            </div>

            <div className="lg:col-span-2">
              <img
                src={WEB_DASHBOARD_SCREENSHOT}
                alt="AniTrack web dashboard screenshot"
                className="h-auto w-full rounded-[18px] border border-[#24354a] shadow-2xl"
              />
            </div>
          </section>
        </main>
      </div>
    </div>
  );
};

export default Landing;
