-- Supabase Schema for AuraLuxe Single Vendor Ecommerce System

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Profiles Table (linked to auth.users)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  role text not null default 'customer' check (role in ('super_admin', 'admin', 'staff', 'customer')),
  is_blocked boolean default false not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on Profiles
alter table public.profiles enable row level security;

-- 2. Categories Table
create table if not exists public.categories (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.categories enable row level security;

-- 3. Products Table
create table if not exists public.products (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  price numeric not null check (price >= 0),
  discount_price numeric check (discount_price >= 0),
  category_id uuid references public.categories on delete set null,
  stock integer not null default 0 check (stock >= 0),
  image_urls text[] not null default '{}',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.products enable row level security;

-- 4. Orders Table (user_id is nullable for guest checkout support)
create table if not exists public.orders (
  id bigserial primary key,
  user_id uuid references public.profiles on delete set null,
  customer_name text not null,
  customer_phone text not null,
  customer_email text,
  shipping_address text not null,
  payment_method text not null default 'COD',
  status text not null default 'pending' check (status in ('pending', 'confirmed', 'processing', 'packed', 'shipped', 'delivered', 'cancelled')),
  total_amount numeric not null check (total_amount >= 0),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.orders enable row level security;

-- 5. Order Items Table
create table if not exists public.order_items (
  id uuid default gen_random_uuid() primary key,
  order_id bigint references public.orders on delete cascade not null,
  product_id uuid references public.products on delete set null,
  product_title text not null, -- denormalized to preserve historical product name at purchase
  quantity integer not null check (quantity > 0),
  unit_price numeric not null check (unit_price >= 0),
  total_price numeric not null check (total_price >= 0)
);

alter table public.order_items enable row level security;

-- 6. Activity Logs Table
create table if not exists public.activity_logs (
  id uuid default gen_random_uuid() primary key,
  performer_id uuid references public.profiles on delete set null,
  performer_email text not null,
  performer_role text not null,
  action text not null,
  entity_type text not null, -- 'product', 'order', 'category', 'user'
  entity_id text not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.activity_logs enable row level security;

-- 7. Notifications Table
create table if not exists public.notifications (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  message text not null,
  is_read boolean default false not null,
  user_id uuid references public.profiles on delete cascade,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.notifications enable row level security;

-- =========================================================================
-- Row Level Security (RLS) Policies
-- =========================================================================

-- Profiles Policies
create policy "Allow public read on profiles" on public.profiles
  for select using (true);

create policy "Allow users to update own profile" on public.profiles
  for update using (auth.uid() = id);

create policy "Allow insert on profiles" on public.profiles
  for insert with check (true);

-- Categories Policies
create policy "Allow public read on categories" on public.categories
  for select using (true);

create policy "Allow admins to modify categories" on public.categories
  for all using (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role in ('super_admin', 'admin')
    )
  );

-- Products Policies
create policy "Allow public read on products" on public.products
  for select using (true);

create policy "Allow admins to modify products" on public.products
  for all using (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role in ('super_admin', 'admin')
    )
  );

-- Orders Policies
create policy "Allow anyone to insert orders" on public.orders
  for insert with check (true);

create policy "Allow user/admin/staff to view orders" on public.orders
  for select using (
    (user_id is not null and auth.uid() = user_id) or 
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role in ('super_admin', 'admin', 'staff')
    )
  );

create policy "Allow admins and staff to update orders" on public.orders
  for update using (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role in ('super_admin', 'admin', 'staff')
    )
  );

-- Order Items Policies
create policy "Allow anyone to insert order items" on public.order_items
  for insert with check (true);

create policy "Allow reading order items" on public.order_items
  for select using (
    exists (
      select 1 from public.orders 
      where id = order_id and 
      ((user_id is not null and auth.uid() = user_id) or 
       exists (select 1 from public.profiles where id = auth.uid() and role in ('super_admin', 'admin', 'staff')))
    )
  );

-- Activity Logs Policies
create policy "Allow super admin to view logs" on public.activity_logs
  for select using (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role = 'super_admin'
    )
  );

create policy "Allow admins and staff to insert logs" on public.activity_logs
  for insert with check (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role in ('super_admin', 'admin', 'staff')
    )
  );

-- Notifications Policies
create policy "Allow users to view own notifications" on public.notifications
  for select using (
    user_id is null or auth.uid() = user_id or
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('super_admin', 'admin')
    )
  );

create policy "Allow admins to create notifications" on public.notifications
  for insert with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('super_admin', 'admin')
    )
  );

-- =========================================================================
-- Trigger for automatic profile creation on user signup
-- =========================================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, role, is_blocked)
  values (new.id, new.email, 'customer', false);
  return new;
end;
$$ language plpgsql security definer;

-- Drop trigger if exists
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
