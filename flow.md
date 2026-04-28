# FLOW.md — Aturan Operasional Aplikasi Creator Specialist OS

## Tujuan Inti
Aplikasi harus memastikan:
1. Konten selalu konsisten dengan DNA (Brand/PERSONAL).
2. Sistem belajar dari feedback user + performa konten.
3. User dipandu naik level: Beginner → Intermediate → Analis → Specialist → Influencer.

## Flow Wajib
1. **Register/Login wajib** sebelum data disimpan permanen.
2. **Input DNA** (brand atau personal) saat onboarding.
3. **Generate konten** berdasarkan DNA + pilar + objective.
4. **CRUD DNA & Content** harus tersedia.
5. **Publish/feedback/performance** disimpan sebagai sinyal optimasi.
6. **Guidance engine** memberi rekomendasi mingguan otomatis.
7. **Leveling engine** memperbarui level creator berdasar score.

## Aturan UX
- Dashboard ringkas: fokus ke insight, task, recommendation.
- Action utama 1 klik: simpan DNA, generate content, mark done.
- Tidak boleh ada data penting hanya di memory frontend.

## Aturan Backend
- Gunakan Supabase Auth + DB + RLS.
- Endpoint DNA dan Content tersedia untuk CRUD.
- Semua endpoint memverifikasi session/JWT user.

## Definisi Done
- User bisa register/login.
- User bisa simpan dan edit DNA.
- User bisa create/read/update/delete content.
- Data tersimpan di Supabase dan bisa dibaca kembali di dashboard.
