-- Migration 006: Worksites — multiple property sites per disaster response
-- Supports the per-worksite setup wizard (owner info, photos, work phases).

-- ── Worksites table ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.worksites (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  disaster_id   uuid        NOT NULL REFERENCES public.disasters(id) ON DELETE CASCADE,
  owner_name    text        NOT NULL,
  address       text        NOT NULL,
  lat           double precision,
  lng           double precision,
  property_type text        NOT NULL DEFAULT 'single_family',
  work_phases   text[]      NOT NULL DEFAULT '{}',
  notes         text,
  assessor_id   uuid        REFERENCES public.profiles(id),
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- ── Worksite photos ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.worksite_photos (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  worksite_id uuid        NOT NULL REFERENCES public.worksites(id) ON DELETE CASCADE,
  url         text        NOT NULL,
  caption     text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- ── RLS ───────────────────────────────────────────────────────────────────────
ALTER TABLE public.worksites        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worksite_photos  ENABLE ROW LEVEL SECURITY;

-- Staff (super_admin or assigned) can manage worksites
CREATE POLICY "Staff can manage worksites"
  ON public.worksites FOR ALL
  USING (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM public.staff_event_permissions
      WHERE user_id = auth.uid() AND disaster_id = worksites.disaster_id
    )
  )
  WITH CHECK (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM public.staff_event_permissions
      WHERE user_id = auth.uid() AND disaster_id = worksites.disaster_id
    )
  );

-- Anyone can view worksite photos; staff can insert/delete
CREATE POLICY "Anyone can view worksite photos"
  ON public.worksite_photos FOR SELECT USING (true);

CREATE POLICY "Staff can manage worksite photos"
  ON public.worksite_photos FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.worksites w
      JOIN public.staff_event_permissions sep ON sep.disaster_id = w.disaster_id
      WHERE w.id = worksite_photos.worksite_id
        AND (sep.user_id = auth.uid() OR is_super_admin())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.worksites w
      JOIN public.staff_event_permissions sep ON sep.disaster_id = w.disaster_id
      WHERE w.id = worksite_photos.worksite_id
        AND (sep.user_id = auth.uid() OR is_super_admin())
    )
  );
