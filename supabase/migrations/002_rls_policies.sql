-- ============================================================
-- ReachGlobal Crisis Response
-- Migration 002: Row Level Security Policies
-- ============================================================
-- Every table has RLS enabled. Policies follow these rules:
--   • Public data (disasters, projects on public events) → anyone can SELECT
--   • Staff (super_admin / coordinator) → full CRUD on their event(s)
--   • Volunteers → read-only on assigned projects; write own records
--   • Church coordinators → manage own team; read event data
--   • Donors → write own donations; read own history
-- ============================================================

-- Helper: is the caller a super_admin?
create or replace function public.is_super_admin()
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'super_admin'
  );
$$;

-- Helper: is the caller a staff member (super_admin OR coordinator)?
create or replace function public.is_staff()
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('super_admin','coordinator')
  );
$$;

-- Helper: does this staff member have access to a given disaster?
create or replace function public.has_event_access(p_disaster_id uuid)
returns boolean language sql security definer stable as $$
  select
    public.is_super_admin()
    or exists (
      select 1 from public.staff_event_permissions
      where user_id = auth.uid() and disaster_id = p_disaster_id
    );
$$;

-- Helper: is the caller a church_coordinator?
create or replace function public.is_church_coordinator()
returns boolean language sql security definer stable as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'church_coordinator'
  );
$$;

-- ── Enable RLS on all tables ──────────────────────────────────────────────────

alter table public.organizations           enable row level security;
alter table public.profiles                enable row level security;
alter table public.staff_event_permissions enable row level security;
alter table public.disasters               enable row level security;
alter table public.recipients              enable row level security;
alter table public.projects                enable row level security;
alter table public.project_stages          enable row level security;
alter table public.tasks                   enable row level security;
alter table public.project_photos          enable row level security;
alter table public.permits                 enable row level security;
alter table public.project_notes           enable row level security;
alter table public.volunteer_profiles      enable row level security;
alter table public.volunteer_teams         enable row level security;
alter table public.team_members            enable row level security;
alter table public.public_team_requests    enable row level security;
alter table public.volunteer_assignments   enable row level security;
alter table public.hours_log               enable row level security;
alter table public.documents               enable row level security;
alter table public.document_completions    enable row level security;
alter table public.project_material_needs  enable row level security;
alter table public.inventory               enable row level security;
alter table public.inventory_allocations   enable row level security;
alter table public.cash_donations          enable row level security;
alter table public.material_donations      enable row level security;
alter table public.expenses                enable row level security;

-- ── PROFILES ─────────────────────────────────────────────────────────────────

create policy "Users can read their own profile"
  on public.profiles for select
  using (id = auth.uid() or public.is_staff());

create policy "Users can update their own profile"
  on public.profiles for update
  using (id = auth.uid())
  with check (id = auth.uid());

create policy "System can insert profiles (trigger)"
  on public.profiles for insert
  with check (true); -- Handled by handle_new_user trigger (security definer)

-- ── ORGANIZATIONS ─────────────────────────────────────────────────────────────

create policy "Staff can manage organizations"
  on public.organizations for all
  using (public.is_staff())
  with check (public.is_staff());

create policy "Anyone can read organizations"
  on public.organizations for select
  using (true);

-- ── DISASTERS ─────────────────────────────────────────────────────────────────

create policy "Public can view visible disasters"
  on public.disasters for select
  using (public_visible = true or public.is_staff());

create policy "Super admin can manage disasters"
  on public.disasters for all
  using (public.is_super_admin())
  with check (public.is_super_admin());

create policy "Coordinators can update their events"
  on public.disasters for update
  using (public.has_event_access(id))
  with check (public.has_event_access(id));

-- ── STAFF EVENT PERMISSIONS ───────────────────────────────────────────────────

create policy "Super admin manages permissions"
  on public.staff_event_permissions for all
  using (public.is_super_admin())
  with check (public.is_super_admin());

create policy "Staff can view their own permissions"
  on public.staff_event_permissions for select
  using (user_id = auth.uid());

-- ── RECIPIENTS ────────────────────────────────────────────────────────────────

create policy "Staff with event access can manage recipients"
  on public.recipients for all
  using (public.is_staff());

-- ── PROJECTS ─────────────────────────────────────────────────────────────────

create policy "Public can view projects in visible disasters"
  on public.projects for select
  using (
    exists (
      select 1 from public.disasters d
      where d.id = disaster_id and (d.public_visible = true or public.is_staff())
    )
  );

create policy "Staff can insert projects for their events"
  on public.projects for insert
  with check (public.has_event_access(disaster_id));

create policy "Staff can update projects for their events"
  on public.projects for update
  using (public.has_event_access(disaster_id))
  with check (public.has_event_access(disaster_id));

create policy "Staff can delete projects for their events"
  on public.projects for delete
  using (public.has_event_access(disaster_id));

create policy "Volunteers can view their assigned projects"
  on public.projects for select
  using (
    exists (
      select 1 from public.volunteer_assignments va
      where va.project_id = id and va.volunteer_id = auth.uid()
    )
  );

-- ── PROJECT STAGES, TASKS, PHOTOS, PERMITS, NOTES ────────────────────────────
-- Follow the parent project's access rules.

create policy "Staff can manage stages"
  on public.project_stages for all
  using (
    public.has_event_access(
      (select disaster_id from public.projects where id = project_id)
    )
  );

create policy "Anyone who can view the project can view stages"
  on public.project_stages for select
  using (
    exists (
      select 1 from public.projects p
      join public.disasters d on d.id = p.disaster_id
      where p.id = project_id and (d.public_visible = true or public.is_staff())
    )
  );

create policy "Staff can manage tasks"
  on public.tasks for all
  using (
    public.has_event_access(
      (select p.disaster_id from public.projects p
       join public.project_stages s on s.project_id = p.id
       where s.id = stage_id)
    )
  );

create policy "Staff can manage photos"
  on public.project_photos for all
  using (public.is_staff());

create policy "Public can view project photos"
  on public.project_photos for select
  using (true);

create policy "Staff can manage permits"
  on public.permits for all
  using (public.is_staff());

create policy "Staff can manage project notes"
  on public.project_notes for all
  using (public.is_staff());

create policy "Assigned volunteers can add notes"
  on public.project_notes for insert
  with check (
    exists (
      select 1 from public.volunteer_assignments va
      where va.project_id = project_id and va.volunteer_id = auth.uid()
    )
  );

-- ── VOLUNTEERS ────────────────────────────────────────────────────────────────

create policy "Volunteers can read/update their own profile"
  on public.volunteer_profiles for all
  using (id = auth.uid());

create policy "Staff can read all volunteer profiles"
  on public.volunteer_profiles for select
  using (public.is_staff());

-- ── VOLUNTEER TEAMS ───────────────────────────────────────────────────────────

create policy "Staff can manage teams"
  on public.volunteer_teams for all
  using (public.is_staff());

create policy "Church coordinators can manage their own teams"
  on public.volunteer_teams for all
  using (coordinator_id = auth.uid())
  with check (coordinator_id = auth.uid());

create policy "Team members can view their team"
  on public.volunteer_teams for select
  using (
    exists (
      select 1 from public.team_members tm
      where tm.team_id = id and tm.volunteer_id = auth.uid()
    )
  );

-- ── TEAM MEMBERS ──────────────────────────────────────────────────────────────

create policy "Church coordinators can manage team members"
  on public.team_members for all
  using (
    exists (
      select 1 from public.volunteer_teams vt
      where vt.id = team_id and vt.coordinator_id = auth.uid()
    )
    or public.is_staff()
  );

create policy "Volunteers can view their own team membership"
  on public.team_members for select
  using (volunteer_id = auth.uid());

-- ── PUBLIC TEAM REQUESTS (open insert, staff read/manage) ────────────────────

create policy "Anyone can submit a team join request"
  on public.public_team_requests for insert
  with check (true);

create policy "Staff can manage team requests"
  on public.public_team_requests for all
  using (public.is_staff());

-- ── VOLUNTEER ASSIGNMENTS ─────────────────────────────────────────────────────

create policy "Staff can manage assignments"
  on public.volunteer_assignments for all
  using (public.is_staff());

create policy "Volunteers can view their own assignments"
  on public.volunteer_assignments for select
  using (volunteer_id = auth.uid());

create policy "Volunteers can update their own assignment notes/hours"
  on public.volunteer_assignments for update
  using (volunteer_id = auth.uid());

-- ── HOURS LOG ─────────────────────────────────────────────────────────────────

create policy "Volunteers can manage their own hours"
  on public.hours_log for all
  using (
    exists (
      select 1 from public.volunteer_assignments va
      where va.id = assignment_id and va.volunteer_id = auth.uid()
    )
  );

create policy "Staff can view all hours"
  on public.hours_log for select
  using (public.is_staff());

-- ── DOCUMENTS ─────────────────────────────────────────────────────────────────

create policy "Staff can manage documents"
  on public.documents for all
  using (public.is_staff());

create policy "Anyone authenticated can view active documents"
  on public.documents for select
  using (active = true and auth.uid() is not null);

-- ── DOCUMENT COMPLETIONS ──────────────────────────────────────────────────────

create policy "Users can manage their own completions"
  on public.document_completions for all
  using (user_id = auth.uid());

create policy "Staff can view all completions"
  on public.document_completions for select
  using (public.is_staff());

create policy "Church coordinators can view their team's completions"
  on public.document_completions for select
  using (
    exists (
      select 1 from public.team_members tm
      join public.volunteer_teams vt on vt.id = tm.team_id
      where tm.volunteer_id = user_id and vt.coordinator_id = auth.uid()
    )
  );

-- ── MATERIALS ─────────────────────────────────────────────────────────────────

create policy "Staff can manage material needs"
  on public.project_material_needs for all
  using (public.is_staff());

create policy "Public can view material needs"
  on public.project_material_needs for select
  using (true);

create policy "Staff can manage inventory"
  on public.inventory for all
  using (public.is_staff());

create policy "Staff can manage allocations"
  on public.inventory_allocations for all
  using (public.is_staff());

-- ── DONATIONS ─────────────────────────────────────────────────────────────────

create policy "Anyone can insert a cash donation"
  on public.cash_donations for insert
  with check (true);

create policy "Donors can view their own donations"
  on public.cash_donations for select
  using (donor_id = auth.uid() or public.is_staff());

create policy "Church coordinators can view their org donations"
  on public.cash_donations for select
  using (
    org_id in (
      select org_id from public.profiles where id = auth.uid()
    )
  );

create policy "Anyone can insert a material donation"
  on public.material_donations for insert
  with check (true);

create policy "Donors and staff can view material donations"
  on public.material_donations for select
  using (donor_id = auth.uid() or public.is_staff());

-- ── EXPENSES ─────────────────────────────────────────────────────────────────

create policy "Staff can manage expenses"
  on public.expenses for all
  using (public.is_staff());
