-- ============================================================
-- ReachGlobal Crisis Response — Initial Schema
-- Migration 001: Core tables
-- ============================================================

-- Enable UUID generation
create extension if not exists "pgcrypto";

-- ── ENUMS ────────────────────────────────────────────────────────────────────

create type user_role as enum (
  'super_admin', 'coordinator', 'church_coordinator', 'volunteer', 'donor'
);

create type disaster_type as enum (
  'tornado', 'flood', 'fire', 'hurricane', 'earthquake', 'other'
);

create type disaster_status as enum (
  'active', 'winding_down', 'closed'
);

create type project_type as enum (
  'debris_removal', 'structural_repair', 'rebuild', 'interior', 'utilities', 'other'
);

create type project_status as enum (
  'intake', 'assessed', 'scheduled', 'in_progress', 'punch_list', 'complete'
);

create type stage_status as enum (
  'pending', 'in_progress', 'complete'
);

create type task_status as enum (
  'todo', 'in_progress', 'done'
);

create type photo_type as enum (
  'assessment', 'progress', 'completion'
);

create type permit_type as enum (
  'building', 'electrical', 'plumbing', 'demo', 'other'
);

create type skill_tag as enum (
  'general_labor', 'carpentry', 'electrical', 'plumbing',
  'roofing', 'demo', 'meals_support', 'logistics', 'medical'
);

create type document_type as enum (
  'waiver', 'training', 'code_of_conduct', 'permit_info'
);

create type assignment_status as enum (
  'pending', 'confirmed', 'completed', 'cancelled'
);

create type donation_method as enum (
  'online', 'check', 'cash', 'wire'
);

create type item_condition as enum (
  'new', 'like_new', 'good', 'fair'
);

create type expense_category as enum (
  'materials', 'equipment', 'lodging', 'food', 'transport', 'admin', 'other'
);

create type material_status as enum (
  'needed', 'partially_met', 'fulfilled'
);

create type org_type as enum (
  'church', 'nonprofit', 'business', 'individual'
);

create type permission_level as enum (
  'coordinator', 'read_only'
);

-- ── ORGANIZATIONS ─────────────────────────────────────────────────────────────

create table public.organizations (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  type        org_type not null default 'church',
  contact_name text,
  email       text,
  phone       text,
  address     text,
  created_at  timestamptz not null default now()
);

-- ── PROFILES (extends auth.users) ────────────────────────────────────────────

create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  role        user_role not null default 'volunteer',
  full_name   text,
  phone       text,
  org_id      uuid references public.organizations(id),
  created_at  timestamptz not null default now()
);

-- Auto-create profile row on new user signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, role, full_name, phone)
  values (
    new.id,
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'volunteer'),
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── STAFF EVENT PERMISSIONS ───────────────────────────────────────────────────

create table public.staff_event_permissions (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  disaster_id uuid not null, -- FK added after disasters table
  level       permission_level not null default 'coordinator',
  unique(user_id, disaster_id)
);

-- ── DISASTERS ─────────────────────────────────────────────────────────────────

create table public.disasters (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  type            disaster_type not null default 'other',
  location_name   text not null,
  lat             numeric(10,7),
  lng             numeric(10,7),
  start_date      date not null default current_date,
  status          disaster_status not null default 'active',
  public_visible  boolean not null default true,
  description     text,
  base_camp_addr  text,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now()
);

-- Add FK now that disasters table exists
alter table public.staff_event_permissions
  add constraint staff_event_permissions_disaster_id_fkey
  foreign key (disaster_id) references public.disasters(id) on delete cascade;

-- ── RECIPIENTS (homeowners / properties) ─────────────────────────────────────

create table public.recipients (
  id                uuid primary key default gen_random_uuid(),
  full_name         text not null,
  phone             text,
  email             text,
  insurance_co      text,
  insurance_claim   text,
  work_auth_signed  boolean not null default false,
  work_auth_date    date,
  special_needs     text,
  notes             text,
  created_at        timestamptz not null default now()
);

-- ── PROJECTS ──────────────────────────────────────────────────────────────────

create table public.projects (
  id              uuid primary key default gen_random_uuid(),
  disaster_id     uuid not null references public.disasters(id) on delete cascade,
  recipient_id    uuid references public.recipients(id),
  address         text not null,
  lat             numeric(10,7),
  lng             numeric(10,7),
  type            project_type not null default 'other',
  status          project_status not null default 'intake',
  scope_notes     text,
  est_labor_hours integer,
  priority        integer check (priority between 1 and 5) default 3,
  created_by      uuid references public.profiles(id),
  created_at      timestamptz not null default now()
);

-- ── PROJECT STAGES ────────────────────────────────────────────────────────────

create table public.project_stages (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  name        text not null,
  order_index integer not null default 0,
  status      stage_status not null default 'pending',
  start_date  date,
  end_date    date,
  notes       text
);

-- ── TASKS ─────────────────────────────────────────────────────────────────────

create table public.tasks (
  id              uuid primary key default gen_random_uuid(),
  stage_id        uuid not null references public.project_stages(id) on delete cascade,
  name            text not null,
  skill_required  skill_tag,
  status          task_status not null default 'todo',
  notes           text
);

-- ── PROJECT PHOTOS ────────────────────────────────────────────────────────────

create table public.project_photos (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  stage_id    uuid references public.project_stages(id),
  url         text not null,
  caption     text,
  type        photo_type not null default 'assessment',
  taken_by    uuid references public.profiles(id),
  taken_at    timestamptz not null default now()
);

-- ── PERMITS ───────────────────────────────────────────────────────────────────

create table public.permits (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete cascade,
  permit_type     permit_type not null default 'building',
  permit_number   text,
  applied_date    date,
  issued_date     date,
  inspection_date date,
  passed          boolean,
  notes           text
);

-- ── PROJECT NOTES ─────────────────────────────────────────────────────────────

create table public.project_notes (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  author_id   uuid references public.profiles(id),
  body        text not null,
  created_at  timestamptz not null default now()
);

-- ── VOLUNTEERS ────────────────────────────────────────────────────────────────

create table public.volunteer_profiles (
  id                uuid primary key references public.profiles(id) on delete cascade,
  skills            skill_tag[] not null default '{}',
  emergency_name    text,
  emergency_phone   text,
  tshirt_size       text,
  onboarding_done   boolean not null default false
);

-- ── VOLUNTEER TEAMS ───────────────────────────────────────────────────────────

create table public.volunteer_teams (
  id              uuid primary key default gen_random_uuid(),
  org_id          uuid not null references public.organizations(id),
  disaster_id     uuid not null references public.disasters(id),
  coordinator_id  uuid references public.profiles(id),
  name            text not null,
  arrival_date    date,
  departure_date  date,
  headcount       integer
);

-- ── TEAM MEMBERS ──────────────────────────────────────────────────────────────

create table public.team_members (
  id            uuid primary key default gen_random_uuid(),
  team_id       uuid not null references public.volunteer_teams(id) on delete cascade,
  volunteer_id  uuid not null references public.profiles(id) on delete cascade,
  unique(team_id, volunteer_id)
);

-- ── PUBLIC TEAM REQUESTS (limited-access join, no full account needed) ────────

create table public.public_team_requests (
  id          uuid primary key default gen_random_uuid(),
  full_name   text not null,
  email       text not null,
  phone       text,
  team_code   text not null,
  confirmed   boolean not null default false,
  created_at  timestamptz not null default now()
);

-- ── VOLUNTEER ASSIGNMENTS ─────────────────────────────────────────────────────

create table public.volunteer_assignments (
  id            uuid primary key default gen_random_uuid(),
  volunteer_id  uuid not null references public.profiles(id),
  project_id    uuid not null references public.projects(id),
  task_id       uuid references public.tasks(id),
  start_date    date,
  end_date      date,
  hours_logged  numeric(6,2) not null default 0,
  status        assignment_status not null default 'pending',
  notes         text
);

-- ── HOURS LOG ─────────────────────────────────────────────────────────────────

create table public.hours_log (
  id              uuid primary key default gen_random_uuid(),
  assignment_id   uuid not null references public.volunteer_assignments(id) on delete cascade,
  check_in        timestamptz not null,
  check_out       timestamptz,
  hours           numeric(5,2) generated always as (
    extract(epoch from (check_out - check_in)) / 3600.0
  ) stored
);

-- ── DOCUMENTS ─────────────────────────────────────────────────────────────────

create table public.documents (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  type          document_type not null default 'waiver',
  url           text not null,
  version       text not null default '1.0',
  required_for  text[] not null default '{all}',
  active        boolean not null default true,
  created_at    timestamptz not null default now()
);

-- ── DOCUMENT COMPLETIONS ──────────────────────────────────────────────────────

create table public.document_completions (
  id            uuid primary key default gen_random_uuid(),
  document_id   uuid not null references public.documents(id),
  user_id       uuid not null references public.profiles(id),
  completed_at  timestamptz not null default now(),
  signature_url text,
  doc_version   text,
  unique(document_id, user_id)
);

-- ── MATERIALS: PROJECT NEEDS ──────────────────────────────────────────────────

create table public.project_material_needs (
  id                uuid primary key default gen_random_uuid(),
  project_id        uuid not null references public.projects(id) on delete cascade,
  item_name         text not null,
  quantity_needed   numeric(10,2) not null default 1,
  quantity_fulfilled numeric(10,2) not null default 0,
  unit              text not null default 'pieces',
  status            material_status not null default 'needed',
  notes             text
);

-- ── INVENTORY (base camp stock) ───────────────────────────────────────────────

create table public.inventory (
  id              uuid primary key default gen_random_uuid(),
  disaster_id     uuid not null references public.disasters(id),
  item_name       text not null,
  quantity        numeric(10,2) not null default 0,
  unit            text not null default 'pieces',
  location_notes  text,
  donated_by_id   uuid references public.profiles(id),
  updated_at      timestamptz not null default now()
);

-- ── INVENTORY ALLOCATIONS ─────────────────────────────────────────────────────

create table public.inventory_allocations (
  id            uuid primary key default gen_random_uuid(),
  inventory_id  uuid not null references public.inventory(id),
  project_id    uuid not null references public.projects(id),
  quantity      numeric(10,2) not null,
  allocated_at  timestamptz not null default now(),
  allocated_by  uuid references public.profiles(id)
);

-- ── CASH DONATIONS ────────────────────────────────────────────────────────────

create table public.cash_donations (
  id              uuid primary key default gen_random_uuid(),
  disaster_id     uuid references public.disasters(id),
  project_id      uuid references public.projects(id),
  donor_id        uuid references public.profiles(id),
  org_id          uuid references public.organizations(id),
  amount          numeric(12,2) not null,
  date            date not null default current_date,
  method          donation_method not null default 'online',
  receipt_number  text,
  notes           text
);

-- ── MATERIAL DONATIONS ────────────────────────────────────────────────────────

create table public.material_donations (
  id              uuid primary key default gen_random_uuid(),
  disaster_id     uuid not null references public.disasters(id),
  donor_id        uuid references public.profiles(id),
  item_name       text not null,
  quantity        numeric(10,2) not null,
  unit            text not null default 'pieces',
  est_value       numeric(12,2),
  condition       item_condition,
  received_date   date,
  notes           text
);

-- ── EXPENSES ─────────────────────────────────────────────────────────────────

create table public.expenses (
  id            uuid primary key default gen_random_uuid(),
  disaster_id   uuid not null references public.disasters(id),
  project_id    uuid references public.projects(id),
  category      expense_category not null default 'other',
  amount        numeric(12,2) not null,
  date          date not null default current_date,
  description   text not null,
  receipt_url   text,
  logged_by     uuid references public.profiles(id),
  approved_by   uuid references public.profiles(id)
);

-- ── INDEXES ───────────────────────────────────────────────────────────────────

create index idx_projects_disaster      on public.projects(disaster_id);
create index idx_projects_status        on public.projects(status);
create index idx_stages_project         on public.project_stages(project_id);
create index idx_tasks_stage            on public.tasks(stage_id);
create index idx_assignments_volunteer  on public.volunteer_assignments(volunteer_id);
create index idx_assignments_project    on public.volunteer_assignments(project_id);
create index idx_cash_donations_disaster on public.cash_donations(disaster_id);
create index idx_expenses_disaster      on public.expenses(disaster_id);
create index idx_inventory_disaster     on public.inventory(disaster_id);
create index idx_profiles_org           on public.profiles(org_id);
