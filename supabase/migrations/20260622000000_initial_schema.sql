create extension if not exists pgcrypto;

do $$
declare
  suffix text := to_char(now(), 'YYYYMMDDHH24MISS');
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'job_analyses'
      and column_name in ('id', 'user_id')
      and udt_name <> 'uuid'
  ) then
    execute format(
      'alter table public.job_analyses rename to %I',
      'job_analyses_legacy_' || suffix
    );
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'saved_jobs'
      and column_name in ('id', 'user_id', 'job_analysis_id')
      and udt_name <> 'uuid'
  ) then
    execute format(
      'alter table public.saved_jobs rename to %I',
      'saved_jobs_legacy_' || suffix
    );
  end if;
end $$;

create table if not exists public.job_analyses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  job_url text not null,
  job_title text,
  company text,
  location text,
  industry text,
  employment_type text,
  required_experience text,
  required_education text,
  summary text,
  simple_english text,
  simple_luganda text,
  analysis_json jsonb not null,
  created_at timestamptz not null default now()
);

alter table public.job_analyses
  add column if not exists simple_luganda text;

create table if not exists public.saved_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  job_analysis_id uuid not null references public.job_analyses(id) on delete cascade,
  saved_at timestamptz not null default now(),
  unique (user_id, job_analysis_id)
);

create index if not exists job_analyses_user_id_idx
  on public.job_analyses(user_id);

create index if not exists job_analyses_created_at_idx
  on public.job_analyses(created_at desc);

create index if not exists saved_jobs_user_id_idx
  on public.saved_jobs(user_id);

create index if not exists saved_jobs_job_analysis_id_idx
  on public.saved_jobs(job_analysis_id);

alter table public.job_analyses enable row level security;
alter table public.saved_jobs enable row level security;

drop policy if exists "Users can read their analyses"
  on public.job_analyses;

drop policy if exists "Users can create their analyses"
  on public.job_analyses;

drop policy if exists "Users can update their analyses"
  on public.job_analyses;

drop policy if exists "Users can delete their analyses"
  on public.job_analyses;

drop policy if exists "Users can read saved jobs"
  on public.saved_jobs;

drop policy if exists "Users can save jobs"
  on public.saved_jobs;

drop policy if exists "Users can remove saved jobs"
  on public.saved_jobs;

drop policy if exists "Users can update saved jobs"
  on public.saved_jobs;

create policy "Users can read their analyses"
  on public.job_analyses for select
  using (
    auth.uid() = user_id
    or exists (
      select 1
      from public.saved_jobs
      where saved_jobs.job_analysis_id = job_analyses.id
        and saved_jobs.user_id = auth.uid()
    )
  );

create policy "Users can create their analyses"
  on public.job_analyses for insert
  with check (auth.uid() = user_id);

create policy "Users can update their analyses"
  on public.job_analyses for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their analyses"
  on public.job_analyses for delete
  using (auth.uid() = user_id);

create policy "Users can read saved jobs"
  on public.saved_jobs for select
  using (auth.uid() = user_id);

create policy "Users can save jobs"
  on public.saved_jobs for insert
  with check (auth.uid() = user_id);

create policy "Users can update saved jobs"
  on public.saved_jobs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can remove saved jobs"
  on public.saved_jobs for delete
  using (auth.uid() = user_id);
