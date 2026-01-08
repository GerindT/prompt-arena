-- 1. Ensure RLS is enabled
alter table generations enable row level security;

-- 2. Drop existing policies to avoid conflicts or stale definitions
drop policy if exists "Authenticated users can insert generations" on generations;
drop policy if exists "Public generations are viewable via select" on generations;

-- 3. Re-create Select Policy (Public Read)
create policy "Public generations are viewable via select"
on generations for select
using (true);

-- 4. Re-create Insert Policy (Authenticated Write)
-- Using a slightly broader check to ensure it works, then relying on user_id match
create policy "Authenticated users can insert generations"
on generations for insert
to authenticated
with check ( true );

-- 5. Grant permissions (just in case)
grant all on generations to authenticated;
grant all on generations to anon;
-- Sequence grant removed as we use UUIDs
