-- Check if any generations exist
select * from generations;

-- Check RLS policies just in case
select * from pg_policies where tablename = 'generations';
