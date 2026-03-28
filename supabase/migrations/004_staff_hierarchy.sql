-- ── Migration 004: Staff Hierarchy & Permissions ─────────────────────────────
-- Adds can_add_staff flag, created_by tracking, and updated RLS for the
-- coordinator tree: super_admin → coordinator → site staff.

ALTER TABLE public.staff_event_permissions
  ADD COLUMN IF NOT EXISTS can_add_staff boolean NOT NULL DEFAULT false;

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Super admin helper
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

-- Can-add-staff helper (super_admin always; coordinator if flag set for that disaster)
CREATE OR REPLACE FUNCTION public.can_current_user_add_staff(p_disaster_id uuid DEFAULT NULL)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT CASE
    WHEN is_super_admin() THEN true
    WHEN p_disaster_id IS NULL THEN false
    ELSE EXISTS (
      SELECT 1 FROM public.staff_event_permissions
      WHERE user_id = auth.uid() AND disaster_id = p_disaster_id AND can_add_staff = true
    )
  END;
$$;

-- ── RLS helper functions (SECURITY DEFINER to avoid recursive policy lookups) ──
--
-- is_disaster_manager: returns true if the current user has can_add_staff=true
-- for the given disaster.  Called from staff_event_permissions policies so the
-- function body must NOT be covered by those same policies — SECURITY DEFINER
-- bypasses RLS when it queries staff_event_permissions itself.
CREATE OR REPLACE FUNCTION public.is_disaster_manager(p_disaster_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.staff_event_permissions
    WHERE user_id = auth.uid()
      AND disaster_id = p_disaster_id
      AND can_add_staff = true
  );
$$;

-- is_staff_under_me: returns true if p_user_id shares any disaster with the
-- current user AND the current user has can_add_staff on that disaster.
CREATE OR REPLACE FUNCTION public.is_staff_under_me(p_user_id uuid)
RETURNS boolean LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.staff_event_permissions mgr
    JOIN public.staff_event_permissions sub
      ON sub.disaster_id = mgr.disaster_id
    WHERE mgr.user_id = auth.uid()
      AND mgr.can_add_staff = true
      AND sub.user_id = p_user_id
  );
$$;

-- ── staff_event_permissions RLS ────────────────────────────────────────────────
DROP POLICY IF EXISTS "staff_can_view_permissions"   ON public.staff_event_permissions;
DROP POLICY IF EXISTS "staff_can_insert_permissions" ON public.staff_event_permissions;
DROP POLICY IF EXISTS "staff_can_update_permissions" ON public.staff_event_permissions;
DROP POLICY IF EXISTS "staff_can_delete_permissions" ON public.staff_event_permissions;

-- SELECT: own rows, super_admin, or manager of same disaster
CREATE POLICY "staff_can_view_permissions" ON public.staff_event_permissions
  FOR SELECT USING (
    user_id = auth.uid()
    OR is_super_admin()
    OR is_disaster_manager(disaster_id)
  );

-- INSERT: super_admin or a manager who has can_add_staff on that disaster
CREATE POLICY "staff_can_insert_permissions" ON public.staff_event_permissions
  FOR INSERT WITH CHECK (
    is_super_admin() OR is_disaster_manager(disaster_id)
  );

-- UPDATE: super_admin or disaster manager
CREATE POLICY "staff_can_update_permissions" ON public.staff_event_permissions
  FOR UPDATE USING (
    is_super_admin() OR is_disaster_manager(disaster_id)
  );

-- DELETE: super_admin or disaster manager
CREATE POLICY "staff_can_delete_permissions" ON public.staff_event_permissions
  FOR DELETE USING (
    is_super_admin() OR is_disaster_manager(disaster_id)
  );

-- ── profiles RLS ───────────────────────────────────────────────────────────────
-- See own row, anyone you directly created, all staff sharing your disaster,
-- or super_admin sees everyone.
DROP POLICY IF EXISTS "profiles_visible_to_managers" ON public.profiles;
CREATE POLICY "profiles_visible_to_managers" ON public.profiles
  FOR SELECT USING (
    id = auth.uid()
    OR is_super_admin()
    OR created_by = auth.uid()
    OR is_staff_under_me(id)
  );
