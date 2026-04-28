# FLOW.v2.md — Progress Lanjutan & Rencana Pengembangan

## Progress yang Sudah Dikerjakan
1. Menambahkan dokumen flow utama (`flow.md`) sebagai aturan implementasi.
2. Menambahkan `js/supabaseclient.js` untuk inisialisasi Supabase client dari browser.
3. Memisahkan flow auth ke file terpisah:
   - `auth.html`
   - `js/auth-flow.js`
4. Menambahkan CRUD DNA + Content di frontend service:
   - `js/dna-content-crud.js`
5. Menambahkan endpoint backend (Supabase Edge Functions):
   - `supabase/functions/dna/index.ts`
   - `supabase/functions/content/index.ts`
6. Menyesuaikan `index.html` agar terintegrasi dengan service DNA/Content dan flow auth.

## Gap yang Masih Perlu Ditutup
1. Integrasi metrik platform (TikTok/Instagram/Youtube API).
2. Guidance engine otomatis berbasis feedback real-time.
3. Level scoring engine terjadwal (cron mingguan).
4. Sinkronisasi status content (scheduled/posted) dengan kanal distribusi.
5. Observability: error tracking, retry, dan audit biaya AI.

## Rencana Sprint Selanjutnya
### Sprint A
- Lengkapi halaman Identity dengan tombol edit DNA penuh.
- Hubungkan dashboard cards ke data real dari tabel `content_ideas`.
- Tambahkan optimistic UI + loading states.

### Sprint B
- Tambahkan `user_feedback_events` capture dari aksi UI.
- Implement rekomendasi mingguan otomatis ke `guidance_recommendations`.
- Tambahkan rules level-up berdasarkan milestone.

### Sprint C
- Integrasi model AI (prompt DNA-aware) + quality scoring.
- A/B testing hook + format per platform.
- Report mingguan otomatis via WhatsApp/email.
