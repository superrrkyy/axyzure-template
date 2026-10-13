#!/usr/bin/env bash
# setup.sh — pasang kerangka repo baru dari axyzure-template.
#
# Pakai (dari DALAM folder proyek barumu):
#     bash /path/ke/axyzure-template/scripts/setup.sh web       # React + Vite + TS + Vitest
#     bash /path/ke/axyzure-template/scripts/setup.sh static    # HTML/CSS/JS atau dokumentasi
#     bash /path/ke/axyzure-template/scripts/setup.sh python    # Flask / skrip Python + Pytest
#     bash /path/ke/axyzure-template/scripts/setup.sh minimal   # hanya Dependabot actions
#
# Argumen ke-2 (opsional): folder tujuan — default: folder saat ini.
# Berkas yang SUDAH ADA tidak akan ditimpa.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-}"
TARGET="${2:-$PWD}"

die() { printf '✗ %s\n' "$*" >&2; exit 1; }
ok()  { printf '  ✓ %s\n' "$*"; }

[ -n "$MODE" ] || die "Pilih mode: web | static | python | minimal   (contoh: bash scripts/setup.sh web)"
case "$MODE" in web | static | python | minimal) ;; *) die "Mode '$MODE' tidak dikenal. Pilihan: web | static | python | minimal" ;; esac

[ -d "$TARGET" ] || die "Folder tujuan tidak ada: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" != "$SRC" ] || die "Jalankan di folder proyekmu, bukan di dalam template ini"

pasang() { # pasang <sumber> <tujuan>
  local asal="$1" tuju="$2"
  if [ -e "$tuju" ]; then
    printf '  ! dilewati (sudah ada): %s\n' "${tuju#"$TARGET"/}"
  else
    cp "$asal" "$tuju"
    ok "${tuju#"$TARGET"/}"
  fi
}

mkdir -p "$TARGET/.github/workflows" "$TARGET/.github/ISSUE_TEMPLATE"

# ── dokumen universal (semua mode) ────────────────────────────────────────────
pasang "$SRC/SECURITY.md"                                 "$TARGET/SECURITY.md"
pasang "$SRC/CONTRIBUTING.md"                             "$TARGET/CONTRIBUTING.md"
pasang "$SRC/.github/ISSUE_TEMPLATE/bug_report.yml"       "$TARGET/.github/ISSUE_TEMPLATE/bug_report.yml"
pasang "$SRC/.github/ISSUE_TEMPLATE/feature_request.yml"  "$TARGET/.github/ISSUE_TEMPLATE/feature_request.yml"
pasang "$SRC/.github/PULL_REQUEST_TEMPLATE.md"            "$TARGET/.github/PULL_REQUEST_TEMPLATE.md"

# ── spesifik per mode ─────────────────────────────────────────────────────────
case "$MODE" in
  web)
    mkdir -p "$TARGET/scripts"
    pasang "$SRC/templates/ci-web.yml"         "$TARGET/.github/workflows/ci.yml"
    pasang "$SRC/templates/dependabot-npm.yml" "$TARGET/.github/dependabot.yml"
    pasang "$SRC/templates/gitignore-web"      "$TARGET/.gitignore"
    pasang "$SRC/templates/vitest.config.ts"   "$TARGET/vitest.config.ts"
    pasang "$SRC/scripts/make_og.py"           "$TARGET/scripts/make_og.py"
    ;;
  static)
    mkdir -p "$TARGET/scripts"
    pasang "$SRC/templates/ci-static.yml"          "$TARGET/.github/workflows/ci.yml"
    pasang "$SRC/templates/dependabot-actions.yml" "$TARGET/.github/dependabot.yml"
    pasang "$SRC/templates/gitignore-static"       "$TARGET/.gitignore"
    pasang "$SRC/scripts/check_site.py"            "$TARGET/scripts/check_site.py"
    pasang "$SRC/scripts/make_og.py"               "$TARGET/scripts/make_og.py"
    ;;
  python)
    pasang "$SRC/templates/ci-python.yml"      "$TARGET/.github/workflows/ci.yml"
    pasang "$SRC/templates/dependabot-pip.yml" "$TARGET/.github/dependabot.yml"
    pasang "$SRC/templates/gitignore-python"   "$TARGET/.gitignore"
    ;;
  minimal)
    pasang "$SRC/templates/dependabot-actions.yml" "$TARGET/.github/dependabot.yml"
    ;;
esac

# ── catatan per mode ──────────────────────────────────────────────────────────
case "$MODE" in
  web) printf '\n  ℹ Mode web: pastikan package.json punya skrip "typecheck", "test", dan "build",\n    serta vitest + @vitest/ui bila ingin menjalankan test.\n' ;;
  python) printf '\n  ℹ Mode python: pastikan ada requirements.txt (min. pytest di requirements-dev.txt).\n' ;;
  static) printf '\n  ℹ Mode static: `scripts/check_site.py` memeriksa tautan, heading, dan sintaks JS\n    otomatis di CI — tidak ada yang perlu diatur.\n' ;;
esac

cat <<'TIP'

Selesai! Langkah berikutnya:
  1) git add -A && git commit -m "chore: kerangka repo" && git push
  2) Di GitHub: isi deskripsi + topics, lalu aktifkan
     Settings → Code security → Dependabot alerts + secret scanning + push protection.
  3) Buka CHECKLIST-REPO-BARU.md untuk daftar lengkapnya.

TIP
