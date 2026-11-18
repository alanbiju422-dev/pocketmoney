-- Store transactions in integer paise and bind every row to its Supabase Auth user.
create table public.transactions (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('income', 'expense')),
  amount_paise bigint not null check (amount_paise > 0),
  category text,
  description text,
  date_time timestamptz not null,
  created_at timestamptz not null default now(),
  constraint transactions_valid_category check (
    category is null or category in ('travel', 'food', 'college', 'other')
  ),
  constraint transactions_type_category check (
    (type = 'income' and category is null and description is null)
    or (type = 'expense' and category is not null)
  ),
  constraint transactions_other_requires_description check (
    category <> 'other' or nullif(btrim(description), '') is not null
  )
);

create index transactions_user_date_idx
  on public.transactions (user_id, date_time desc);

alter table public.transactions enable row level security;
alter table public.transactions force row level security;

revoke all on table public.transactions from anon, public;
grant select, insert, delete on table public.transactions to authenticated;

create policy "Users can read their own transactions"
  on public.transactions for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can insert their own transactions"
  on public.transactions for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own transactions"
  on public.transactions for delete to authenticated
  using ((select auth.uid()) = user_id);

comment on table public.transactions is
  'PocketMoney transactions. Access is restricted to the authenticated owner by RLS.';

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'transactions'
  ) then
    alter publication supabase_realtime add table public.transactions;
  end if;
end;
$$;
