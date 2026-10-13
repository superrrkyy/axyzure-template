# 🧰 axyzure-template

![CI](https://github.com/superrrkyy/axyzure-template/actions/workflows/selftest.yml/badge.svg)

**Kerangka repo baru ala AXRYZURE** — hasil menyisir dan merapikan 13 repo:
semua yang paling sering terlupa saat membuat repo baru (CI, lisensi, template issue,
Dependabot yang aman, pemeriksa situs) sudah siap tinggal pakai.

> ⚡ Intinya: repo baru **langsung rapi dan CI hijau sejak commit pertama** — bukan diperbaiki belakangan.

---

## 🚀 Cara pakai

### 1) Tombol "Use this template" (paling simpel)
Di halaman repo ini: **Use this template → Create a new repository** → beri nama → beres.
Semua berkas di root ikut tersalin. Lanjutkan dengan `setup.sh` (cara 2) Kalau perlu CI/pemeriksa.

### 2) `setup.sh` — pasang sesuai jenis proyek (disarankan)

```bash
# dari dalam folder proyek barumu:
bash /path/ke/axyzure-template/scripts/setup.sh web      # React + Vite + TypeScript + Vitest
bash /path/ke/axyzure-template/scripts/setup.sh static   # HTML/CSS/JS atau dokumentasi
bash /path/ke/axyzure-template/scripts/setup.sh python   # Flask / skrip Python + Pytest
bash /path/ke/axyzure-template/scripts/setup.sh minimal  # hanya Dependabot (actions)
```

Aman diulang: berkas yang sudah ada **tidak pernah ditimpa**.

| Mode | Yang dipasang otomatis |
| --- | --- |
| `web` | CI `npm ci → typecheck → test → build`, Dependabot npm, `.gitignore`, `vitest.config.ts`, `make_og.py` |
| `static` | CI pemeriksa HTML/MD/JS (`check_site.py`), Dependabot actions-only, `.gitignore`, `make_og.py` |
| `python` | CI Pytest, Dependabot pip, `.gitignore` python |
| `minimal` | Hanya Dependabot actions — untuk repo apa pun |

Semua mode juga memasang: `SECURITY.md`, `CONTRIBUTING.md`, template issue (bug & fitur), dan template PR.

### 3) Salin manual
Tidak memakai skrip? Ambil saja yang perlu dari `templates/`:

```bash
cp templates/ci-web.yml         .github/workflows/ci.yml
cp templates/dependabot-npm.yml .github/dependabot.yml
cp templates/gitignore-web      .gitignore
```

---

## 📁 Isi repo

| Berkas | Kegunaan |
| --- | --- |
| `templates/ci-web.yml` | CI untuk proyek Vite/React/TS: typecheck → test → build |
| `templates/ci-static.yml` | CI untuk repo statis/dokumentasi (memanggil `scripts/check_site.py`) |
| `templates/ci-python.yml` | CI Pytest + pip cache |
| `templates/dependabot-npm.yml` | Dependabot npm + actions, **hanya minor/patch** yang diusulkan otomatis |
| `templates/dependabot-pip.yml` | Sama, untuk ekosistem pip |
| `templates/dependabot-actions.yml` | Hanya pembaruan Actions — aman untuk repo apa pun |
| `templates/gitignore-web / -static / -python` | `.gitignore` siap pakai per jenis proyek |
| `templates/vitest.config.ts` | Konfigurasi Vitest (alias `@` → `src/`) |
| `templates/og-meta-snippet.html` | Tag `og:image` agar tautan tampil sebagai kartu di WhatsApp/X/LinkedIn |
| `scripts/setup.sh` | Pemasang otomatis (lihat cara pakai di atas) |
| `scripts/check_site.py` | Pemeriksa ringan: tautan rusak, heading melompat, sintaks JS |
| `scripts/make_og.py` | Pembuat kartu sosial 1200×630 dari `og.json` (butuh Pillow) |
| `scripts/selftest.sh` | Uji kesehatan template ini sendiri (dijalankan CI di repo ini) |
| `SECURITY.md` | Cara melaporkan kerentanan + kebijakan versi |
| `CONTRIBUTING.md` | Panduan kontribusi + standar commit (Conventional Commits) |
| `CHECKLIST-REPO-BARU.md` | ✅ Daftar lengkap hal yang harus ada di repo baru |
| `.github/ISSUE_TEMPLATE/` | Form laporan bug & usulan fitur (tangkap info penting sejak awal) |
| `.github/PULL_REQUEST_TEMPLATE.md` | Daftar periksa pull request |
| `.github/dependabot.yml` | Default actions-only — `setup.sh` menggantinya sesuai mode |

---

## 🔧 Sedikit penyesuaian yang diperlukan per proyek

- **Mode web** — pastikan `package.json` punya skrip `typecheck`, `test`, `build`.
  CI akan memberi pesan jelas kalau ada yang kurang. Untuk test, `npm i -D vitest` lalu
  salin `vitest.config.ts` (sudah otomatis dari `setup.sh`).
- **Mode python** — sediakan `requirements.txt` (minimal `pytest` untuk test;
  bisa lewat `requirements-dev.txt`, CI memasang keduanya bila ada).
- **Mode static** — tidak ada yang perlu diatur; `check_site.py` memeriksa
  tautan, heading, dan sintaks JS otomatis.

### Kartu sosial (og:image)
1. `python3 scripts/make_og.py --init` → sunting `og.json` (judul, subjudul, warna aksen, slug).
2. `python3 scripts/make_og.py` → hasil di `og/`.
3. Salin kartu ke folder yang **ikut ter-build**:
   - Vite: `public/og-image.png` (⚠️ **bukan** `assets/` — Vite tidak menyalinnya ke `dist/`).
   - Statis: `assets/og-image.png`.
4. Tempel tag dari `templates/og-meta-snippet.html` ke `<head>` `index.html`.
5. Uji di https://www.opengraph.xyz/

---

## 🟢 Menjaga CI tetap hijau

- **Jangan commit tanpa menjalankan pemeriksaan lokal dulu** — persis perintah yang dipakai CI
  (lihat `CONTRIBUTING.md`). Di repo ini: `bash scripts/selftest.sh`.
- **Menambah dependensi = perbarui lockfile.** Setelah mengubah `package.json`, jalankan:
  `npm install --package-lock-only` agar `npm ci` di CI tidak gagal.
- **Upgrade major jangan dibiarkan otomatis.** Dependabot di sini hanya mengusulkan minor/patch;
  major (mis. Vite 6→8, Tailwind 3→4) selalu ditinjau manual saat proyek sudah siap.

---

## ✅ Checklist lengkap repo baru

Buka ➡️ [`CHECKLIST-REPO-BARU.md`](CHECKLIST-REPO-BARU.md) — dari deskripsi repo, topics,
aktivasi keamanan, sampai kebiasaan commit yang bikin profil terlihat aktif.

---

## 📄 Lisensi

[MIT](LICENSE) © 2026 AXRYZURE — bebas dipakai, diubah, dan dibagikan.
