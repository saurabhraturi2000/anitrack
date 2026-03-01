import React, { useState } from 'react';
import {
  Home,
  Flame,
  User,
  Settings as SettingsIcon,
  ChevronDown,
  Layout,
  Bell,
  Info,
  Sliders,
  List,
  LogOut,
  LogIn,
} from 'lucide-react';
import { Navigate, Outlet, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import Watchlist from '@/screens/Watchlist';
import Discover from '@/screens/Discover';
import Profile from '@/screens/Profile';
import RightSidebar from '@/components/RightSidebar';
import { useAuth } from '@/auth/AuthContext';

type DashboardNavTab = {
  id: 'watchlist' | 'discover' | 'profile';
  label: string;
  path: string;
  icon: React.ReactNode;
  activeIcon: React.ReactNode;
};

const DashboardLayout: React.FC = () => {
  const { isAuthenticated, login, logout, loading } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [settingsOpen, setSettingsOpen] = useState(false);

  const tabs: DashboardNavTab[] = [
    {
      id: 'watchlist',
      label: 'Watchlist',
      path: '/dashboard/watchlist',
      icon: <Home size={22} />,
      activeIcon: <Home size={22} fill="#3db4f2" />,
    },
    {
      id: 'discover',
      label: 'Discover',
      path: '/dashboard/discover',
      icon: <Flame size={22} />,
      activeIcon: <Flame size={22} fill="#3db4f2" />,
    },
    {
      id: 'profile',
      label: 'Profile',
      path: '/dashboard/profile',
      icon: <User size={22} />,
      activeIcon: <User size={22} fill="#3db4f2" />,
    },
  ];

  const isActive = (path: string) => location.pathname === path;
  const isWatchlistRoute = location.pathname === '/dashboard/watchlist';

  return (
    <div className="h-screen w-screen bg-[#0b1622] lg:bg-gradient-to-br lg:from-[#0b1622] lg:to-[#111f30]">
      <div className="flex flex-col h-full w-full max-w-md mx-auto shadow-2xl relative overflow-hidden bg-[#0b1622] lg:max-w-none lg:mx-0 lg:flex-row lg:shadow-none">
        <aside className="hidden lg:flex lg:w-72 lg:flex-col lg:justify-between lg:border-r lg:border-[#24354a] lg:bg-[#111f30]/80 lg:p-6">
          <div>
            <h1 className="text-[#f0f1f1] text-2xl font-bold tracking-tight">AniTrack</h1>
            <p className="mt-1 text-xs uppercase tracking-[0.18em] text-[#3db4f2]/80">Watch. Discover. Repeat.</p>

            <nav className="mt-10 space-y-2">
              {tabs.map((tab) => (
                <button
                  key={`desktop-${tab.id}`}
                  onClick={() => navigate(tab.path)}
                  className={`w-full rounded-xl px-4 py-3 transition-all duration-300 ${
                    isActive(tab.path)
                      ? 'bg-[#3db4f2]/15 text-[#3db4f2] ring-1 ring-[#3db4f2]/30'
                      : 'text-gray-400 hover:bg-[#151f2e] hover:text-gray-200'
                  }`}
                >
                  <span className="flex items-center space-x-3 text-sm font-semibold tracking-wide">
                    {isActive(tab.path) ? tab.activeIcon : tab.icon}
                    <span>{tab.label}</span>
                  </span>
                </button>
              ))}
            </nav>
          </div>

          <div className="space-y-3">
            <div className="relative">
              {settingsOpen && (
                <div className="absolute bottom-full left-0 right-0 z-20 mb-2 rounded-xl border border-[#24354a] bg-[#151f2e]/95 p-3 space-y-1 shadow-2xl">
                  {[
                    { icon: <Layout size={16} />, label: 'Appearance' },
                    { icon: <Bell size={16} />, label: 'Push Notifications' },
                    { icon: <Info size={16} />, label: 'About' },
                    { icon: <User size={16} />, label: 'AniList Profile' },
                    { icon: <Sliders size={16} />, label: 'Content Preferences' },
                    { icon: <List size={16} />, label: 'List Preferences' },
                    { icon: <Bell size={16} />, label: 'AniList Notifications' },
                  ].map((item) => (
                    <button
                      key={item.label}
                      className="flex w-full items-center space-x-2 rounded-lg px-3 py-2 text-xs text-gray-300 hover:bg-[#0f1a27]"
                    >
                      <span className="text-[#3db4f2]">{item.icon}</span>
                      <span>{item.label}</span>
                    </button>
                  ))}
                  {!loading && (
                    <button
                      onClick={isAuthenticated ? logout : login}
                      className="mt-2 flex w-full items-center space-x-2 rounded-lg bg-[#3db4f2]/15 px-3 py-2 text-xs font-semibold text-[#3db4f2] hover:bg-[#3db4f2]/20"
                    >
                      {isAuthenticated ? <LogOut size={16} /> : <LogIn size={16} />}
                      <span>{isAuthenticated ? 'Logout' : 'Login with AniList'}</span>
                    </button>
                  )}
                </div>
              )}

              <button
                onClick={() => setSettingsOpen((prev) => !prev)}
                className="flex w-full items-center justify-between rounded-xl border border-[#24354a] bg-[#151f2e]/70 px-4 py-3 text-sm font-semibold text-gray-200 hover:bg-[#1a2a3c]"
              >
                <span className="flex items-center space-x-3">
                  <SettingsIcon size={18} />
                  <span>Settings</span>
                </span>
                <ChevronDown
                  size={16}
                  className={`transition-transform duration-200 ${settingsOpen ? 'rotate-180' : ''}`}
                />
              </button>
            </div>
          </div>
        </aside>

        <div className="relative flex-1 overflow-hidden">
          <main className="flex-1 overflow-hidden h-full">
            <Outlet />
          </main>

          <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md h-20 bg-[#0b1622] flex items-center justify-around px-2 border-t border-gray-900/50 z-50 lg:hidden">
            {tabs.map((tab) => (
              <button
                key={`mobile-${tab.id}`}
                onClick={() => navigate(tab.path)}
                className={`flex flex-col items-center justify-center space-y-1 w-full h-full transition-all duration-300 ${
                  isActive(tab.path) ? 'text-[#3db4f2]' : 'text-gray-600'
                }`}
              >
                <div className={`${isActive(tab.path) ? 'bg-[#3db4f2]/10 p-2 rounded-full ring-4 ring-[#3db4f2]/5' : ''}`}>
                  {isActive(tab.path) ? tab.activeIcon : tab.icon}
                </div>
                <span className={`text-[9px] font-black uppercase tracking-widest ${isActive(tab.path) ? 'opacity-100' : 'opacity-60'}`}>
                  {tab.label}
                </span>
              </button>
            ))}
          </nav>
        </div>

        {isWatchlistRoute && <RightSidebar />}
      </div>
    </div>
  );
};

const AuthCallbackPage: React.FC = () => {
  const navigate = useNavigate();
  const { loading, isAuthenticated, login } = useAuth();

  React.useEffect(() => {
    if (loading) return;
    if (isAuthenticated) {
      navigate('/dashboard/watchlist', { replace: true });
    }
  }, [isAuthenticated, loading, navigate]);

  return (
    <div className="flex h-screen w-screen items-center justify-center bg-[#0b1622] px-6 text-[#f0f1f1]">
      <div className="max-w-md rounded-xl border border-[#24354a] bg-[#151f2e]/90 p-6 text-center">
        <h2 className="text-xl font-bold">Completing AniList Sign-In</h2>
        <p className="mt-2 text-sm text-gray-400">
          {loading
            ? 'Please wait while we finish authentication.'
            : 'Sign-in was not completed. Please try again.'}
        </p>
        {!loading && (
          <button
            onClick={login}
            className="mt-4 rounded-lg bg-[#3db4f2]/20 px-4 py-2 text-sm font-semibold text-[#3db4f2] hover:bg-[#3db4f2]/30"
          >
            Login with AniList
          </button>
        )}
      </div>
    </div>
  );
};

const App: React.FC = () => (
  <Routes>
    <Route path="/auth/callback" element={<AuthCallbackPage />} />
    <Route path="/" element={<Navigate to="/dashboard/watchlist" replace />} />
    <Route path="/dashboard" element={<DashboardLayout />}>
      <Route index element={<Navigate to="watchlist" replace />} />
      <Route path="watchlist" element={<Watchlist />} />
      <Route path="discover" element={<Discover />} />
      <Route path="profile" element={<Profile />} />
    </Route>
    <Route path="*" element={<Navigate to="/dashboard/watchlist" replace />} />
  </Routes>
);

export default App;
