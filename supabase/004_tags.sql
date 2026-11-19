-- Миграция 004: теги салатов («майонезный», «овощной»)
-- Выполнить один раз в Supabase: SQL Editor → New query → вставить → Run

alter table public.salads add column if not exists tags text[] not null default '{}';
