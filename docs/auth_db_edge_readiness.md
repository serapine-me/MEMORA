# Panduan Detail Validasi Auth + Database + Edge Function (Sebelum AI Engine)

Dokumen ini untuk memastikan fondasi aplikasi **benar-benar jalan** sebelum lanjut membuat API/Edge Function AI.

## 1) Checklist Status “Lengkap”
Auth + database dianggap siap jika semua poin ini lulus:

- [ ] User bisa register dari `auth.html`.
- [ ] User bisa login dari `auth.html`.
- [ ] Tabel `profiles` terisi otomatis setelah register.
- [ ] Onboarding di `index.html` menyimpan Brand DNA ke `brands`.
- [ ] Generate konten menyimpan record ke `content_ideas`.
- [ ] User A tidak bisa membaca data User B (RLS aktif).
- [ ] Endpoint Edge Function `dna` dan `content` bisa dipanggil dengan JWT user.

## 2) Persiapan Wajib di Supabase Dashboard

1. Jalankan SQL schema (`docs/supabase_schema.sql`) di SQL Editor.
2. Auth > Providers: aktifkan Email/Password.
3. Auth > URL Configuration:
   - Site URL: URL aplikasi kamu.
   - Tambahkan redirect URL untuk `index.html` dan `auth.html`.
4. (Opsional saat dev) matikan email confirmation agar login langsung bisa.

## 3) Konfigurasi Client
File: `js/supabaseclient.js`

Gunakan salah satu cara:
1. Set `window.__SUPABASE_URL__` + `window.__SUPABASE_ANON_KEY__`.
2. Simpan ke localStorage:
   - key: `SUPABASE_URL`
   - key: `SUPABASE_ANON_KEY`
3. Isi fallback hardcoded pada:
   - `HARDCODED_SUPABASE_URL`
   - `HARDCODED_SUPABASE_ANON_KEY`

Catatan:
- Di `auth.html` sekarang ada panel **Konfigurasi Supabase** untuk menyimpan URL + anon key ke `localStorage` jika muncul pesan \"Supabase client belum siap\".

## 4) Uji Manual End-to-End (UI)

### A. Register/Login
1. Buka `auth.html`.
2. Register user baru.
3. Login user tersebut.
4. Pastikan redirect ke `index.html` berhasil.

### B. Simpan DNA
1. Dari `index.html`, jalankan onboarding sampai selesai.
2. Cek table editor `brands`: pastikan row baru muncul.

### C. Simpan Content
1. Klik "Generate AI Baru" di page Daily.
2. Cek table `content_ideas`: pastikan konten masuk.

## 5) Uji SQL Cepat di Supabase SQL Editor

### Cek profile terbaru
```sql
select id, full_name, whatsapp_no, email, created_at
from public.profiles
order by created_at desc
limit 5;
```

### Cek DNA terbaru
```sql
select id, owner_id, dna_mode, brand_name, niche, created_at
from public.brands
order by created_at desc
limit 5;
```

### Cek content terbaru
```sql
select id, brand_id, hook, status, dna_alignment_score, created_at
from public.content_ideas
order by created_at desc
limit 10;
```

## 6) Uji Edge Function

Pastikan function sudah deploy:
- `supabase functions deploy dna`
- `supabase functions deploy content`

### A. Ambil JWT user dari browser
Setelah login, ambil access token dari Supabase session (DevTools).

### B. Test endpoint DNA
```bash
curl -X GET 'https://<project-ref>.functions.supabase.co/dna' \
  -H 'Authorization: Bearer <USER_JWT>'
```

### C. Test endpoint Content
```bash
curl -X GET 'https://<project-ref>.functions.supabase.co/content?brand_id=<BRAND_ID>' \
  -H 'Authorization: Bearer <USER_JWT>'
```

## 7) Troubleshooting Paling Umum

1. **Error “Supabase client belum siap”**
   - URL/anon key belum terbaca di `supabaseclient.js`.

2. **Register sukses tapi profile kosong**
   - RLS policy `profiles_owner_all` belum ada/bermasalah.
   - Kolom wajib `full_name/whatsapp_no/email` tidak terisi.

3. **DNA gagal tersimpan**
   - User belum login.
   - RLS `brands_owner_all` menolak karena `owner_id` mismatch.

4. **Content gagal insert**
   - `brand_id` invalid/tidak ditemukan.
   - RLS `content_ideas_owner_all` menolak akses.

5. **Edge Function unauthorized**
   - Header `Authorization: Bearer <token>` tidak valid/expired.

## 8) Kapan Lanjut ke AI Engine?
Lanjut ke API/Edge Function AI **hanya jika**:
- Auth + profile stabil,
- DNA CRUD stabil,
- Content CRUD stabil,
- Edge endpoint dasar stabil,
- RLS lolos uji multi-user.

Setelah ini, AI engine tinggal fokus ke: prompting DNA-aware, scoring, feedback loop, dan rekomendasi level-up.
