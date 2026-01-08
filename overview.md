# 🚀 Supabase + Nuxt: Project Concepts (Mid-Level)

## 🎨 Project 1: "PixelParty" (Realtime Collaborative Canvas)
**Concept:** A massively multiplayer 20x20 grid where users paint pixels in real-time. A clone of Reddit's r/place but simplified for a 2-3 hour build.

### 🛠 Tech Stack
- **Frontend:** Nuxt 3 (Tailwind CSS for grid).
- **Backend:** Supabase (Postgres, Realtime, Edge Functions).

### ✅ MVP Features (The "Must Haves")
- [ ] **Interactive Grid:** A 20x20 CSS grid rendering individual divs.
- [ ] **State Sync:** Fetch initial state from `pixels` table on load.
- [ ] **Live Updates:** Subscribe to `postgres_changes` on the `pixels` table to update colors without refreshing.
- [ ] **Optimistic UI:** Update the DOM immediately on click, revert if the server request fails.

### ⚡ Mid-Level Challenges (The Fun Stuff)
- [ ] **Ghost Cursors (Presence):**
    - Use Supabase `channel.track()` to broadcast mouse coordinates.
    - Render floating borders/names where other users are hovering.
- [ ] **Cooldown Timer (RLS & Logic):**
    - Users can only paint 1 pixel every 5 seconds.
    - **Implementation:** Store `last_painted_at` in a `profiles` table. Use a Postgres Trigger or RLS policy to reject updates if `now() - last_painted_at < 5 seconds`.
- [ ] **"Heatmap" Mode:**
    - Track how many times each pixel has been changed.
    - Add a toggle to visualize "hot" zones (high contention areas) using a color gradient overlay.

### 🧠 "Big Brain" Extensions (If you get bored)
- [ ] **Time Travel:** A slider to replay the history of the canvas (requires a `pixel_history` log table).
- [ ] **Teams/Factions:** Users join a "Team Red" or "Team Blue". Tally scores based on total pixels occupied.

---

## 🔐 Project 2: "007-Drop" (Ephemeral Encrypted File Sharing)
**Concept:** A secure file transfer tool (like Firefox Send). Upload a file, get a link, and the file self-destructs after 1 download or 24 hours.

### 🛠 Tech Stack
- **Frontend:** Nuxt 3 (VueUse for clipboard/UI).
- **Backend:** Supabase Storage + Database + Postgres Cron (or Edge Functions).

### ✅ MVP Features
- [ ] **File Upload:** Direct upload to Supabase Storage buckets.
- [ ] **Link Generation:** Generate a signed URL or a unique UUID route (e.g., `/d/xyz-123`).
- [ ] **Download Limit:** Track download count in a `files` table.

### ⚡ Mid-Level Challenges
- [ ] **Auto-Deletion (The tricky part):**
    - **Method A (Lazy):** Check expiry on *read*. If expired, return 404 and delete in background.
    - **Method B (Pro):** Use `pg_cron` (available in Supabase) to run a SQL cleanup script every hour: `DELETE FROM storage.objects WHERE created_at < now() - interval '24 hours'`.
- [ ] **Row Level Security (RLS):**
    - Ensure only the *uploader* can see the file metadata initially.
    - Ensure the *downloader* can only access it if they have the correct UUID token (Row Level Security using a function to check the token).
- [ ] **Client-Side Encryption:**
    - Encrypt the file in the browser (Web Crypto API) *before* it hits Supabase. The server never sees the contents, only the blob.

---

## 🤖 Project 3: "Prompt Arena" (AI Output Elo Rater)
**Concept:** Given your AI background, this is relevant. A tool where you display two AI-generated images/texts side-by-side, and the user votes for the better one. It calculates an Elo rating.

### 🛠 Tech Stack
- **Frontend:** Nuxt 3.
- **Backend:** Supabase (Database, RPC functions for math).

### ✅ MVP Features
- [ ] **Pairing Logic:** Fetch two random items from a `generations` table.
- [ ] **Voting UI:** "Left is better" vs "Right is better".
- [ ] **Leaderboard:** Display top-rated generations.

### ⚡ Mid-Level Challenges
- [ ] **The Elo Algorithm (Postgres Function):**
    - Don't calculate Elo in Javascript. Write a PL/pgSQL function `update_elo(winner_id, loser_id)` that runs entirely inside the database when a vote is cast.
    - *Why?* Prevents race conditions and is much faster.
- [ ] **Anti-Cheat:**
    - Use RLS and IP tracking (or anonymous auth) to prevent one user from voting on the same pair 50 times.
- [ ] **Smart Matchmaking:**
    - Instead of random pairs, write a SQL query to fetch pairs with *similar* Elo ratings (to make the choice harder and the data more valuable).

---

## 📦 Quick Setup Commands

### 1. Install Nuxt with Supabase
```bash
npx nuxi@latest init pixel-party
cd pixel-party
npx nuxi@latest module add supabase
npm install