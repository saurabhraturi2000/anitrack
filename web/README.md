<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

View your app in AI Studio: https://ai.studio/apps/drive/1RQiT_uBvyv13-PoP3HeUh5rxoxRT585m

## Run Locally

**Prerequisites:**  Node.js


1. Install dependencies:
   `npm install`
2. Set the `GEMINI_API_KEY` in [.env.local](.env.local) to your Gemini API key
3. Set AniList auth values in `.env.local`:
   - `VITE_ANILIST_CLIENT_ID=your_anilist_client_id`
   - `VITE_ANILIST_REDIRECT_URI=http://localhost:3000/auth/callback`
4. Run the app:
   `npm run dev`

## AniList OAuth Redirect URL

Register this redirect URL in your AniList developer app settings:

`http://localhost:3000/auth/callback`

For production, register your production callback URL too (same path is recommended):

`https://your-domain.com/auth/callback`
