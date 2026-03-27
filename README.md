# Prompt Arena

A head-to-head AI generation ranking app where users vote between two images and the system updates Elo ratings in real time using Supabase.

## What It Does

- Presents two generations and lets users vote for the better one.
- Updates ratings through a Postgres RPC (`update_elo`) to keep scoring logic in the database.
- Supports account creation/sign-in with Supabase Auth.
- Lets authenticated users upload images to Supabase Storage.
- Shows a leaderboard with top Elo-rated generations and a rating distribution chart.
- Includes profile stats (uploads, highest Elo) and dark/light theme toggle.

## Tech Stack

- **Frontend:** Nuxt 4, Vue 3, Tailwind CSS
- **Backend:** Supabase (Postgres, Auth, Storage, RPC)
- **Extras:** Nuxt Icon, VueUse, Nuxt Color Mode

## Screens / Routes

- `/` - Vote between two generations
- `/leaderboard` - Top rated generations
- `/login` - Sign in / sign up
- `/upload` - Upload a generation (auth required)
- `/profile` - Personal uploads and stats (auth required)

## Quick Start

### 1) Install dependencies

```bash
npm install
```

### 2) Configure environment variables

Copy `.env.example` to `.env` and fill in your Supabase project values.

```bash
cp .env.example .env
```

Current example keys:

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_KEY=your_supabase_anon_key_here
```

If your Nuxt Supabase module setup expects `NUXT_PUBLIC_SUPABASE_URL` and `NUXT_PUBLIC_SUPABASE_KEY`, use those names instead.

### 3) Create Supabase schema and policies

Run these SQL files in your Supabase SQL editor (in this order):

1. `supabase_schema.sql`
2. `upload_migration.sql`
3. `fix_rls.sql` (if you need to re-apply or fix policies)

Optional checks:

- `check_db.sql` to inspect table data and policies

### 4) Start development server

```bash
npm run dev
```

Open `http://localhost:3000`.

## NPM Scripts

- `npm run dev` - Start local dev server
- `npm run build` - Build for production
- `npm run preview` - Preview production build locally
- `npm run generate` - Generate static output

## Database Notes

- `generations` stores uploaded content URLs and Elo ratings.
- `votes` stores winner/loser vote events.
- `update_elo(winner_id, loser_id)` applies Elo updates atomically and logs a vote.

## MVP Status / Next Improvements

- Current pairing logic fetches a pool and picks close Elo matches client-side.
- A server-side pair-selection RPC is a good next step for scalability.
- Add stricter anti-abuse checks (rate limits, duplicate-vote protection).
- Add tests around Elo update and auth/upload flows.

## Deployment

This is a Nuxt app and can be deployed to platforms like Vercel, Netlify, or a Node host.
Make sure production environment variables match your Supabase project.
