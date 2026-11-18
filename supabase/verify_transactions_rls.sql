-- Run after 20261118000100_create_user_transactions.sql in the Supabase SQL Editor.

select
  c.relrowsecurity as rls_enabled,
  c.relforcerowsecurity as rls_forced
from pg_class c
where c.oid = 'public.transactions'::regclass;

select policyname, cmd, roles, qual, with_check
from pg_policies
where schemaname = 'public'
  and tablename = 'transactions'
order by policyname;

select
  has_table_privilege('anon', 'public.transactions', 'SELECT') as anon_can_select,
  has_table_privilege('authenticated', 'public.transactions', 'SELECT') as authenticated_can_select,
  has_table_privilege('authenticated', 'public.transactions', 'INSERT') as authenticated_can_insert,
  has_table_privilege('authenticated', 'public.transactions', 'UPDATE') as authenticated_can_update,
  has_table_privilege('authenticated', 'public.transactions', 'DELETE') as authenticated_can_delete;

select exists (
  select 1
  from pg_publication_tables
  where pubname = 'supabase_realtime'
    and schemaname = 'public'
    and tablename = 'transactions'
) as transactions_in_realtime_publication;
