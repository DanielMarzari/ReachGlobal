-- ============================================================
-- ReachGlobal Crisis Response
-- Migration 003: Supabase Storage Buckets
-- ============================================================

-- Project photos (public read, staff write)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'project-photos',
  'project-photos',
  true,
  10485760, -- 10 MB
  array['image/jpeg','image/png','image/webp','image/heic']
)
on conflict (id) do nothing;

-- Legal documents and signed waivers (private — staff + owner only)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'documents',
  'documents',
  false,
  20971520, -- 20 MB
  array['application/pdf','image/jpeg','image/png']
)
on conflict (id) do nothing;

-- Expense receipts (private — staff only)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'receipts',
  'receipts',
  false,
  10485760, -- 10 MB
  array['application/pdf','image/jpeg','image/png']
)
on conflict (id) do nothing;

-- ── Storage RLS policies ──────────────────────────────────────────────────────

-- project-photos: anyone can view, authenticated staff can upload
create policy "Public can view project photos"
  on storage.objects for select
  using (bucket_id = 'project-photos');

create policy "Staff can upload project photos"
  on storage.objects for insert
  with check (
    bucket_id = 'project-photos'
    and auth.uid() is not null
    and (
      select role from public.profiles where id = auth.uid()
    ) in ('super_admin','coordinator')
  );

-- documents: only owner or staff can access
create policy "Owner can view their own documents"
  on storage.objects for select
  using (
    bucket_id = 'documents'
    and (
      auth.uid()::text = (storage.foldername(name))[1]
      or (select role from public.profiles where id = auth.uid())
         in ('super_admin','coordinator')
    )
  );

create policy "Authenticated users can upload their own documents"
  on storage.objects for insert
  with check (
    bucket_id = 'documents'
    and auth.uid() is not null
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- receipts: staff only
create policy "Staff can manage receipts"
  on storage.objects for all
  using (
    bucket_id = 'receipts'
    and (
      select role from public.profiles where id = auth.uid()
    ) in ('super_admin','coordinator')
  );
