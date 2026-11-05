-- Supabase > SQL Editor mein ye poora paste karke Run karo.

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  email text,
  balance numeric(18,8) not null default 0
);

create function handle_new_user() returns trigger language plpgsql security definer as $$
begin
  insert into profiles(id,email) values (new.id,new.email);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

create table admins (user_id uuid primary key references auth.users);

create function is_admin() returns boolean language sql security definer stable as $$
  select exists(select 1 from admins where user_id = auth.uid())
$$;

create table country_fees (country text primary key, btc numeric(18,8) not null);
insert into country_fees values ('default',0.001),('India',0.001);

create table applications (
  id bigserial primary key,
  user_id uuid not null references auth.users,
  data jsonb not null,
  photos text[] default '{}',
  fee numeric(18,8) not null,
  status text not null default 'pending' check (status in ('pending','progress','done','cancel')),
  created_at timestamptz default now()
);

alter table profiles enable row level security;
alter table admins enable row level security;
alter table country_fees enable row level security;
alter table applications enable row level security;

create policy "own or admin profile" on profiles for select using (id = auth.uid() or is_admin());
create policy "fees readable" on country_fees for select to authenticated using (true);
create policy "admin manages fees" on country_fees for all using (is_admin()) with check (is_admin());
create policy "own or admin apps" on applications for select using (user_id = auth.uid() or is_admin());
create policy "admin updates apps" on applications for update using (is_admin()) with check (is_admin());
-- users apni application direct insert/update nahi kar sakte; sirf neeche wale function se.

create function submit_application(p_data jsonb, p_photos text[]) returns bigint
language plpgsql security definer as $$
declare v_fee numeric; v_bal numeric; v_id bigint;
begin
  if auth.uid() is null then raise exception 'login required'; end if;
  select btc into v_fee from country_fees where country = p_data->>'country';
  if v_fee is null then select btc into v_fee from country_fees where country='default'; end if;
  select balance into v_bal from profiles where id = auth.uid() for update;
  if v_bal < v_fee then raise exception 'balance kam hai'; end if;
  update profiles set balance = balance - v_fee where id = auth.uid();
  insert into applications(user_id,data,photos,fee) values (auth.uid(),p_data,p_photos,v_fee) returning id into v_id;
  return v_id;
end $$;

create function admin_credit(p_email text, p_amount numeric) returns void
language plpgsql security definer as $$
begin
  if not is_admin() then raise exception 'not allowed'; end if;
  update profiles set balance = balance + p_amount where email = p_email;
end $$;

-- Private photo/document storage
insert into storage.buckets (id,name,public) values ('docs','docs',false);
create policy "upload own folder" on storage.objects for insert to authenticated
  with check (bucket_id='docs' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "read own or admin" on storage.objects for select to authenticated
  using (bucket_id='docs' and ((storage.foldername(name))[1] = auth.uid()::text or is_admin()));

-- ADMIN BANANA: pehle Authentication > Users mein apna email + strong password se user banao,
-- phir uska UUID copy karke ye chalao:
-- insert into admins values ('YAHAN_ADMIN_USER_UUID');
