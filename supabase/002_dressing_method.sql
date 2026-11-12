-- Миграция 002: заправка, способ приготовления и продукты без граммовки («на глаз»)
-- Выполнить один раз в Supabase: SQL Editor → New query → вставить → Run

alter table public.salads add column if not exists dressing text;
alter table public.salads add column if not exists method text;

-- граммы становятся необязательными: пусто = «на глаз»
alter table public.ingredients alter column grams drop not null;
alter table public.ingredients drop constraint if exists ingredients_grams_check;
alter table public.ingredients add constraint ingredients_grams_check check (grams is null or grams > 0);
