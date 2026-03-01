const ACCESS_TOKEN_KEY = "anitrack.auth.access_token";
const EXPIRES_AT_KEY = "anitrack.auth.expires_at";
const OAUTH_STATE_KEY = "anitrack.auth.state";

export interface Viewer {
  id: number;
  name: string;
  avatarUrl: string;
  bannerImage?: string;
}

export type OAuthSession = {
  accessToken: string;
  expiresAt: number;
};

type ViewerResponse = {
  data?: {
    Viewer?: {
      id: number;
      name: string;
      avatar?: { large?: string | null } | null;
      bannerImage?: string | null;
    };
  };
  errors?: Array<{ message: string }>;
};

const nowMs = () => Date.now();
const ANILIST_GRAPHQL_URL = import.meta.env.DEV
  ? "/api/anilist"
  : (import.meta.env.VITE_ANILIST_GRAPHQL_URL as string | undefined) ||
    "https://graphql.anilist.co";

const getClientId = () =>
  import.meta.env.VITE_ANILIST_CLIENT_ID as string | undefined;
// const getRedirectUri = () => import.meta.env.VITE_ANILIST_REDIRECT_URI as string | undefined;

export const getStoredSession = (): OAuthSession | null => {
  const token = localStorage.getItem(ACCESS_TOKEN_KEY);
  const expiresAtRaw = localStorage.getItem(EXPIRES_AT_KEY);
  if (!token || !expiresAtRaw) return null;

  const expiresAt = Number(expiresAtRaw);
  if (!Number.isFinite(expiresAt) || expiresAt <= nowMs()) {
    clearStoredSession();
    return null;
  }

  return { accessToken: token, expiresAt };
};

export const storeSession = (accessToken: string, expiresInSeconds: number) => {
  const expiresAt = nowMs() + Math.max(1, expiresInSeconds) * 1000;
  localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
  localStorage.setItem(EXPIRES_AT_KEY, String(expiresAt));
};

export const clearStoredSession = () => {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(EXPIRES_AT_KEY);
  sessionStorage.removeItem(OAUTH_STATE_KEY);
};

const generateState = () => {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  let value = "";
  const cryptoObj = globalThis.crypto;
  if (cryptoObj?.getRandomValues) {
    const buffer = new Uint32Array(32);
    cryptoObj.getRandomValues(buffer);
    for (const n of buffer) {
      value += chars[n % chars.length];
    }
    return value;
  }

  for (let i = 0; i < 32; i += 1) {
    value += chars[Math.floor(Math.random() * chars.length)];
  }
  return value;
};

export const buildAuthorizeUrl = () => {
  const clientId = getClientId()?.trim();
  if (!clientId) {
    throw new Error("Missing VITE_ANILIST_CLIENT_ID.");
  }

  const state = generateState();
  sessionStorage.setItem(OAUTH_STATE_KEY, state);

  const params = new URLSearchParams({
    client_id: clientId,
    response_type: "token",
    state,
  });

  // const redirectUri = getRedirectUri()?.trim();
  // if (redirectUri) {
  //   params.set('redirect_uri', redirectUri);
  // }

  return `https://anilist.co/api/v2/oauth/authorize?${params.toString()}`;
};

export const consumeOAuthCallback = (): OAuthSession | null => {
  const hash = window.location.hash?.startsWith("#")
    ? window.location.hash.slice(1)
    : window.location.hash;
  if (!hash) return null;

  const params = new URLSearchParams(hash);
  const token = params.get("access_token");
  const expiresIn = Number(params.get("expires_in") || "0");
  const incomingState = params.get("state");
  const expectedState = sessionStorage.getItem(OAUTH_STATE_KEY);

  if (!token || !Number.isFinite(expiresIn) || expiresIn <= 0) {
    return null;
  }

  if (expectedState && incomingState && expectedState !== incomingState) {
    throw new Error("OAuth state validation failed.");
  }

  storeSession(token, expiresIn);
  sessionStorage.removeItem(OAUTH_STATE_KEY);

  const cleanUrl = `${window.location.origin}${window.location.pathname}${window.location.search}`;
  window.history.replaceState({}, document.title, cleanUrl);

  return getStoredSession();
};

export const fetchViewer = async (accessToken: string): Promise<Viewer> => {
  let response: Response;
  try {
    response = await fetch(ANILIST_GRAPHQL_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        query: `
          query {
            Viewer {
              id
              name
              avatar { large }
              bannerImage
            }
          }
        `,
      }),
    });
  } catch {
    throw new Error("Network request to AniList failed while loading profile.");
  }

  let payload: ViewerResponse;
  try {
    payload = (await response.json()) as ViewerResponse;
  } catch {
    throw new Error(
      `AniList returned an invalid response (HTTP ${response.status}).`,
    );
  }

  const viewer = payload.data?.Viewer;
  if (!response.ok || payload.errors?.length || !viewer) {
    throw new Error(
      payload.errors?.[0]?.message || "Failed to load AniList viewer.",
    );
  }

  return {
    id: viewer.id,
    name: viewer.name,
    avatarUrl: viewer.avatar?.large || "",
    bannerImage: viewer.bannerImage || undefined,
  };
};
