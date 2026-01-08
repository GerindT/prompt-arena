-- Enable the UUID extension if not already enabled
create extension if not exists "uuid-ossp";

-- 1. Create 'generations' table
create table generations (
  id uuid default gen_random_uuid() primary key,
  content text not null, -- URL to image or text content
  type text check (type in ('image', 'text')) not null,
  elo_rating int default 1200,
  created_at timestamptz default now()
);

-- 2. Create 'votes' table
create table votes (
  id uuid default gen_random_uuid() primary key,
  match_id uuid default gen_random_uuid(), -- Optional: to group pairs if needed in future
  winner_id uuid references generations(id) not null,
  loser_id uuid references generations(id) not null,
  created_at timestamptz default now()
);

-- 3. Create 'update_elo' RPC function
-- This function atomicaly updates the Elo rating for two items.
create or replace function update_elo(winner_id uuid, loser_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  k_factor constant int := 32;
  winner_rating int;
  loser_rating int;
  expected_winner float;
  expected_loser float;
  new_winner_rating int;
  new_loser_rating int;
begin
  -- Get current ratings
  select elo_rating into winner_rating from generations where id = update_elo.winner_id;
  select elo_rating into loser_rating from generations where id = update_elo.loser_id;

  -- Calculate expected scores
  -- E = 1 / (1 + 10 ^ ((Rb - Ra) / 400))
  expected_winner := 1.0 / (1.0 + power(10.0, (loser_rating - winner_rating)::float / 400.0));
  expected_loser := 1.0 / (1.0 + power(10.0, (winner_rating - loser_rating)::float / 400.0));

  -- Calculate new ratings
  new_winner_rating := round(winner_rating + k_factor * (1 - expected_winner));
  new_loser_rating := round(loser_rating + k_factor * (0 - expected_loser));

  -- Update ratings
  update generations set elo_rating = new_winner_rating where id = update_elo.winner_id;
  update generations set elo_rating = new_loser_rating where id = update_elo.loser_id;

  -- Record the vote
  insert into votes (winner_id, loser_id) values (update_elo.winner_id, update_elo.loser_id);
end;
$$;

-- 4. Enable Row Level Security (RLS)
alter table generations enable row level security;
alter table votes enable row level security;

-- Create policies (modify as needed for production)
-- Allow public read access to generations
create policy "Public generations are viewable via select"
  on generations for select
  using (true);

-- Allow anon users to call the update_elo function (via RPC) is handled by GRANT EXECUTE usually,
-- but the function is SECURITY DEFINER so it runs with creator privileges.
-- However, we might want to restrict who can execute it or rate-limit it in the app logic.

-- Grant access to public (anon) and authenticated users
grant usage on schema public to anon, authenticated;
grant all on all tables in schema public to anon, authenticated;
grant all on all sequences in schema public to anon, authenticated;
grant all on all routines in schema public to anon, authenticated;

-- 5. Seed Dummy Data (Images)
insert into generations (content, type) values
('https://picsum.photos/seed/1/400/400', 'image'),
('https://picsum.photos/seed/2/400/400', 'image'),
('https://picsum.photos/seed/3/400/400', 'image'),
('https://picsum.photos/seed/4/400/400', 'image'),
('https://picsum.photos/seed/5/400/400', 'image'),
('https://picsum.photos/seed/6/400/400', 'image'),
('https://picsum.photos/seed/7/400/400', 'image'),
('https://picsum.photos/seed/8/400/400', 'image');
