-- Reset semua data user non-production (staging/dev).
-- JANGAN jalankan script ini di production tanpa backup + approval.

begin;

-- 1) Hapus data domain app (cascade by FK akan membersihkan child tables)
delete from public.profiles;

-- 2) Hapus user auth Supabase (wajib role service_role / postgres)
delete from auth.users;

-- 3) Opsional: reset sequence / statistik planner if any table without FK to profiles
-- contoh:
-- truncate table public.some_audit_table restart identity;

commit;
