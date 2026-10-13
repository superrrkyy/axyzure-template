#!/usr/bin/env bash
# selftest.sh — memastikan template ini sendiri tetap sehat.
# Dijalankan otomatis oleh CI (.github/workflows/selftest.yml) dan bisa juga manual:
#     bash scripts/selftest.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== 1/3 · Validasi berkas YAML =="
python3 - "$ROOT" <<'PY'
import pathlib
import sys

try:
    import yaml
except ImportError:
    print("  ! PyYAML tidak terpasang — validasi YAML dilewati")
    raise SystemExit(0)

root = pathlib.Path(sys.argv[1])
n = bad = 0
for p in sorted(root.rglob("*.y*ml")):
    if ".git" in p.parts:
        continue
    try:
        yaml.safe_load(p.read_text(encoding="utf-8"))
        n += 1
    except Exception as e:  # noqa: BLE001
        print(f"  ✗ YAML rusak: {p.relative_to(root)} → {e}")
        bad += 1
print(f"  ✓ {n} berkas YAML valid" if not bad else f"  ✗ {bad} berkas bermasalah")
raise SystemExit(1 if bad else 0)
PY

echo "== 2/3 · Sintaks skrip shell =="
for f in "$ROOT"/scripts/*.sh; do
  bash -n "$f"
  echo "  ✓ $(basename "$f")"
done

echo "== 3/3 · Uji setup.sh di setiap mode =="
for mode in web static python minimal; do
  tmp="$(mktemp -d)"
  bash "$ROOT/scripts/setup.sh" "$mode" "$tmp" > /dev/null

  [ -f "$tmp/SECURITY.md" ] || { echo "  ✗ $mode: SECURITY.md kurang"; exit 1; }
  [ -f "$tmp/CONTRIBUTING.md" ] || { echo "  ✗ $mode: CONTRIBUTING.md kurang"; exit 1; }
  [ -f "$tmp/.github/dependabot.yml" ] || { echo "  ✗ $mode: dependabot.yml kurang"; exit 1; }
  [ -f "$tmp/.github/ISSUE_TEMPLATE/bug_report.yml" ] || { echo "  ✗ $mode: template issue kurang"; exit 1; }

  if [ "$mode" = "minimal" ]; then
    if [ -f "$tmp/.github/workflows/ci.yml" ]; then
      echo "  ✗ minimal: ci.yml seharusnya tidak dipasang"; exit 1
    fi
  else
    [ -f "$tmp/.github/workflows/ci.yml" ] || { echo "  ✗ $mode: ci.yml kurang"; exit 1; }
    [ -f "$tmp/.gitignore" ] || { echo "  ✗ $mode: .gitignore kurang"; exit 1; }
  fi

  if [ "$mode" = "static" ]; then
    [ -f "$tmp/scripts/check_site.py" ] || { echo "  ✗ static: check_site.py kurang"; exit 1; }
  fi

  rm -rf "$tmp"
  echo "  ✓ mode $mode"
done

echo
echo "🎉 Semua uji lulus — template sehat."
