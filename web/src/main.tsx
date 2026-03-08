
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from '@/app/App';
import { AuthProvider } from '@/auth/AuthContext';

const routerBasename = (() => {
  const baseUrl = import.meta.env.BASE_URL;
  if (!baseUrl || baseUrl === '/') {
    return undefined;
  }

  return baseUrl.replace(/\/$/, '');
})();

const rootElement = document.getElementById('root');
if (!rootElement) {
  throw new Error("Could not find root element to mount to");
}

const root = ReactDOM.createRoot(rootElement);
root.render(
  <React.StrictMode>
    <BrowserRouter basename={routerBasename}>
      <AuthProvider>
        <App />
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>
);
