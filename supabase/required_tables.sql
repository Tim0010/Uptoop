-- Supabase required tables and policies for Uptop Careers
-- Run this in Supabase SQL editor (or as a migration)

-- Extensions
create extension if not exists pgcrypto;

-- Helper: auto-update updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- USERS
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  phone_number text unique,
  auth_provider text not null default 'phone',
  full_name text not null,
  email text,
  age text,
  college text,
  avatar_url text,
  bio text,
  interests text[] default '{}',
  referral_code text not null unique,
  referred_by_code text,
  referred_by_user_id uuid references public.users(id) on delete set null,
  level int not null default 1,
  coins int not null default 0,
  total_earnings numeric(12,2) not null default 0,
  pending_earnings numeric(12,2) not null default 0,
  monthly_earnings numeric(12,2) not null default 0,
  total_referrals int not null default 0,
  active_referrals int not null default 0,
  successful_referrals int not null default 0,
  current_streak int not null default 0,
  longest_streak int not null default 0,
  is_active boolean not null default true,
  is_verified boolean not null default false,
  is_email_verified boolean not null default false,
  is_phone_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_login_at timestamptz
);

create index if not exists idx_users_phone on public.users (phone_number);
create index if not exists idx_users_referral_code on public.users (referral_code);

-- Recreate trigger idempotently (CREATE TRIGGER has no OR REPLACE)
drop trigger if exists trg_users_updated_at on public.users;
create trigger trg_users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

alter table public.users enable row level security;

-- Only the owner can view/modify own row (CREATE POLICY has no IF NOT EXISTS)
drop policy if exists "Users select own" on public.users;
create policy "Users select own" on public.users
  for select using ( auth.uid() = id );

-- Allow users to search by phone number (for sign-in flow)
drop policy if exists "Users select by phone" on public.users;
create policy "Users select by phone" on public.users
  for select using ( true );

drop policy if exists "Users insert own" on public.users;
create policy "Users insert own" on public.users
  for insert with check ( auth.uid() = id );
drop policy if exists "Users update own" on public.users;
create policy "Users update own" on public.users
  for update using ( auth.uid() = id );

-- REFERRALS
create table if not exists public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references public.users(id) on delete cascade,
  referred_name text not null,
  referred_email text,
  referred_phone text,
  referred_college text,
  status text not null default 'pending',
  application_stage text not null default 'not_started',
  is_completed boolean not null default false,
  program_id text,
  program_name text,
  university_name text,
  reward_amount numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  enrolled_at timestamptz,
  completed_at timestamptz
);

create index if not exists idx_referrals_referrer on public.referrals (referrer_id);
create index if not exists idx_referrals_created_at on public.referrals (created_at desc);

-- Recreate trigger idempotently for referrals
drop trigger if exists trg_referrals_updated_at on public.referrals;
create trigger trg_referrals_updated_at
before update on public.referrals
for each row execute function public.set_updated_at();

alter table public.referrals enable row level security;
drop policy if exists "Referrals select own" on public.referrals;
create policy "Referrals select own" on public.referrals
  for select using ( auth.uid() = referrer_id );
drop policy if exists "Referrals insert own" on public.referrals;
create policy "Referrals insert own" on public.referrals
  for insert with check ( auth.uid() = referrer_id );
drop policy if exists "Referrals update own" on public.referrals;
create policy "Referrals update own" on public.referrals
  for update using ( auth.uid() = referrer_id );

-- UNIVERSITIES
create table if not exists public.universities (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  logo_url text,
  description text,
  location text,
  website_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_universities_name on public.universities (name);
create index if not exists idx_universities_active on public.universities (is_active);

drop trigger if exists trg_universities_updated_at on public.universities;
create trigger trg_universities_updated_at
before update on public.universities
for each row execute function public.set_updated_at();

alter table public.universities enable row level security;
drop policy if exists "Universities select all" on public.universities;
create policy "Universities select all" on public.universities
  for select using ( true );

-- PROGRAMS
create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  university_id uuid not null references public.universities(id) on delete cascade,
  university_name text not null,
  program_name text not null,
  category text not null,
  duration text not null,
  mode text not null, -- 'Online', 'Offline', 'Hybrid'
  earning numeric(12,2) not null default 0,
  logo_url text,
  description text,
  highlights text[] default '{}',
  brochure_url text,
  is_active boolean not null default true,
  max_referrals int,
  current_referrals int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_programs_university on public.programs (university_id);
create index if not exists idx_programs_category on public.programs (category);
create index if not exists idx_programs_mode on public.programs (mode);
create index if not exists idx_programs_active on public.programs (is_active);
create index if not exists idx_programs_created_at on public.programs (created_at desc);

drop trigger if exists trg_programs_updated_at on public.programs;
create trigger trg_programs_updated_at
before update on public.programs
for each row execute function public.set_updated_at();

alter table public.programs enable row level security;
drop policy if exists "Programs select all" on public.programs;
create policy "Programs select all" on public.programs
  for select using ( is_active = true );

-- USER SESSIONS
create table if not exists public.user_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  device_info text,
  ip_address text,
  user_agent text,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_user_sessions_user on public.user_sessions (user_id);

alter table public.user_sessions enable row level security;
drop policy if exists "Sessions select own" on public.user_sessions;
create policy "Sessions select own" on public.user_sessions
  for select using ( auth.uid() = user_id );
drop policy if exists "Sessions insert own" on public.user_sessions;
create policy "Sessions insert own" on public.user_sessions
  for insert with check ( auth.uid() = user_id );
drop policy if exists "Sessions update own" on public.user_sessions;
create policy "Sessions update own" on public.user_sessions
  for update using ( auth.uid() = user_id );

-- APPLICATIONS
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  program_id uuid not null references public.programs(id) on delete cascade,
  referral_id uuid references public.referrals(id) on delete set null,

  -- Application status
  status text not null default 'draft' check (status in ('draft','in_progress','submitted','accepted','rejected')),
  progress int not null default 0 check (progress >= 0 and progress <= 100),

  -- Granular stage tracking for referral visibility
  stage text not null default 'invited' check (stage in (
    'invited',
    'application_started',
    'personal_info_submitted',
    'academic_info_submitted',
    'documents_submitted',
    'application_fee_paid',
    'application_submitted'
  )),
  stage_history jsonb default '[]'::jsonb,

  -- Stage timestamps
  personal_info_submitted_at timestamptz,
  academic_info_submitted_at timestamptz,
  documents_submitted_at timestamptz,
  application_fee_paid_at timestamptz,
  application_submitted_at timestamptz,

  -- Personal Information
  full_name text,
  father_name text,
  mother_name text,
  date_of_birth date,
  gender text check (gender in ('male','female','other')),
  email text,
  phone text,
  alternate_phone text,

  -- Address Information
  address_line1 text,
  address_line2 text,
  city text,
  state text,
  pincode text,
  country text default 'India',

  -- Educational Information
  highest_qualification text,
  institution_name text,
  passing_year text,
  percentage_or_cgpa text,

  -- Documents
  photo_url text,
  signature_url text,
  id_proof_url text,
  address_proof_url text,
  qualification_certificate_url text,
  other_documents jsonb default '[]'::jsonb,
  documents_submitted boolean not null default false,

  -- Payment Information
  application_fee_amount numeric(12,2),
  application_fee_paid boolean not null default false,
  payment_transaction_id text,
  payment_date timestamptz,

  -- Enrollment
  enrollment_confirmed boolean not null default false,
  enrollment_date timestamptz,
  enrollment_id text,

  -- Additional Information
  notes text,
  metadata jsonb default '{}'::jsonb,

  -- Timestamps
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  submitted_at timestamptz
);

create index if not exists idx_applications_user on public.applications (user_id);
create index if not exists idx_applications_program on public.applications (program_id);
create index if not exists idx_applications_referral on public.applications (referral_id);
create index if not exists idx_applications_status on public.applications (status);
create index if not exists idx_applications_stage on public.applications (stage);
create index if not exists idx_applications_created_at on public.applications (created_at desc);

-- Trigger to auto-update updated_at timestamp
drop trigger if exists trg_applications_updated_at on public.applications;
create trigger trg_applications_updated_at
before update on public.applications
for each row execute function public.set_updated_at();

-- Function to auto-update stage history
create or replace function update_application_stage_history()
returns trigger as $$
begin
  -- Only add to history if stage actually changed
  if OLD.stage IS DISTINCT FROM NEW.stage then
    NEW.stage_history = NEW.stage_history || jsonb_build_object(
      'stage', NEW.stage,
      'timestamp', NOW(),
      'previous_stage', OLD.stage
    );
  end if;

  return NEW;
end;
$$ language plpgsql;

-- Trigger for stage history tracking
drop trigger if exists trg_update_application_stage_history on public.applications;
create trigger trg_update_application_stage_history
  before update on public.applications
  for each row
  execute function update_application_stage_history();

alter table public.applications enable row level security;
drop policy if exists "Applications select own" on public.applications;
create policy "Applications select own" on public.applications
  for select using ( auth.uid() = user_id );
drop policy if exists "Applications insert own" on public.applications;
create policy "Applications insert own" on public.applications
  for insert with check ( auth.uid() = user_id );
drop policy if exists "Applications update own" on public.applications;
create policy "Applications update own" on public.applications
  for update using ( auth.uid() = user_id );


-- LEADERBOARD (public snapshots)
-- Stores precomputed leaderboard rows per period for safe public access
create table if not exists public.leaderboard_snapshots (
  id uuid primary key default gen_random_uuid(),
  period_type text not null check (period_type in ('weekly','monthly')),
  period_start date not null,
  period_end date not null,
  user_id uuid not null references public.users(id) on delete cascade,
  rank int not null,
  display_name text not null,
  avatar_url text,
  level int not null default 1,
  coins int not null default 0,
  total_referrals int not null default 0,
  total_earnings numeric(12,2) not null default 0,
  created_at timestamptz not null default now(),
  unique (period_type, period_start, user_id)
);

create index if not exists idx_lb_period_rank on public.leaderboard_snapshots (period_type, period_start, rank);
create index if not exists idx_lb_user_period on public.leaderboard_snapshots (user_id, period_type, period_start);

alter table public.leaderboard_snapshots enable row level security;
drop policy if exists "Leaderboard select all" on public.leaderboard_snapshots;
create policy "Leaderboard select all" on public.leaderboard_snapshots
  for select using ( true );

-- Optional helper RPC to fetch current period leaderboard
drop function if exists public.get_leaderboard(period text, limit_count int, offset_count int);
create or replace function public.get_leaderboard(
  period text,
  limit_count int default 50,
  offset_count int default 0
)
returns table (
  user_id uuid,
  display_name text,
  avatar_url text,
  level int,
  coins int,
  total_referrals int,
  total_earnings numeric,
  rank int
)
language sql
stable
as $$
  with bounds as (
    select 
      case when lower(period) = 'monthly' then date_trunc('month', now())::date else date_trunc('week', now())::date end as period_start,
      lower(period) as ptype
  )
  select ls.user_id, ls.display_name, ls.avatar_url, ls.level, ls.coins, ls.total_referrals, ls.total_earnings, ls.rank
  from public.leaderboard_snapshots ls
  join bounds b
    on ls.period_start = b.period_start
   and ls.period_type = case when b.ptype = 'monthly' then 'monthly' else 'weekly' end
  order by ls.rank asc
  limit limit_count offset offset_count;
$$;


-- TRANSACTIONS (wallet ledger)
-- Single table to track credits/debits: earnings, withdrawals, bonuses, penalties
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  referral_id uuid references public.referrals(id) on delete set null,
  referral_name text,
  type text not null check (type in ('earning','withdrawal','bonus','penalty')),
  status text not null default 'pending' check (status in ('pending','processing','completed','failed')),
  amount numeric(12,2) not null check (amount > 0),
  description text not null,
  payment_method text check (payment_method in ('upi','bank','paytm')),
  transaction_ref text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create index if not exists idx_tx_user_created on public.transactions (user_id, created_at desc);
create index if not exists idx_tx_type_status on public.transactions (type, status);
create index if not exists idx_tx_referral on public.transactions (referral_id);

alter table public.transactions enable row level security;
drop policy if exists "Transactions select own" on public.transactions;
create policy "Transactions select own" on public.transactions
  for select using ( auth.uid() = user_id );

-- Allow users to request withdrawals themselves (insert-only, their own row)
drop policy if exists "Transactions insert own withdrawals" on public.transactions;
create policy "Transactions insert own withdrawals" on public.transactions
  for insert with check (
    auth.uid() = user_id and type = 'withdrawal'
  );

-- (Optional) allow users to cancel their own pending withdrawal by marking failed
drop policy if exists "Transactions update cancel own pending withdrawal" on public.transactions;
create policy "Transactions update cancel own pending withdrawal" on public.transactions
  for update using (
    auth.uid() = user_id and type = 'withdrawal' and status = 'pending'
  ) with check (
    auth.uid() = user_id and type = 'withdrawal' and status in ('pending','failed')
  );

-- Notes:
-- 1) Service role bypasses RLS and can insert earnings/bonuses and update statuses.
-- 2) Consider adding a scheduled job/Edge Function to populate leaderboard_snapshots
--    from transactions/referrals each night (or hourly) for both weekly and monthly periods.

-- ============================================

-- ============================================
-- ENABLE REALTIME REPLICATION
-- ============================================

-- Enable realtime for programs table
-- This allows the app to receive instant updates when programs are added, updated, or deleted
DO $$
BEGIN
  -- Check if programs table is already in the publication
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
    AND schemaname = 'public'
    AND tablename = 'programs'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.programs;
  END IF;
END $$;

-- Enable realtime for universities table
DO $$
BEGIN
  -- Check if universities table is already in the publication
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
    AND schemaname = 'public'
    AND tablename = 'universities'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.universities;
  END IF;
END $$;

-- Note: Realtime is automatically enabled for authenticated users
-- The app will receive real-time updates for any changes to these tables
-- based on the RLS policies defined above
-- Okay, so I have created buckets where I store the image and brochure assets within the database, however, the images are not being displayed in the app. What could be the issue? Other features such as program name, duration, and mode are working fine.

