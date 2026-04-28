-- Supabase schema for Creator Specialist OS
-- Objective: keep generated content consistent with Brand/Personal DNA,
-- and automatically guide creators from beginner -> influencer.

create extension if not exists pgcrypto;

-- ===== ENUMS =====
create type public.dna_mode as enum ('brand', 'personal');
create type public.platform_type as enum ('tiktok', 'instagram', 'youtube', 'linkedin', 'x', 'facebook');
create type public.creator_level as enum ('beginner', 'intermediate', 'analis', 'specialist', 'influencer');
create type public.content_status as enum ('idea', 'planned', 'drafted', 'scheduled', 'posted', 'archived');
create type public.content_format as enum ('talking_head', 'tutorial', 'review', 'storytelling', 'listicle', 'bts', 'carousel', 'live');
create type public.tone_type as enum ('friendly', 'bold', 'educational', 'storytelling', 'premium');
create type public.trend_status as enum ('new', 'adapted', 'rejected', 'expired');

-- ===== UTIL =====
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$;

-- ===== ACCOUNT & PROFILE =====
-- Password is managed by Supabase Auth (auth.users) and should NOT be stored in plain text.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  whatsapp_no text not null,
  email text not null,
  avatar_url text,
  timezone text not null default 'Asia/Jakarta',
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now()),
  unique (email),
  unique (whatsapp_no)
);

create table if not exists public.brands (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  dna_mode public.dna_mode not null default 'brand',
  brand_name text not null,
  niche text,
  primary_offer text,
  target_audience text,
  positioning_statement text,
  voice_guide text,
  mission text,
  vision text,
  dna_profile jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);
create index if not exists idx_brands_owner_active on public.brands(owner_id, is_active);

create table if not exists public.brand_platforms (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  platform public.platform_type not null,
  handle text,
  posting_frequency_per_week int not null default 3,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (brand_id, platform)
);

create table if not exists public.brand_pillars (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  pillar_name text not null,
  description text,
  priority smallint not null default 3 check (priority between 1 and 5),
  created_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.onboarding_responses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  brand_id uuid references public.brands(id) on delete set null,
  step_no int not null check (step_no between 1 and 5),
  payload jsonb not null,
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- ===== CREATOR LEVELING & AUTO GUIDANCE =====
create table if not exists public.creator_progress (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null unique references public.brands(id) on delete cascade,
  current_level public.creator_level not null default 'beginner',
  level_score numeric(6,2) not null default 0,
  consistency_score numeric(6,2) not null default 0,
  dna_consistency_score numeric(6,2) not null default 0,
  performance_score numeric(6,2) not null default 0,
  feedback_score numeric(6,2) not null default 0,
  updated_by_engine_at timestamptz,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.level_milestones (
  id uuid primary key default gen_random_uuid(),
  level public.creator_level not null,
  milestone_code text not null,
  milestone_name text not null,
  min_level_score numeric(6,2) not null,
  min_dna_consistency numeric(6,2) not null,
  min_consistency numeric(6,2) not null,
  min_performance numeric(6,2) not null,
  guidance_template text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (level, milestone_code)
);

create table if not exists public.user_feedback_events (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  source_feature text not null,
  feedback_type text not null check (feedback_type in ('like_output', 'dislike_output', 'manual_edit', 'publish_success', 'publish_fail')),
  feedback_note text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc'::text, now())
);
create index if not exists idx_feedback_brand_date on public.user_feedback_events(brand_id, created_at desc);

create table if not exists public.guidance_recommendations (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  target_level public.creator_level not null,
  recommendation_type text not null,
  recommendation_text text not null,
  priority smallint not null default 3 check (priority between 1 and 5),
  status text not null default 'open' check (status in ('open', 'accepted', 'done', 'rejected')),
  generated_from jsonb not null default '{}'::jsonb,
  due_date date,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

-- ===== CONTENT SYSTEM =====
create table if not exists public.content_ideas (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  pillar_id uuid references public.brand_pillars(id) on delete set null,
  hook text not null,
  topic text,
  angle text,
  format public.content_format,
  platform public.platform_type,
  est_duration_seconds int,
  confidence_score numeric(5,2) check (confidence_score between 0 and 100),
  dna_alignment_score numeric(5,2) not null default 0 check (dna_alignment_score between 0 and 100),
  source text not null default 'ai',
  status public.content_status not null default 'idea',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);
create index if not exists idx_content_ideas_brand_status on public.content_ideas(brand_id, status);

create table if not exists public.content_assets (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.content_ideas(id) on delete cascade,
  asset_type text not null check (asset_type in ('caption','script','hashtags','cta','thumbnail','shot_list')),
  tone public.tone_type,
  body text not null,
  metadata jsonb not null default '{}'::jsonb,
  version_no int not null default 1,
  generated_by text not null default 'ai',
  created_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.content_calendar (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  content_id uuid references public.content_ideas(id) on delete set null,
  platform public.platform_type not null,
  scheduled_for timestamptz not null,
  status public.content_status not null default 'planned',
  notes text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.publish_logs (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.content_ideas(id) on delete cascade,
  platform public.platform_type not null,
  posted_at timestamptz not null,
  external_post_id text,
  permalink text,
  created_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.content_metrics_daily (
  id uuid primary key default gen_random_uuid(),
  content_id uuid not null references public.content_ideas(id) on delete cascade,
  metric_date date not null,
  views int not null default 0,
  likes int not null default 0,
  comments int not null default 0,
  shares int not null default 0,
  saves int not null default 0,
  watch_time_seconds numeric(12,2),
  avg_watch_duration_seconds numeric(12,2),
  ctr numeric(6,3),
  profile_visits int,
  follows int,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (content_id, metric_date)
);

-- ===== STRATEGY / TREND / COMPETITOR / GAMIFICATION =====
create table if not exists public.weekly_strategies (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  week_start date not null,
  week_end date not null,
  focus text not null,
  rationale text,
  kpi_target jsonb not null default '{}'::jsonb,
  ai_summary text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (brand_id, week_start)
);

create table if not exists public.strategy_tasks (
  id uuid primary key default gen_random_uuid(),
  strategy_id uuid not null references public.weekly_strategies(id) on delete cascade,
  task_name text not null,
  owner_label text,
  due_date date,
  is_done boolean not null default false,
  priority smallint not null default 3 check (priority between 1 and 5),
  created_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.trending_signals (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  platform public.platform_type not null,
  trend_title text not null,
  trend_type text,
  source_url text,
  raw_signal jsonb not null default '{}'::jsonb,
  trend_score numeric(5,2),
  status public.trend_status not null default 'new',
  detected_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.competitor_profiles (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  platform public.platform_type not null,
  competitor_handle text not null,
  profile_url text,
  notes text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (brand_id, platform, competitor_handle)
);

create table if not exists public.competitor_snapshots (
  id uuid primary key default gen_random_uuid(),
  competitor_id uuid not null references public.competitor_profiles(id) on delete cascade,
  snapshot_date date not null,
  followers int,
  total_posts int,
  avg_views int,
  top_content_summary text,
  insights jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (competitor_id, snapshot_date)
);

create table if not exists public.streak_daily (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  activity_date date not null,
  posted_count int not null default 0,
  score int not null default 0,
  badge_code text,
  created_at timestamptz not null default timezone('utc'::text, now()),
  unique (brand_id, activity_date)
);

create table if not exists public.evolution_milestones (
  id uuid primary key default gen_random_uuid(),
  brand_id uuid not null references public.brands(id) on delete cascade,
  phase_name text not null,
  progress_pct numeric(5,2) not null default 0 check (progress_pct between 0 and 100),
  evidence text,
  target_date date,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now())
);

create table if not exists public.ai_generation_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete set null,
  brand_id uuid references public.brands(id) on delete set null,
  feature_name text not null,
  input_payload jsonb not null,
  output_payload jsonb,
  model_name text,
  latency_ms int,
  token_usage jsonb,
  created_at timestamptz not null default timezone('utc'::text, now())
);

-- ===== UPDATED_AT TRIGGERS =====
create trigger trg_profiles_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger trg_brands_updated_at before update on public.brands for each row execute function public.set_updated_at();
create trigger trg_creator_progress_updated_at before update on public.creator_progress for each row execute function public.set_updated_at();
create trigger trg_guidance_recommendations_updated_at before update on public.guidance_recommendations for each row execute function public.set_updated_at();
create trigger trg_content_ideas_updated_at before update on public.content_ideas for each row execute function public.set_updated_at();
create trigger trg_content_calendar_updated_at before update on public.content_calendar for each row execute function public.set_updated_at();
create trigger trg_evolution_milestones_updated_at before update on public.evolution_milestones for each row execute function public.set_updated_at();

-- ===== RLS =====
alter table public.profiles enable row level security;
alter table public.brands enable row level security;
alter table public.brand_platforms enable row level security;
alter table public.brand_pillars enable row level security;
alter table public.onboarding_responses enable row level security;
alter table public.creator_progress enable row level security;
alter table public.level_milestones enable row level security;
alter table public.user_feedback_events enable row level security;
alter table public.guidance_recommendations enable row level security;
alter table public.content_ideas enable row level security;
alter table public.content_assets enable row level security;
alter table public.content_calendar enable row level security;
alter table public.publish_logs enable row level security;
alter table public.content_metrics_daily enable row level security;
alter table public.weekly_strategies enable row level security;
alter table public.strategy_tasks enable row level security;
alter table public.trending_signals enable row level security;
alter table public.competitor_profiles enable row level security;
alter table public.competitor_snapshots enable row level security;
alter table public.streak_daily enable row level security;
alter table public.evolution_milestones enable row level security;
alter table public.ai_generation_logs enable row level security;

create policy "profiles_owner_all" on public.profiles
for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "brands_owner_all" on public.brands
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy "level_milestones_read_all" on public.level_milestones
for select using (true);

-- Reusable owner-check pattern on brand_id relation
create policy "brand_platforms_owner_all" on public.brand_platforms
for all using (exists (select 1 from public.brands b where b.id = brand_platforms.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = brand_platforms.brand_id and b.owner_id = auth.uid()));

create policy "brand_pillars_owner_all" on public.brand_pillars
for all using (exists (select 1 from public.brands b where b.id = brand_pillars.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = brand_pillars.brand_id and b.owner_id = auth.uid()));

create policy "onboarding_owner_all" on public.onboarding_responses
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "creator_progress_owner_all" on public.creator_progress
for all using (exists (select 1 from public.brands b where b.id = creator_progress.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = creator_progress.brand_id and b.owner_id = auth.uid()));

create policy "feedback_owner_all" on public.user_feedback_events
for all using (exists (select 1 from public.brands b where b.id = user_feedback_events.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = user_feedback_events.brand_id and b.owner_id = auth.uid()));

create policy "guidance_owner_all" on public.guidance_recommendations
for all using (exists (select 1 from public.brands b where b.id = guidance_recommendations.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = guidance_recommendations.brand_id and b.owner_id = auth.uid()));

create policy "content_ideas_owner_all" on public.content_ideas
for all using (exists (select 1 from public.brands b where b.id = content_ideas.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = content_ideas.brand_id and b.owner_id = auth.uid()));

create policy "content_assets_owner_all" on public.content_assets
for all using (
  exists (
    select 1 from public.content_ideas ci
    join public.brands b on b.id = ci.brand_id
    where ci.id = content_assets.content_id and b.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.content_ideas ci
    join public.brands b on b.id = ci.brand_id
    where ci.id = content_assets.content_id and b.owner_id = auth.uid()
  )
);

create policy "content_calendar_owner_all" on public.content_calendar
for all using (exists (select 1 from public.brands b where b.id = content_calendar.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = content_calendar.brand_id and b.owner_id = auth.uid()));

create policy "publish_logs_owner_all" on public.publish_logs
for all using (
  exists (
    select 1 from public.content_ideas ci
    join public.brands b on b.id = ci.brand_id
    where ci.id = publish_logs.content_id and b.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.content_ideas ci
    join public.brands b on b.id = ci.brand_id
    where ci.id = publish_logs.content_id and b.owner_id = auth.uid()
  )
);

create policy "metrics_owner_all" on public.content_metrics_daily
for all using (
  exists (
    select 1 from public.content_ideas ci
    join public.brands b on b.id = ci.brand_id
    where ci.id = content_metrics_daily.content_id and b.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.content_ideas ci
    join public.brands b on b.id = ci.brand_id
    where ci.id = content_metrics_daily.content_id and b.owner_id = auth.uid()
  )
);

create policy "weekly_strategies_owner_all" on public.weekly_strategies
for all using (exists (select 1 from public.brands b where b.id = weekly_strategies.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = weekly_strategies.brand_id and b.owner_id = auth.uid()));

create policy "strategy_tasks_owner_all" on public.strategy_tasks
for all using (
  exists (
    select 1 from public.weekly_strategies ws
    join public.brands b on b.id = ws.brand_id
    where ws.id = strategy_tasks.strategy_id and b.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.weekly_strategies ws
    join public.brands b on b.id = ws.brand_id
    where ws.id = strategy_tasks.strategy_id and b.owner_id = auth.uid()
  )
);

create policy "trending_owner_all" on public.trending_signals
for all using (exists (select 1 from public.brands b where b.id = trending_signals.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = trending_signals.brand_id and b.owner_id = auth.uid()));

create policy "competitor_profiles_owner_all" on public.competitor_profiles
for all using (exists (select 1 from public.brands b where b.id = competitor_profiles.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = competitor_profiles.brand_id and b.owner_id = auth.uid()));

create policy "competitor_snapshots_owner_all" on public.competitor_snapshots
for all using (
  exists (
    select 1 from public.competitor_profiles cp
    join public.brands b on b.id = cp.brand_id
    where cp.id = competitor_snapshots.competitor_id and b.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.competitor_profiles cp
    join public.brands b on b.id = cp.brand_id
    where cp.id = competitor_snapshots.competitor_id and b.owner_id = auth.uid()
  )
);

create policy "streak_owner_all" on public.streak_daily
for all using (exists (select 1 from public.brands b where b.id = streak_daily.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = streak_daily.brand_id and b.owner_id = auth.uid()));

create policy "evolution_owner_all" on public.evolution_milestones
for all using (exists (select 1 from public.brands b where b.id = evolution_milestones.brand_id and b.owner_id = auth.uid()))
with check (exists (select 1 from public.brands b where b.id = evolution_milestones.brand_id and b.owner_id = auth.uid()));

create policy "ai_logs_owner_all" on public.ai_generation_logs
for all using (
  auth.uid() = user_id
  or exists (select 1 from public.brands b where b.id = ai_generation_logs.brand_id and b.owner_id = auth.uid())
)
with check (
  auth.uid() = user_id
  or exists (select 1 from public.brands b where b.id = ai_generation_logs.brand_id and b.owner_id = auth.uid())
);
