# Launch Runbook (Deep Crosscheck) — Creator Specialist OS

## 1) Temuan kritikal sebelum launch

1. **Credential anon key hardcoded di halaman auth** (`auth.html`) yang berisiko bocor permanen dan tersalin ke user/browser history.
2. **Konfigurasi Supabase bergantung ke `localStorage`** (`js/supabaseclient.js`), cocok untuk dev, tapi kurang aman/terkontrol untuk production karena tidak ada source-of-truth environment.
3. **Belum ada automation test/build gate** (repo masih static html/js + edge function manual), sehingga regressions mudah lolos.
4. **Belum ada runbook reset data resmi** untuk pembersihan akun/data demo sebelum launch.

## 2) Perubahan minimum yang WAJIB sebelum production

### A. Nonaktifkan credential contoh di UI
- Jangan tampilkan `SUPABASE_ANON_KEY` literal di UI.
- Setup credential via environment hosting (Vercel env / build injection), bukan instruksi copy-paste key di browser.

### B. Pastikan RLS aktif + policy tervalidasi
- Verifikasi seluruh tabel yang user-facing memakai Row Level Security.
- Tes 3 skenario:
  - user A tidak bisa membaca data user B,
  - user A tidak bisa update/delete data user B,
  - user anonymous tidak bisa akses tabel private.

### C. Bersihkan data user lama/default
- Jalankan `docs/reset_user_data.sql` di staging terlebih dahulu.
- Untuk production, jalankan hanya setelah backup dan freeze deployment.

### D. Tambah smoke test manual release
- Auth register/login/logout.
- Buat brand DNA, list brand, create/update/delete content.
- Akses dari akun kedua untuk validasi isolasi data.

## 3) Langkah lengkap launch (disarankan berurutan)

## Phase 0 — Freeze
1. Freeze fitur baru.
2. Tentukan commit release candidate.
3. Backup database Supabase.

## Phase 1 — Security & Config
1. Putar (rotate) ANON key + SERVICE ROLE key jika pernah terekspos.
2. Simpan URL/key di platform env:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Pastikan tidak ada key literal di file HTML/JS.

## Phase 2 — Database Readiness
1. Apply schema terbaru (`docs/supabase_schema.sql`) di staging.
2. Validasi enum/table/index sukses dibuat.
3. Jalankan reset data staging `docs/reset_user_data.sql`.
4. Seed hanya data yang memang dibutuhkan (tanpa dummy user lama).

## Phase 3 — Functional QA
1. Test auth flow end-to-end.
2. Test CRUD Brand DNA.
3. Test CRUD content ideas.
4. Test edge functions `dna` dan `content` (happy path + error path).
5. Uji dari desktop + mobile viewport.

## Phase 4 — Observability
1. Aktifkan log retention untuk auth, database, edge function.
2. Buat alert minimal:
   - error rate edge function,
   - auth login failure spike,
   - 5xx dari hosting.

## Phase 5 — Production Cutover
1. Backup production DB lagi (tepat sebelum deploy).
2. Deploy frontend + edge function.
3. Jalankan smoke test production.
4. Monitor 60 menit pertama (war room).

## Phase 6 — Post Launch
1. Rekap bug 24 jam pertama.
2. Prioritasi hotfix P0/P1.
3. Kunci prosedur rollback (commit + DB rollback point).

## 4) Checklist final “GO / NO-GO”

- [ ] Tidak ada key rahasia/hardcoded credential di frontend.
- [ ] RLS + policy lolos uji isolasi user.
- [ ] Data lama/demo sudah dibersihkan.
- [ ] Smoke test lulus 100% di staging dan production.
- [ ] Monitoring + alert aktif.
- [ ] Backup point + rollback plan terdokumentasi.
