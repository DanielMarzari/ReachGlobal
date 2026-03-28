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

-- staff_event_permissions RLS
DROP POLICY IF EXISTS "staff_can_view_permissions"   ON public.staff_event_permissions;
DROP POLICY IF EXISTS "staff_can_insert_permissions" ON public.staff_event_permissions;
DROP POLICY IF EXISTS "staff_can_update_permissions" ON public.staff_event_permissions;
DROP POLICY IF EXISTS "staff_can_delete_permissions" ON public.staff_event_permissions;

CREATE POLICY "staff_can_view_permissions" ON public.staff_event_permissions FOR SELECT USING (
  is_super_admin() OR user_id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.staff_event_permissions mgr
    WHERE mgr.user_id = auth.uid() AND mgr.disaster_id = staff_event_permissions.disaster_id AND mgr.can_add_staff = true
  )
);
CREATE POLICY "staff_can_insert_permissions" ON public.staff_event_permissions FOR INSERT WITH CHECK (
  is_super_admin() OR can_current_user_add_staff(disaster_id)
);
CREATE POLICY "staff_can_update_permissions" ON public.staff_event_permissions FOR UPDATE USING (
  is_super_admin() OR EXISTS (
    SELECT 1 FROM public.staff_event_permissions mgr
    WHERE mgr.user_id = auth.uid() AND mgr.disaster_id = staff_event_permissions.disaster_id AND mgr.can_add_staff = true
  )
);
CREATE POLICY "staff_can_delete_permissions" ON public.staff_event_permissions FOR DELETE USING (
  is_super_admin() OR EXISTS (
    SELECT 1 FROM public.staff_event_permissions mgr
    WHERE mgr.user_id = auth.uid() AND mgr.disaster_id = staff_event_permissions.disaster_id AND mgr.can_add_staff = true
  )
);

-- profiles RLS: see self, people you created, and staff at your disasters
DROP POLICY IF EXISTS "profiles_visible_to_managers" ON public.profiles;
CREATE POLICY "profiles_visible_to_managers" ON public.profiles FOR SELECT USING (
  id = auth.uid() OR is_super_admin() OR created_by = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.staff_event_permissions my_sep
    JOIN public.staff_event_permissions their_sep ON their_sep.disaster_id = my_sep.disaster_id
    WHERE my_sep.user_id = auth.uid() AND my_sep.can_add_staff = true AND their_sep.user_id = profiles.id
  )
);
