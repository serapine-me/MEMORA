# Analogi, Flow, dan Kebutuhan Sistem (Revisi)

## 1) Tujuan Utama Aplikasi
Aplikasi ini adalah **OS pertumbuhan kreator** untuk memastikan semua konten:
1. **Konsisten dengan DNA** (Brand DNA atau Personal DNA), dan
2. **Terus meningkat performanya** lewat loop feedback,
3. **Sambil menaikkan level kreator** secara otomatis dari:
   **Beginner → Intermediate → Analis → Specialist → Influencer**.

## 2) Analogi Produk
Analogi paling pas: **"GPS + Coach + Performance Lab" untuk creator**.

- **DNA = koordinat tujuan** (identitas brand/personal).
- **Generator konten = mesin rute harian** (apa yang dipost hari ini).
- **Analytics & feedback = sensor jalan** (mana konten yang benar-benar efektif).
- **Leveling system = progress perjalanan** dari beginner sampai influencer.

Artinya sistem bukan cuma bikin konten, tapi menuntun user sampai level akhir secara cerdas.

## 3) Flow Produk yang Diinginkan (Updated)

### Step 0 — Registrasi Akun (wajib)
Setelah input DNA, user wajib punya akun dengan data:
- Nama lengkap,
- No WhatsApp,
- Email,
- User ID,
- Password (disimpan aman di Supabase Auth, tidak plain text),
- DNA mode (Brand/Personal) + DNA profile.

### Step 1 — Onboarding DNA
User mengisi:
- Brand DNA **atau** Personal DNA,
- Niche, audience, offer, voice, pilar konten, platform, objective.

Output:
- Positioning statement,
- Pilar konten prioritas,
- Baseline level awal (umumnya `beginner`).

### Step 2 — Daily Content Engine
Sistem generate ide/script/caption/CTA yang:
- Selalu refer ke DNA profile,
- Punya `dna_alignment_score`,
- Masuk ke content pipeline (`idea → planned → drafted → scheduled → posted`).

### Step 3 — Feedback Capture
Setiap interaksi user jadi sinyal:
- approve/reject output,
- edit manual,
- publish sukses/gagal,
- performa posting (views, saves, share, dll).

### Step 4 — Smart Guidance Engine
Engine menghitung skor:
- consistency,
- DNA consistency,
- performance,
- feedback quality.

Lalu sistem otomatis kasih guidance:
- Prioritas task minggu ini,
- Format/tone yang perlu diperbanyak,
- Eksperimen yang harus dicoba,
- Rekomendasi untuk naik level.

### Step 5 — Level Advancement
Jika threshold milestone tercapai, user naik level:
- Beginner → Intermediate → Analis → Specialist → Influencer.

Setiap naik level membuka target yang lebih tinggi (authority, conversion, kolaborasi, monetisasi).

## 4) Pemetaan ke Prototype Saat Ini
Prototype `index.html` sudah punya fondasi UI:
- Welcome + onboarding flow,
- Halaman dashboard/daily/identity/performance/trending/competitor/strategy/streak/evolution,
- Basic AI simulation di sisi frontend.

Namun saat ini masih prototype karena data belum persisten dan belum ada engine leveling otomatis berbasis feedback.

## 5) Kebutuhan Sistem agar Benar-Benar Jalan

## A. Data Layer (Supabase)
Wajib ada:
1. **profiles**: nama, whatsapp, email, user_id (auth), metadata akun.
2. **brands**: dukung `dna_mode = brand/personal` + `dna_profile` JSON.
3. **creator_progress + level_milestones**: tracking level dan syarat naik level.
4. **user_feedback_events + guidance_recommendations**: inti smart guidance loop.
5. **content_ideas/content_assets/content_calendar/metrics**: closed loop content system.

## B. Intelligence Layer
1. **DNA Guardrail**: semua output dicek alignment ke DNA.
2. **Feedback Learner**: model belajar dari edit dan hasil posting.
3. **Guidance Policy**: rekomendasi otomatis berbasis gap ke level berikutnya.
4. **Scheduler**: job harian/mingguan (content generation, metrics sync, level scoring).

## C. UX Layer
1. Registrasi account wajib setelah DNA input (tidak boleh anonymous jika mau save progress).
2. Tiap konten menampilkan: pillar, DNA score, objective, status.
3. Halaman level harus memperlihatkan:
   - level saat ini,
   - progress ke next level,
   - checklist milestone.
4. Guidance harus actionable (contoh: “minggu ini 3 konten edukasi + 2 review”).

## 6) Definisi Sukses “Berjalan Baik”
Dalam 30–60 hari:
1. User posting konsisten mengikuti plan.
2. Rata-rata DNA alignment meningkat.
3. Feedback loop menghasilkan rekomendasi yang dipakai user.
4. Sebagian user naik level (minimal Beginner → Intermediate/Analis).
5. Time-to-publish turun dan metrik engagement naik.

## 7) Implementasi Bertahap
- **Phase 1:** Auth + profile registration + DNA persistence + content CRUD.
- **Phase 2:** Feedback events + guidance engine + creator level scoring.
- **Phase 3:** Auto-optimization lanjutan sampai target level Influencer.
