create index if not exists saved_jobs_job_analysis_id_idx
  on public.saved_jobs(job_analysis_id);

drop policy if exists "Users can read their analyses"
  on public.job_analyses;

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

drop policy if exists "Users can update saved jobs"
  on public.saved_jobs;

create policy "Users can update saved jobs"
  on public.saved_jobs for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
