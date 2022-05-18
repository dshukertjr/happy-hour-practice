# Happy Chat Rehersal

```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade on update cascade,
  username text not null
);

create table rooms (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamptz not null default now(),
  name text
);

alter table rooms enable row level security;


create type room_participant_role as enum ('ADMIN', 'PARTICIPANT');

create table room_participants (
  room_id uuid not null references rooms(id) on delete cascade on update cascade,
  profile_id uuid not null references profiles(id) on delete cascade on update cascade,
  created_at timestamptz not null default now(),
  role room_participant_role not null default 'PARTICIPANT',
  primary key (room_id, profile_id)
);

create or replace function is_room_participant(room_id uuid, profile_id uuid)
returns boolean as $$
  select exists(
    select 1
    from room_participants
    where room_id = is_room_participant.room_id and profile_id = is_room_participant.profile_id
  );
$$ language sql security definer;

create or replace function room_role(room_id uuid, profile_id uuid)
returns room_participant_role as $$
  select role
  from room_participants
  where room_id = room_role.room_id and profile_id = room_role.profile_id
$$ language sql security definer;

create or replace function create_room(name text default null)
returns uuid as $$
    declare
        new_room_id uuid;
    begin
        -- Create a new room
        insert into public.rooms (name) values(name)
        returning id into new_room_id;

        -- Insert the caller user into the new room
        insert into public.room_participants (profile_id, room_id)
        values (auth.uid(), new_room_id);

        return new_room_id;
    end
$$ language plpgsql security definer;

alter table room_participants enable row level security;


create table messages (
  id uuid primary key default uuid_generate_v4(),
  created_at timestamptz not null default now(),
  profile_id uuid not null references profiles(id) on delete cascade on update cascade default auth.uid(),
  room_id uuid not null references rooms(id) on delete cascade on update cascade,
  message text not null
);

alter table messages enable row level security;

-- RLS

create policy "can view rooms participating in" on rooms
for select using (
  is_room_participant(id, auth.uid())
);

create policy "admins can update rooms" on rooms
for update using (
  room_role(id, auth.uid()) = 'ADMIN'
);

-- maybe we shouldn't allow this and admins can only leave rooms
create policy "admins can delete rooms" on rooms
for delete using (
  room_role(id, auth.uid()) = 'ADMIN'
);

create policy "can view room participants" on room_participants
for select using (
  is_room_participant(room_id, auth.uid())
);

create policy "can remove self from room" on room_participants
for delete using (
  profile_id = auth.uid()
);

create policy "admins can remove others from room" on room_participants
for delete using (
  room_role(room_id, profile_id) = 'ADMIN'
);

create policy "can view room messages" on messages
for select using (
  is_room_participant(room_id, auth.uid())
);

create policy "can create room messages" on messages
for insert with check (
  is_room_participant(room_id, auth.uid())
);

create policy "can delete own messages" on messages
for delete using (
  profile_id = auth.uid()
);
```