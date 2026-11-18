-- Correct the "other" expense description check without changing transaction rows.
alter table public.transactions
  drop constraint if exists transactions_other_requires_description;

alter table public.transactions
  add constraint transactions_other_requires_description
  check (
    category is distinct from 'other'
    or nullif(btrim(description), '') is not null
  );
