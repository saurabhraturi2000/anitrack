import React, { useEffect, useState } from 'react';
import {
  Bell,
  BellDot,
  BookOpen,
  Heart,
  MessageSquareText,
  Tv,
  UserPlus,
} from 'lucide-react';
import {
  ActivityFeedItem,
  fetchNotifications,
  fetchRecentActivities,
  NotificationFeedItem,
} from '@/services/anilist';
import { useAuth } from '@/auth/AuthContext';

type FeedTab = 'activities' | 'notifications';

const timeAgo = (epochSeconds?: number) => {
  if (!epochSeconds) {
    return '';
  }

  const now = Date.now();
  const then = epochSeconds * 1000;
  const diffMinutes = Math.floor((now - then) / 60000);
  if (diffMinutes < 1) return 'now';
  if (diffMinutes < 60) return `${diffMinutes}m`;
  const diffHours = Math.floor(diffMinutes / 60);
  if (diffHours < 24) return `${diffHours}h`;
  const diffDays = Math.floor(diffHours / 24);
  if (diffDays < 7) return `${diffDays}d`;
  return `${Math.floor(diffDays / 7)}w`;
};

const ActivityIcon: React.FC<{ kind: ActivityFeedItem['kind'] }> = ({ kind }) => {
  if (kind === 'anime') return <Tv size={18} />;
  if (kind === 'manga') return <BookOpen size={18} />;
  return <MessageSquareText size={18} />;
};

const NotificationIcon: React.FC<{ type: string }> = ({ type }) => {
  if (type === 'FOLLOWING') return <UserPlus size={18} />;
  if (type.includes('LIKE')) return <Heart size={18} />;
  if (type.includes('ACTIVITY')) return <MessageSquareText size={18} />;
  return <BellDot size={18} />;
};

const Avatar: React.FC<{
  image?: string;
  fallback: React.ReactNode;
}> = ({ image, fallback }) => (
  <div className="h-11 w-11 shrink-0 overflow-hidden rounded-lg bg-[#0f1a27] ring-1 ring-[#24354a]">
    {image ? (
      <img
        src={image}
        alt=""
        className="h-full w-full object-cover"
      />
    ) : (
      <div className="flex h-full w-full items-center justify-center text-[#6d8098]">
        {fallback}
      </div>
    )}
  </div>
);

const RightSidebar: React.FC = () => {
  const { isAuthenticated, viewer, login, authError } = useAuth();
  const [activeTab, setActiveTab] = useState<FeedTab>('activities');
  const [activities, setActivities] = useState<ActivityFeedItem[]>([]);
  const [notifications, setNotifications] = useState<NotificationFeedItem[]>([]);
  const [loadingActivities, setLoadingActivities] = useState(true);
  const [loadingNotifications, setLoadingNotifications] = useState(true);
  const [activitiesError, setActivitiesError] = useState<string | null>(null);
  const [notificationsError, setNotificationsError] = useState<string | null>(null);

  useEffect(() => {
    if (!isAuthenticated || !viewer) {
      setLoadingActivities(false);
      setLoadingNotifications(false);
      setActivities([]);
      setNotifications([]);
      setActivitiesError(null);
      setNotificationsError(null);
      return;
    }

    let isMounted = true;

    const loadActivities = async () => {
      setLoadingActivities(true);
      setActivitiesError(null);
      try {
        const data = await fetchRecentActivities(viewer.id, 20);
        if (isMounted) {
          setActivities(data);
        }
      } catch (err) {
        if (isMounted) {
          setActivitiesError(err instanceof Error ? err.message : 'Failed to load activities.');
        }
      } finally {
        if (isMounted) {
          setLoadingActivities(false);
        }
      }
    };

    const loadNotifications = async () => {
      setLoadingNotifications(true);
      setNotificationsError(null);
      try {
        const data = await fetchNotifications(20);
        if (isMounted) {
          setNotifications(data);
        }
      } catch (err) {
        if (isMounted) {
          setNotificationsError(err instanceof Error ? err.message : 'Failed to load notifications.');
        }
      } finally {
        if (isMounted) {
          setLoadingNotifications(false);
        }
      }
    };

    void Promise.all([loadActivities(), loadNotifications()]);
    return () => {
      isMounted = false;
    };
  }, [isAuthenticated, viewer]);

  return (
    <aside className="flex h-[45vh] flex-col border-t border-[#24354a] bg-[#111f30]/80 lg:h-auto lg:w-96 lg:border-l lg:border-t-0">
      <div className="border-b border-[#24354a] p-4">
        <div className="rounded-xl bg-[#151f2e] p-1">
          <button
            onClick={() => setActiveTab('activities')}
            className={`w-1/2 rounded-lg px-4 py-2 text-xs font-bold uppercase tracking-[0.2em] transition ${
              activeTab === 'activities'
                ? 'bg-[#3db4f2]/20 text-[#3db4f2]'
                : 'text-gray-400 hover:text-gray-200'
            }`}
          >
            Activities
          </button>
          <button
            onClick={() => setActiveTab('notifications')}
            className={`w-1/2 rounded-lg px-4 py-2 text-xs font-bold uppercase tracking-[0.2em] transition ${
              activeTab === 'notifications'
                ? 'bg-[#3db4f2]/20 text-[#3db4f2]'
                : 'text-gray-400 hover:text-gray-200'
            }`}
          >
            Notifications
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-3">
        {!isAuthenticated && (
          <div className="rounded-xl border border-[#24354a] bg-[#151f2e]/90 p-4">
            <p className="text-sm font-semibold text-gray-100">Connect AniList</p>
            <p className="mt-1 text-xs text-gray-400">
              Sign in to see your activities and notifications.
            </p>
            {authError && (
              <p className="mt-2 text-xs text-red-400">{authError}</p>
            )}
            <button
              onClick={login}
              className="mt-3 rounded-lg bg-[#3db4f2]/20 px-3 py-2 text-xs font-semibold text-[#3db4f2] hover:bg-[#3db4f2]/30"
            >
              Login with AniList
            </button>
          </div>
        )}

        {isAuthenticated && activeTab === 'activities' && (
          <>
            {loadingActivities && <p className="text-xs text-gray-500">Loading activities...</p>}
            {activitiesError && <p className="text-xs text-red-400">{activitiesError}</p>}
            {!loadingActivities && !activitiesError && activities.length === 0 && (
              <p className="text-xs text-gray-500">No recent activities yet.</p>
            )}
            {activities.map((item) => (
              <div
                key={item.id}
                className="flex items-start gap-3 rounded-xl border border-[#24354a] bg-[#151f2e]/90 p-3"
              >
                <Avatar image={item.image} fallback={<ActivityIcon kind={item.kind} />} />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold text-gray-100">{item.title}</p>
                  <p className="mt-1 line-clamp-2 text-xs text-gray-400">{item.subtitle}</p>
                </div>
                <p className="text-[11px] text-gray-500">{timeAgo(item.createdAt)}</p>
              </div>
            ))}
          </>
        )}

        {isAuthenticated && activeTab === 'notifications' && (
          <>
            {loadingNotifications && <p className="text-xs text-gray-500">Loading notifications...</p>}
            {notificationsError && (
              <p className="text-xs text-red-400">
                {notificationsError.includes('Unauthorized')
                  ? 'Notifications require AniList authentication.'
                  : notificationsError}
              </p>
            )}
            {!loadingNotifications && !notificationsError && notifications.length === 0 && (
              <p className="text-xs text-gray-500">No notifications yet.</p>
            )}
            {notifications.map((item) => (
              <div
                key={item.id}
                className="flex items-start gap-3 rounded-xl border border-[#24354a] bg-[#151f2e]/90 p-3"
              >
                <Avatar image={item.image} fallback={<NotificationIcon type={item.type} />} />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-semibold text-gray-100">{item.title}</p>
                  <p className="mt-1 line-clamp-2 text-xs text-gray-400">{item.subtitle}</p>
                </div>
                <p className="text-[11px] text-gray-500">{timeAgo(item.createdAt)}</p>
              </div>
            ))}
          </>
        )}
      </div>

      <div className="border-t border-[#24354a] p-4">
        <div className="rounded-xl bg-[#151f2e]/80 px-4 py-3 text-xs text-gray-400">
          <p className="flex items-center gap-2">
            <Bell size={14} className="text-[#3db4f2]" />
            Live feed synced to AniList API
          </p>
        </div>
      </div>
    </aside>
  );
};

export default RightSidebar;
