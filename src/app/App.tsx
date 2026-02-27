
import React, { useState } from 'react';
import { Home, Flame, User, Settings as SettingsIcon } from 'lucide-react';
import Watchlist from '@/screens/Watchlist';
import Discover from '@/screens/Discover';
import Profile from '@/screens/Profile';
import Settings from '@/screens/Settings';
import { TabType } from '@/types';

const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<TabType>('home');
  const tabs: { id: TabType; label: string; icon: React.ReactNode; activeIcon: React.ReactNode }[] = [
    {
      id: 'home',
      label: 'Home',
      icon: <Home size={22} />,
      activeIcon: <Home size={22} fill="#3db4f2" />,
    },
    {
      id: 'discover',
      label: 'Discover',
      icon: <Flame size={22} />,
      activeIcon: <Flame size={22} fill="#3db4f2" />,
    },
    {
      id: 'profile',
      label: 'Profile',
      icon: <User size={22} />,
      activeIcon: <User size={22} fill="#3db4f2" />,
    },
    {
      id: 'settings',
      label: 'Settings',
      icon: <SettingsIcon size={22} />,
      activeIcon: <SettingsIcon size={22} fill="#3db4f2" />,
    },
  ];

  const renderContent = () => {
    switch (activeTab) {
      case 'home': return <Watchlist />;
      case 'discover': return <Discover />;
      case 'profile': return <Profile />;
      case 'settings': return <Settings />;
      default: return <Watchlist />;
    }
  };

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
                  onClick={() => setActiveTab(tab.id)}
                  className={`w-full rounded-xl px-4 py-3 transition-all duration-300 ${
                    activeTab === tab.id
                      ? 'bg-[#3db4f2]/15 text-[#3db4f2] ring-1 ring-[#3db4f2]/30'
                      : 'text-gray-400 hover:bg-[#151f2e] hover:text-gray-200'
                  }`}
                >
                  <span className="flex items-center space-x-3 text-sm font-semibold tracking-wide">
                    {activeTab === tab.id ? tab.activeIcon : tab.icon}
                    <span>{tab.label}</span>
                  </span>
                </button>
              ))}
            </nav>
          </div>

          <div className="rounded-xl bg-[#151f2e]/80 p-4 text-xs text-gray-400">
            Desktop view inspired by mobile layout
          </div>
        </aside>

        <div className="relative flex-1 overflow-hidden">
          {/* Dynamic Page Content */}
          <main className="flex-1 overflow-hidden h-full">
            {renderContent()}
          </main>

          {/* Bottom Navigation */}
          <nav className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-md h-20 bg-[#0b1622] flex items-center justify-around px-2 border-t border-gray-900/50 z-50 lg:hidden">
            {tabs.map((tab) => (
              <button
                key={`mobile-${tab.id}`}
                onClick={() => setActiveTab(tab.id)}
                className={`flex flex-col items-center justify-center space-y-1 w-full h-full transition-all duration-300 ${
                  activeTab === tab.id ? 'text-[#3db4f2]' : 'text-gray-600'
                }`}
              >
                <div className={`${activeTab === tab.id ? 'bg-[#3db4f2]/10 p-2 rounded-full ring-4 ring-[#3db4f2]/5' : ''}`}>
                  {activeTab === tab.id ? tab.activeIcon : tab.icon}
                </div>
                <span className={`text-[9px] font-black uppercase tracking-widest ${activeTab === tab.id ? 'opacity-100' : 'opacity-60'}`}>
                  {tab.label}
                </span>
              </button>
            ))}
          </nav>
        </div>
      </div>
    </div>
  );
};

export default App;
