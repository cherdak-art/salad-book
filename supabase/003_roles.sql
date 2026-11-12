-- Миграция 003: роли «администратор», «управляющий», «повар», «пользователь»;
-- удалять салаты могут все, кроме «пользователя»; новые аккаунты — «пользователь»
-- Выполнить один раз в Supabase: SQL Editor → New query → вставить → Run

-- допустимые роли: admin (администратор), manager (управляющий), cook (повар), user (пользователь)
alter table public.profiles drop constraint if exists profiles_role_check;
alter table public.profiles add constraint profiles_role_check
  check (role in ('admin', 'manager', 'cook', 'user'));

-- новые аккаунты получают роль «пользователь»
alter table public.profiles alter column role set default 'user';

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'user');
  return new;
end;
$$;

-- кто может удалять салаты
create or replace function public.can_delete()
returns boolean
language sql
stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('admin', 'manager', 'cook')
  );
$$;

drop policy if exists "salads: удаление только админ" on public.salads;
drop policy if exists "salads: удаление" on public.salads;
create policy "salads: удаление"
  on public.salads for delete to authenticated using (public.can_delete());

-- Назначить роль (подставьте email):
-- update public.profiles set role = 'admin'   where email = 'admin@example.com';
-- update public.profiles set role = 'manager' where email = 'manager@example.com';
-- update public.profiles set role = 'cook'    where email = 'cook@example.com';
-- update public.profiles set role = 'user'    where email = 'user@example.com';
