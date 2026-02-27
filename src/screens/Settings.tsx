
import React from 'react';
import { ArrowLeft, User, Layout, Bell, Info, Sliders, List, ChevronRight } from 'lucide-react';

interface SettingsItemProps {
  icon: React.ReactNode;
  label: string;
}

const SettingsItem: React.FC<SettingsItemProps> = ({ icon, label }) => (
  <div className="flex items-center justify-between p-4 bg-[#151f2e] first:rounded-t-xl last:rounded-b-xl border-b border-[#0b1622] last:border-0 active:bg-[#1c2a3d] transition-colors">
    <div className="flex items-center space-x-4">
      <div className="text-[#3db4f2]">
        {icon}
      </div>
      <span className="text-sm font-medium text-gray-300">{label}</span>
    </div>
    <ChevronRight size={18} className="text-gray-500" />
  </div>
);

const Settings: React.FC = () => {
  return (
    <div className="flex flex-col h-full bg-[#0b1622] text-[#f0f1f1]">
      {/* Header */}
      <div className="flex items-center px-6 pt-6 pb-6 relative">
        <ArrowLeft size={24} className="text-gray-400 cursor-pointer" />
        <h2 className="absolute left-1/2 -translate-x-1/2 text-sm font-bold tracking-[0.2em] text-[#3db4f2]">SETTINGS</h2>
      </div>

      <div className="flex-1 overflow-y-auto px-6 space-y-8 pb-24 lg:pb-8">
        {/* App Settings Section */}
        <div>
          <h3 className="text-lg font-bold mb-4 text-gray-200">App Settings</h3>
          <div className="shadow-2xl">
            <SettingsItem icon={<Layout size={20} />} label="Appearance" />
            <SettingsItem icon={<Bell size={20} />} label="Push Notifications" />
            <SettingsItem icon={<Info size={20} />} label="About" />
          </div>
        </div>

        {/* Anilist Settings Section */}
        <div>
          <h3 className="text-lg font-bold mb-4 text-gray-200">Anilist Settings</h3>
          <div className="shadow-2xl">
            <SettingsItem icon={<User size={20} />} label="Profile" />
            <SettingsItem icon={<Sliders size={20} />} label="Content Preferences" />
            <SettingsItem icon={<List size={20} />} label="List Preferences" />
            <SettingsItem icon={<Bell size={20} />} label="Notifications" />
          </div>
        </div>

        {/* Logout Button */}
        <div className="mt-8">
          <button className="w-full bg-[#3db4f2] text-[#0b1622] py-4 rounded-md font-black text-sm tracking-widest uppercase shadow-xl active:scale-95 transition-transform">
            Logout
          </button>
        </div>
      </div>
    </div>
  );
};

export default Settings;
