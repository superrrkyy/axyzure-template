# ✅ Checklist Repo Baru

Ringkasan dari pengalaman merapikan 13 repo: hal-hal kecil yang membedakan repo
"asal jalan" dengan repo yang **layak dipakai orang lain** — dan bisa dikerjakan
dalam 10 menit pertama.

---

## 1) Saat membuat repo (2 menit)

- [ ] **Deskripsi singkat** diisi — bukan kosong. Muncul di pencarian & kartu repo.
- [ ] **Topics** 4–8 buah (mis. `react`, `typescript`, `vite`, `weather-app`).
      Repo tanpa topics hampir tidak pernah muncul di pencarian GitHub.
- [ ] **Situs (About → Website)** diisi kalau proyek punya halaman live.
- [ ] **Wiki dimatikan** kalau tidak dipakai → tidak ada tab kosong yang menyesatkan.
- [ ] Pilih **lisensi** (MIT paling umum) → tanpa lisensi, **tidak ada yang boleh
      memakai kodemu secara hukum**, sehebat apa pun isinya.

## 2) Sebelum commit pertama (3 menit)

- [ ] **`.gitignore`** sudah ada *sebelum* commit pertama —
      `node_modules/`, `dist/`, `.env`, `*.key`, `__pycache__/`.
      (Lihat `templates/gitignore-*`.)
- [ ] **`README.md`** menjawab 3 hal: *ini apa*, *cara menjalankan*, *struktur folder*.
- [ ] **Rahasia tidak masuk repo**: kunci API, token, `.env` — sekali ter-push,
      harus dianggap bocor (hapus riwayat, rotasi kunci). Aktifkan **secret scanning +
      push protection** agar GitHub menahannya lebih dulu.

## 3) Hari pertama — bikin sistemnya hidup (5 menit)

- [ ] **CI sejak commit pertama** (`setup.sh` atau `templates/ci-*`) →
      typecheck + test + build dijalankan GitHub, gratis.
- [ ] **Dependabot** dengan aturan **hanya minor/patch** — upgrade major selalu manual.
- [ ] **Keamanan (Settings → Code security)**:
  - [ ] Dependabot alerts
  - [ ] Dependabot security updates
  - [ ] Secret scanning
  - [ ] Push protection

## 4) Saat proyek mulai serius

- [ ] **`SECURITY.md`** — cara melaporkan kerentanan (bukan lewat issue publik).
- [ ] **`CONTRIBUTING.md`** + **template issue & PR** → kontribusi dari luar punya jalur jelas.
- [ ] **Rilis + tag** (`v1.0.0`) dengan changelog — titik acuan versi untuk pengguna.
- [ ] **Kartu sosial (og:image)** kalau punya situs → tautan tampil bergambar saat dibagikan.
- [ ] **Unit test** untuk logika inti (bukan semuanya) — biar refactor tidak menakutkan.

## 5) Rutin yang menentukan nilai profil

- [ ] **Commit kecil 3×/minggu** — lebih berarti daripada 100 commit dalam sehari lalu hilang sebulan.
- [ ] **Merge PR Dependabot hanya yang CI-nya hijau**; baca dulu kalau major.
- [ ] **Kirim PR ke repo orang lain** — satu-satunya cara nyata nilai *kolaborasi* naik.
- [ ] Pindahkan PR yang tertunda: tutup yang sudah tidak relevan, jangan biarkan menumpuk.

---

## ⚠️ Pelajaran dari 13 repo (yang paling sering bikin merah)

| Gejala | Penyebab | Obat |
| --- | --- | --- |
| `npm ci` gagal di CI | Lockfile tidak diselaraskan setelah menambah dependensi | `npm install --package-lock-only` setelah ubah `package.json` |
| Kartu sosial 404 padahal file ada | File di `assets/`, tapi Vite hanya menyalin `public/` | Taruh di `public/`, arahkan URL ke `/{slug}/og-image.png` |
| CI merah tiba-tiba tanpa mengubah apa pun | PR Dependabot major (mis. Tailwind 3→4) masuk | Tinjau manual; di sini semua major sudah ditahan otomatis |
| Dependabot error terus | Ekosistem tidak cocok jenis repo (npm di repo tanpa `package.json`) | Pakai config sesuai tipe: npm / pip / actions-only |
| Skrip di README tidak jalan | Kode dalam file berisi sisa blok Markdown | Jalankan manual sebelum dokumentasi dijanjikan |
| Merge PR lewat API gagal `405` | Tabrakan internal setelah PR lain masuk | Terapkan langsung ke `main`, tutup PR-nya |

---

## 🗓️ Target realistis

| Kapan | Target |
| --- | --- |
| Repo baru | Checklist 1–3 selesai **di hari pertama** |
| 1 minggu | CI hijau, dependabot bersih, README beres |
| 1 bulan | ≥1 rilis bertag, ≥1 PR ke repo orang lain, grafik kontribusi tidak bolong |
| 3 bulan | Repo punya pengguna/testimoni; profil terlihat seperti wadah portofolio, bukan gudang latihan |
