-- ── Migration 005: Site Assessment & Response Setup Wizard ───────────────────
-- Supports the post-creation onboarding flow for new disaster responses.
-- Captures site photos, selected work phases, room dimensions, and auto-
-- generates baseline inventory estimates.

-- ── Extend disasters table ────────────────────────────────────────────────────
ALTER TABLE public.disasters
  ADD COLUMN IF NOT EXISTS cover_image_url  text,
  ADD COLUMN IF NOT EXISTS setup_complete   boolean NOT NULL DEFAULT false;

-- ── Site assessment (one per disaster) ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.site_assessments (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  disaster_id     uuid        NOT NULL REFERENCES public.disasters(id) ON DELETE CASCADE,
  selected_stages text[]      NOT NULL DEFAULT '{}',
  general_notes   text,
  setup_complete  boolean     NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  UNIQUE(disaster_id)
);

-- ── Individual affected rooms / areas ─────────────────────────────────────────
-- Stores dimensions so material quantities can be auto-estimated.
CREATE TABLE IF NOT EXISTS public.assessment_areas (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  assessment_id   uuid        NOT NULL REFERENCES public.site_assessments(id) ON DELETE CASCADE,
  area_name       text        NOT NULL,
  area_type       text        NOT NULL DEFAULT 'room',     -- room | basement | attic | garage | exterior
  length_ft       numeric(8,2) NOT NULL DEFAULT 0,
  width_ft        numeric(8,2) NOT NULL DEFAULT 0,
  height_ft       numeric(8,2) NOT NULL DEFAULT 8,
  damage_level    text        NOT NULL DEFAULT 'moderate', -- light | moderate | severe
  damage_types    text[]      NOT NULL DEFAULT '{}',       -- walls | ceiling | floor | roof | windows | doors | electrical | plumbing
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- ── Site photo metadata ───────────────────────────────────────────────────────
-- Files live in the existing 'project-photos' storage bucket.
CREATE TABLE IF NOT EXISTS public.site_photos (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  disaster_id     uuid        NOT NULL REFERENCES public.disasters(id) ON DELETE CASCADE,
  storage_path    text        NOT NULL,
  public_url      text,
  caption         text,
  photo_type      text        NOT NULL DEFAULT 'damage',  -- damage | before | during | after | cover
  uploaded_by     uuid        REFERENCES public.profiles(id),
  taken_at        timestamptz NOT NULL DEFAULT now()
);

-- ── SECURITY DEFINER helper ───────────────────────────────────────────────────
-- Avoids RLS recursion when assessment_areas policies reference site_assessments.
CREATE OR REPLACE FUNCTION public.is_assessment_member(p_assessment_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.site_assessments sa
    WHERE sa.id = p_assessment_id
      AND (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'super_admin')
        OR EXISTS (
          SELECT 1 FROM public.staff_event_permissions
          WHERE user_id = auth.uid() AND disaster_id = sa.disaster_id
        )
      )
  );
$$;

-- ── Enable RLS ────────────────────────────────────────────────────────────────
ALTER TABLE public.site_assessments  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessment_areas  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.site_photos       ENABLE ROW LEVEL SECURITY;

-- site_assessments: super_admin or assigned staff can read/write
CREATE POLICY "Staff can manage site assessments"
  ON public.site_assessments FOR ALL
  USING (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM public.staff_event_permissions
      WHERE user_id = auth.uid() AND disaster_id = site_assessments.disaster_id
    )
  )
  WITH CHECK (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM public.staff_event_permissions
      WHERE user_id = auth.uid() AND disaster_id = site_assessments.disaster_id
    )
  );

-- assessment_areas: accessible via SECURITY DEFINER helper (avoids RLS cycle)
CREATE POLICY "Staff can manage assessment areas"
  ON public.assessment_areas FOR ALL
  USING    (is_assessment_member(assessment_id))
  WITH CHECK (is_assessment_member(assessment_id));

-- site_photos: public read, staff write/delete
CREATE POLICY "Anyone can view site photos"
  ON public.site_photos FOR SELECT USING (true);

CREATE POLICY "Staff can upload site photos"
  ON public.site_photos FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND (
      is_super_admin()
      OR EXISTS (
        SELECT 1 FROM public.staff_event_permissions
        WHERE user_id = auth.uid() AND disaster_id = site_photos.disaster_id
      )
    )
  );

CREATE POLICY "Staff can delete own site photos"
  ON public.site_photos FOR DELETE
  USING (uploaded_by = auth.uid() OR is_super_admin());
