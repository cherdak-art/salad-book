-- Схема базы «Ладушки салаты» для Supabase.
-- Выполните целиком в Supabase: SQL Editor → New query → Run.

-- ---------- Роли пользователей ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  role text not null default 'cook' check (role in ('admin', 'cook')),
  created_at timestamptz not null default now()
);

-- Автоматически создаём профиль при регистрации нового пользователя
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'cook');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Проверка: является ли текущий пользователь администратором
create or replace function public.is_admin()
returns boolean
language sql
stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

-- ---------- Салаты ----------
create table if not exists public.salads (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  final_weight numeric check (final_weight is null or final_weight > 0),
  created_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

-- ---------- Продукты (состав) ----------
create table if not exists public.ingredients (
  id uuid primary key default gen_random_uuid(),
  salad_id uuid not null references public.salads(id) on delete cascade,
  name text not null,
  grams numeric not null check (grams > 0),
  position int not null default 0
);

create index if not exists ingredients_salad_idx on public.ingredients(salad_id);

-- ---------- Права доступа (Row Level Security) ----------
alter table public.profiles    enable row level security;
alter table public.salads      enable row level security;
alter table public.ingredients enable row level security;

-- Профили: каждый видит только себя, админ видит всех
create policy "profiles: видит себя или админ"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_admin());

-- Салаты и продукты: все авторизованные пользователи читают и редактируют
create policy "salads: чтение"
  on public.salads for select to authenticated using (true);
create policy "salads: добавление"
  on public.salads for insert to authenticated with check (true);
create policy "salads: изменение"
  on public.salads for update to authenticated using (true) with check (true);
create policy "salads: удаление только админ"
  on public.salads for delete to authenticated using (public.is_admin());

create policy "ingredients: чтение"
  on public.ingredients for select to authenticated using (true);
create policy "ingredients: добавление"
  on public.ingredients for insert to authenticated with check (true);
create policy "ingredients: изменение"
  on public.ingredients for update to authenticated using (true) with check (true);
create policy "ingredients: удаление"
  on public.ingredients for delete to authenticated using (true);

-- Анонимные (не вошедшие) пользователи не имеют доступа вообще — политики выше только для authenticated.

-- ---------- После регистрации первого пользователя ----------
-- Назначьте себе роль администратора (подставьте свой email):
-- update public.profiles set role = 'admin' where email = 'ваш@email';
