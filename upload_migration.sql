-- 1. Add user_id to generations table
alter table generations 
add column user_id uuid references auth.users(id);

-- 2. Create Storage Bucket for 'generations'
insert into storage.buckets (id, name, public)
values ('generations', 'generations', true);

-- 3. Set up Storage Policies using helper function (if you have one) OR raw RLS
create policy "Public Access"
on storage.objects for select
using ( bucket_id = 'generations' );

create policy "Authenticated Upload"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'generations' );

create policy "Owner Delete"
on storage.objects for delete
to authenticated
using ( bucket_id = 'generations' and auth.uid() = owner );

-- 4. Update Generations RLS
-- Allow public read (already done)
-- Allow authenticated insert
create policy "Authenticated users can insert generations"
on generations for insert
to authenticated
with check ( auth.uid() = user_id );

-- 5. Track uploads in Profile
-- (Optional) We can query this dynamically using count(*), no need for a separate counter column yet.
