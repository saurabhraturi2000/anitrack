import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import {
  buildAuthorizeUrl,
  clearStoredSession,
  consumeOAuthCallback,
  fetchViewer,
  getStoredSession,
  Viewer,
} from '@/auth/auth';

type AuthContextValue = {
  loading: boolean;
  isAuthenticated: boolean;
  viewer: Viewer | null;
  authError: string | null;
  login: () => void;
  logout: () => void;
};

const AuthContext = createContext<AuthContextValue | null>(null);

export const AuthProvider: React.FC<React.PropsWithChildren> = ({ children }) => {
  const [loading, setLoading] = useState(true);
  const [viewer, setViewer] = useState<Viewer | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const initialize = async () => {
      setLoading(true);
      setAuthError(null);
      try {
        consumeOAuthCallback();
      } catch (err) {
        clearStoredSession();
        setAuthError(err instanceof Error ? err.message : 'OAuth callback failed.');
      }

      const session = getStoredSession();
      if (!session) {
        if (isMounted) {
          setViewer(null);
          setLoading(false);
        }
        return;
      }

      try {
        const me = await fetchViewer(session.accessToken);
        if (isMounted) {
          setViewer(me);
          setAuthError(null);
        }
      } catch (err) {
        clearStoredSession();
        if (isMounted) {
          setViewer(null);
          setAuthError(err instanceof Error ? err.message : 'Failed to load AniList profile.');
        }
      } finally {
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    void initialize();
    return () => {
      isMounted = false;
    };
  }, []);

  const login = () => {
    const url = buildAuthorizeUrl();
    window.location.assign(url);
  };

  const logout = () => {
    clearStoredSession();
    setViewer(null);
    setAuthError(null);
  };

  const value = useMemo<AuthContextValue>(
    () => ({
      loading,
      isAuthenticated: Boolean(viewer),
      viewer,
      authError,
      login,
      logout,
    }),
    [authError, loading, viewer]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextValue => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used inside AuthProvider');
  }
  return context;
};
