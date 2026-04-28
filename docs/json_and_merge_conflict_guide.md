# Cara Pakai File JSON + Cara Mengatasi PR "Branch has merge conflicts"

## A) Cara Makai File JSON di Project Ini

Di repo ini, file JSON dipakai sebagai **konfigurasi / planner / data struktur**, bukan file yang "dijalankan" langsung.

## 1. `vercel.json`
Fungsi: mengatur routing saat deploy di Vercel.

- Lokasi: `vercel.json`
- Contoh isi saat ini:
  - rewrite path tanpa ekstensi file ke `index.html`
  - file statis seperti `auth.html` dan `smoke-test.html` tetap bisa diakses langsung.

Artinya:
- `/dashboard`, `/daily` => ke `index.html` (SPA route)
- `/auth.html` => tetap buka file `auth.html`

## 2. `docs/planner_report.json`
Fungsi: dokumen analisis/plan dalam format JSON.

Cara pakai:
1. Baca manual sebagai planning reference.
2. Bisa diparse di JS kalau mau ditampilkan ke UI.
3. Bisa dipakai sebagai input pipeline internal (mis. sprint board automation).

Contoh baca di JS:
```js
const res = await fetch('/docs/planner_report.json');
const planner = await res.json();
console.log(planner.workflow);
```

## 3. Validasi JSON
Pastikan format valid sebelum commit.

Contoh command:
```bash
python -m json.tool docs/planner_report.json > /tmp/planner.pretty.json
python -m json.tool vercel.json > /tmp/vercel.pretty.json
```

---

## B) Kenapa Merge di GitHub Muncul "Branch has merge conflicts"

Karena branch PR kamu dan branch target (biasanya `main`) mengubah baris/file yang sama, jadi GitHub tidak bisa merge otomatis.

Itu normal. Bukan berarti code jelek, tapi ada perubahan paralel.

---

## C) Langkah Aman Resolve Conflict (Recommended)

> Jalankan di branch PR kamu (bukan di main)

1. Ambil update terbaru:
```bash
git fetch origin
```

2. Checkout branch PR:
```bash
git checkout <nama-branch-pr>
```

3. Rebase ke main terbaru (lebih rapi histori):
```bash
git rebase origin/main
```

4. Kalau conflict muncul:
- buka file yang conflict,
- cari marker:
  - `<<<<<<< HEAD`
  - `=======`
  - `>>>>>>>`
- pilih/gabung isi yang benar,
- simpan.

5. Setelah selesai tiap file:
```bash
git add <file-yang-sudah-dibereskan>
```

6. Lanjut rebase:
```bash
git rebase --continue
```

7. Kalau semua beres, push pakai force-with-lease:
```bash
git push --force-with-lease origin <nama-branch-pr>
```

8. Balik ke PR GitHub, refresh. Biasanya status conflict hilang.

---

## D) Kalau Takut Rebase, Pakai Merge Biasa

Alternatif lebih mudah (histori kurang bersih tapi aman):

```bash
git fetch origin
git checkout <nama-branch-pr>
git merge origin/main
# resolve conflict
git add .
git commit -m "Resolve merge conflicts with main"
git push origin <nama-branch-pr>
```

---

## E) Checklist Sebelum Klik Tombol Merge

- [ ] PR sudah bebas conflict.
- [ ] `vercel.json` tidak merusak route statis.
- [ ] `auth.html` dan `smoke-test.html` tetap bisa dibuka langsung.
- [ ] File JSON valid (`python -m json.tool ...`).
- [ ] Jika pakai squash merge, pastikan commit message jelas.

---

## F) Kenapa Tombol "Cancel" Muncul?

Di layar GitHub mobile itu bukan error; itu opsi untuk batal dialog merge.

Kalau masih ada conflict, tombol merge memang tidak akan menyelesaikan apa-apa sampai conflict di branch dibereskan dulu.

Jadi urutannya:
1. Resolve conflict di branch.
2. Push hasil resolve.
3. Baru merge dari GitHub.
