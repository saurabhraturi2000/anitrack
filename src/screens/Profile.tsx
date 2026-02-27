
import React from 'react';

const Profile: React.FC = () => {
  return (
    <div className="flex flex-col items-center justify-center h-full bg-[#0b1622] text-[#f0f1f1]">
      <div className="w-24 h-24 rounded-full overflow-hidden bg-gray-700 border-4 border-[#3db4f2] mb-4">
        <img src="https://picsum.photos/seed/user/200/200" alt="Profile" className="w-full h-full object-cover" />
      </div>
      <h2 className="text-xl font-bold">Otaku User</h2>
      <p className="text-gray-500 text-sm mt-1">Lover of all things shonen</p>
      
      <div className="mt-8 grid grid-cols-3 gap-8 text-center">
        <div>
          <p className="text-[#3db4f2] font-bold text-lg">243</p>
          <p className="text-[10px] text-gray-500 uppercase font-black">Anime</p>
        </div>
        <div>
          <p className="text-[#3db4f2] font-bold text-lg">82</p>
          <p className="text-[10px] text-gray-500 uppercase font-black">Manga</p>
        </div>
        <div>
          <p className="text-[#3db4f2] font-bold text-lg">1.2k</p>
          <p className="text-[10px] text-gray-500 uppercase font-black">Days</p>
        </div>
      </div>
    </div>
  );
};

export default Profile;
