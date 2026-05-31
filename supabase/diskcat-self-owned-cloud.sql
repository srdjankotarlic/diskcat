-- DiskCat self-owned cloud schema for Supabase.
-- Run this in the Supabase SQL Editor inside the project that will own the data.
-- The public app never ships with a default Supabase project or private key.

create extension if not exists pgcrypto;

create table if not exists public.archives (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'My DiskCat Archive',
  public_read_enabled boolean not null default false,
  public_read_token text unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.archive_members (
  archive_id uuid not null references public.archives(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor', 'viewer')),
  created_at timestamptz not null default now(),
  primary key (archive_id, user_id)
);

create table if not exists public.archive_invites (
  id uuid primary key default gen_random_uuid(),
  archive_id uuid not null references public.archives(id) on delete cascade,
  role text not null check (role in ('editor', 'viewer')),
  code text not null unique default encode(gen_random_bytes(18), 'hex'),
  created_by uuid not null references auth.users(id) on delete cascade,
  used_by uuid references auth.users(id) on delete set null,
  expires_at timestamptz not null default (now() + interval '14 days'),
  created_at timestamptz not null default now()
);

create table if not exists public.drives (
  archive_id uuid not null references public.archives(id) on delete cascade,
  id text not null,
  label text not null default '',
  name text not null default '',
  kind text not null default 'hdd',
  status text not null default 'active',
  capacity numeric,
  used numeric,
  cap_unit text not null default 'TB',
  note text not null default '',
  created_at bigint,
  updated_at timestamptz not null default now(),
  primary key (archive_id, id)
);

create table if not exists public.events (
  archive_id uuid not null references public.archives(id) on delete cascade,
  id text not null,
  name text not null,
  event_date date,
  date_display text,
  approx boolean not null default false,
  drive_ids text[] not null default '{}',
  client text not null default '',
  tags text[] not null default '{}',
  stage text not null default '',
  location text not null default '',
  note text not null default '',
  created_at bigint,
  updated_at timestamptz not null default now(),
  primary key (archive_id, id)
);

create index if not exists archive_members_user_idx on public.archive_members (user_id, archive_id);
create index if not exists archive_invites_code_idx on public.archive_invites (code);
create index if not exists drives_archive_updated_idx on public.drives (archive_id, updated_at desc);
create index if not exists events_archive_updated_idx on public.events (archive_id, updated_at desc);
create index if not exists events_archive_date_idx on public.events (archive_id, event_date desc);

create or replace function public.diskcat_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists archives_touch_updated_at on public.archives;
create trigger archives_touch_updated_at
before update on public.archives
for each row execute function public.diskcat_touch_updated_at();

drop trigger if exists drives_touch_updated_at on public.drives;
create trigger drives_touch_updated_at
before update on public.drives
for each row execute function public.diskcat_touch_updated_at();

drop trigger if exists events_touch_updated_at on public.events;
create trigger events_touch_updated_at
before update on public.events
for each row execute function public.diskcat_touch_updated_at();

create or replace function public.diskcat_member_role(p_archive_id uuid)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select m.role
  from public.archive_members m
  where m.archive_id = p_archive_id
    and m.user_id = (select auth.uid())
  limit 1
$$;

create or replace function public.diskcat_can_read_archive(p_archive_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.archives a
    where a.id = p_archive_id
      and (
        a.owner_id = (select auth.uid())
        or public.diskcat_member_role(p_archive_id) in ('owner', 'editor', 'viewer')
      )
  )
$$;

create or replace function public.diskcat_can_write_archive(p_archive_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.archives a
    where a.id = p_archive_id
      and (
        a.owner_id = (select auth.uid())
        or public.diskcat_member_role(p_archive_id) in ('owner', 'editor')
      )
  )
$$;

create or replace function public.diskcat_is_owner(p_archive_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.archives a
    where a.id = p_archive_id
      and (
        a.owner_id = (select auth.uid())
        or public.diskcat_member_role(p_archive_id) = 'owner'
      )
  )
$$;

create or replace function public.diskcat_add_owner_member()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.archive_members (archive_id, user_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict (archive_id, user_id) do update set role = 'owner';
  return new;
end;
$$;

drop trigger if exists archives_add_owner_member on public.archives;
create trigger archives_add_owner_member
after insert on public.archives
for each row execute function public.diskcat_add_owner_member();

create or replace function public.diskcat_create_invite(p_archive_id uuid, p_role text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite public.archive_invites;
begin
  if (select auth.uid()) is null then
    raise exception 'Sign in first';
  end if;

  if p_role not in ('editor', 'viewer') then
    raise exception 'Role must be editor or viewer';
  end if;

  if not public.diskcat_is_owner(p_archive_id) then
    raise exception 'Only archive owners can create invites';
  end if;

  insert into public.archive_invites (archive_id, role, created_by)
  values (p_archive_id, p_role, (select auth.uid()))
  returning * into v_invite;

  return jsonb_build_object(
    'archive_id', v_invite.archive_id,
    'code', v_invite.code,
    'role', v_invite.role,
    'expires_at', v_invite.expires_at
  );
end;
$$;

create or replace function public.diskcat_redeem_invite(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite public.archive_invites;
begin
  if (select auth.uid()) is null then
    raise exception 'Sign in first';
  end if;

  select *
  into v_invite
  from public.archive_invites
  where code = p_code
    and used_by is null
    and expires_at > now()
  limit 1;

  if not found then
    raise exception 'Invite is invalid or expired';
  end if;

  insert into public.archive_members (archive_id, user_id, role)
  values (v_invite.archive_id, (select auth.uid()), v_invite.role)
  on conflict (archive_id, user_id) do update
    set role = case
      when public.archive_members.role = 'owner' then 'owner'
      else excluded.role
    end;

  update public.archive_invites
  set used_by = (select auth.uid())
  where id = v_invite.id;

  return jsonb_build_object(
    'archive_id', v_invite.archive_id,
    'role', v_invite.role
  );
end;
$$;

create or replace function public.diskcat_public_read_archive(p_token text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'archive', jsonb_build_object(
      'id', a.id,
      'name', a.name,
      'public_read_enabled', a.public_read_enabled
    ),
    'drives', coalesce((
      select jsonb_agg(to_jsonb(d) - 'archive_id' - 'updated_at' order by d.label, d.name)
      from public.drives d
      where d.archive_id = a.id
    ), '[]'::jsonb),
    'events', coalesce((
      select jsonb_agg(to_jsonb(e) - 'archive_id' - 'updated_at' order by e.event_date desc nulls last, e.name)
      from public.events e
      where e.archive_id = a.id
    ), '[]'::jsonb)
  )
  from public.archives a
  where a.public_read_enabled = true
    and a.public_read_token = p_token
  limit 1
$$;

alter table public.archives enable row level security;
alter table public.archive_members enable row level security;
alter table public.archive_invites enable row level security;
alter table public.drives enable row level security;
alter table public.events enable row level security;

drop policy if exists "archives_select_members" on public.archives;
create policy "archives_select_members"
on public.archives for select
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_read_archive(id)
);

drop policy if exists "archives_insert_owner" on public.archives;
create policy "archives_insert_owner"
on public.archives for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and owner_id = (select auth.uid())
);

drop policy if exists "archives_update_owner" on public.archives;
create policy "archives_update_owner"
on public.archives for update
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(id)
)
with check (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(id)
);

drop policy if exists "archives_delete_owner" on public.archives;
create policy "archives_delete_owner"
on public.archives for delete
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(id)
);

drop policy if exists "members_select_archive_members" on public.archive_members;
create policy "members_select_archive_members"
on public.archive_members for select
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_read_archive(archive_id)
);

drop policy if exists "members_insert_owner" on public.archive_members;
create policy "members_insert_owner"
on public.archive_members for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(archive_id)
);

drop policy if exists "members_update_owner" on public.archive_members;
create policy "members_update_owner"
on public.archive_members for update
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(archive_id)
)
with check (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(archive_id)
);

drop policy if exists "members_delete_owner" on public.archive_members;
create policy "members_delete_owner"
on public.archive_members for delete
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(archive_id)
);

drop policy if exists "invites_select_owner" on public.archive_invites;
create policy "invites_select_owner"
on public.archive_invites for select
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(archive_id)
);

drop policy if exists "invites_delete_owner" on public.archive_invites;
create policy "invites_delete_owner"
on public.archive_invites for delete
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_is_owner(archive_id)
);

drop policy if exists "drives_select_members" on public.drives;
create policy "drives_select_members"
on public.drives for select
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_read_archive(archive_id)
);

drop policy if exists "drives_insert_writers" on public.drives;
create policy "drives_insert_writers"
on public.drives for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
);

drop policy if exists "drives_update_writers" on public.drives;
create policy "drives_update_writers"
on public.drives for update
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
)
with check (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
);

drop policy if exists "drives_delete_writers" on public.drives;
create policy "drives_delete_writers"
on public.drives for delete
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
);

drop policy if exists "events_select_members" on public.events;
create policy "events_select_members"
on public.events for select
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_read_archive(archive_id)
);

drop policy if exists "events_insert_writers" on public.events;
create policy "events_insert_writers"
on public.events for insert
to authenticated
with check (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
);

drop policy if exists "events_update_writers" on public.events;
create policy "events_update_writers"
on public.events for update
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
)
with check (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
);

drop policy if exists "events_delete_writers" on public.events;
create policy "events_delete_writers"
on public.events for delete
to authenticated
using (
  (select auth.uid()) is not null
  and public.diskcat_can_write_archive(archive_id)
);

revoke all on public.archives from anon;
revoke all on public.archive_members from anon;
revoke all on public.archive_invites from anon;
revoke all on public.drives from anon;
revoke all on public.events from anon;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.archives to authenticated;
grant select, insert, update, delete on public.archive_members to authenticated;
grant select, delete on public.archive_invites to authenticated;
grant select, insert, update, delete on public.drives to authenticated;
grant select, insert, update, delete on public.events to authenticated;

revoke all on function public.diskcat_member_role(uuid) from public;
revoke all on function public.diskcat_can_read_archive(uuid) from public;
revoke all on function public.diskcat_can_write_archive(uuid) from public;
revoke all on function public.diskcat_is_owner(uuid) from public;
revoke all on function public.diskcat_public_read_archive(text) from public;
revoke all on function public.diskcat_create_invite(uuid, text) from public;
revoke all on function public.diskcat_redeem_invite(text) from public;

grant execute on function public.diskcat_member_role(uuid) to authenticated;
grant execute on function public.diskcat_can_read_archive(uuid) to authenticated;
grant execute on function public.diskcat_can_write_archive(uuid) to authenticated;
grant execute on function public.diskcat_is_owner(uuid) to authenticated;
grant execute on function public.diskcat_public_read_archive(text) to anon, authenticated;
grant execute on function public.diskcat_create_invite(uuid, text) to authenticated;
grant execute on function public.diskcat_redeem_invite(text) to authenticated;
