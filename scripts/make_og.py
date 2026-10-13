#!/usr/bin/env python3
"""
make_og.py — pembuat kartu sosial (og:image 1200×630) untuk semua situsmu.

Konfigurasi dibaca dari berkas `og.json` di root repo:

    [
      {
        "slug": "",                                  ← "" = situs utama (mis. user.github.io)
        "title": "Namamu",
        "subtitle": "Web Developer — React · TypeScript",
        "accent": "#a78bfa",
        "label": "Indonesia"                          ← opsional, teks kecil kiri-bawah
      },
      {
        "slug": "cryptoku",
        "title": "CryptoKu",
        "subtitle": "Pantau harga kripto real-time dalam Rupiah",
        "accent": "#f7b955"
      }
    ]

Pakai:
    python3 scripts/make_og.py --init     # buat og.json contoh
    python3 scripts/make_og.py            # hasil ke folder ./og
    python3 scripts/make_og.py --out og   # ganti folder keluaran

Hasil dipakai pada tag <meta property="og:image"> di index.html
(lihat templates/og-meta-snippet.html). Satu-satunya dependensi: Pillow.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

W, H = 1200, 630

FONT_DIR = Path("/usr/share/fonts/truetype/dejavu")
FONT_BOLD = FONT_DIR / "DejaVuSans-Bold.ttf"
FONT_REG = FONT_DIR / "DejaVuSans.ttf"

CONTOH = [
    {
        "slug": "",
        "title": "Namamu",
        "subtitle": "Web Developer — React · TypeScript · Node.js",
        "accent": "#a78bfa",
        "label": "Indonesia",
    },
    {
        "slug": "cryptoku",
        "title": "CryptoKu",
        "subtitle": "Pantau harga kripto secara real-time dalam Rupiah",
        "accent": "#f7b955",
    },
]


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(str(path), size)
    except OSError:
        return ImageFont.load_default()


def hex_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", (1, h))
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        px[0, y] = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return img.resize((w, h))


def wrap(draw: ImageDraw.ImageDraw, text: str, f: ImageFont.FreeTypeFont, max_w: int) -> list[str]:
    words, lines, cur = text.split(), [], ""
    for word in words:
        uji = f"{cur} {word}".strip()
        if draw.textlength(uji, font=f) <= max_w:
            cur = uji
        else:
            if cur:
                lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def buat_kartu(judul: str, sub: str, aksen: str, url: str, label: str, tujuan: Path) -> None:
    base = gradient((W, H), (10, 9, 22), (32, 18, 62))
    img = base.convert("RGBA")
    draw = ImageDraw.Draw(img)

    acc = hex_rgb(aksen)

    # lingkaran cahaya aksen
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([W - 520, -260, W + 260, 520], fill=(*acc, 38))
    gd.ellipse([-260, H - 320, 420, H + 240], fill=(*acc, 24))
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    # garis aksen kiri
    draw.rounded_rectangle([0, 0, 14, H], radius=0, fill=(*acc, 255))

    # judul
    f_judul = font(FONT_BOLD, 86 if len(judul) <= 14 else 68)
    draw.text((86, 150), judul, font=f_judul, fill=(255, 255, 255))

    # garis bawah judul
    draw.rounded_rectangle([88, 268, 88 + 132, 276], radius=4, fill=(*acc, 255))

    # subjudul
    f_sub = font(FONT_REG, 34)
    y = 318
    for line in wrap(draw, sub, f_sub, W - 200)[:3]:
        draw.text((88, y), line, font=f_sub, fill=(226, 220, 245))
        y += 48

    # label kecil di bawah (opsional)
    if label:
        f_kecil = font(FONT_BOLD, 26)
        draw.text((88, H - 116), label, font=f_kecil, fill=(*acc, 255))

    # url
    f_url = font(FONT_REG, 26)
    draw.text((88, H - 72), url, font=f_url, fill=(160, 152, 190))

    img.convert("RGB").save(tujuan, format="PNG", optimize=True)
    print(f"  ✓ {tujuan.name}")


def baca_konfigurasi(root: Path) -> list[dict]:
    cfg_path = root / "og.json"
    if not cfg_path.exists():
        print(f"✗ {cfg_path} tidak ditemukan.\n  Buat dulu dengan:  python3 scripts/make_og.py --init")
        sys.exit(1)
    try:
        data = json.loads(cfg_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"✗ og.json bukan JSON yang valid: {e}")
        sys.exit(1)
    if not isinstance(data, list) or not data:
        print("✗ og.json harus berisi daftar (array) objek situs — lihat contoh di --init")
        sys.exit(1)
    return data


def main() -> int:
    ap = argparse.ArgumentParser(description="Pembuat kartu sosial 1200×630.")
    ap.add_argument("--out", default="og", help="folder keluaran (default: og)")
    ap.add_argument("--init", action="store_true", help="tulis og.json contoh lalu keluar")
    ap.add_argument("--base-url", default="", help="domain dasar untuk teks URL di kartu, mis. nama.github.io")
    args = ap.parse_args()

    root = Path(__file__).resolve().parents[1]

    if args.init:
        tujuan = root / "og.json"
        if tujuan.exists():
            print(f"! {tujuan} sudah ada — tidak ditimpa.")
            return 0
        tujuan.write_text(json.dumps(CONTOH, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"✓ Contoh konfigurasi ditulis ke {tujuan}. Sunting sesuai situsmu, lalu jalankan tanpa --init.")
        return 0

    situs = baca_konfigurasi(root)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    print(f"Membuat {len(situs)} kartu sosial di {out}/ …")

    preview_dari: Path | None = None
    for s in situs:
        slug = str(s.get("slug", "")).strip("/")
        judul = s.get("title") or "Tanpa Judul"
        sub = s.get("subtitle", "")
        aksen = s.get("accent", "#a78bfa")
        label = s.get("label", "React · TypeScript · Tailwind")

        if s.get("url"):
            url = str(s["url"])
        elif args.base_url:
            url = f"{args.base_url.rstrip('/')}/{slug}" if slug else args.base_url.rstrip("/")
        else:
            url = f"{slug}/" if slug else ""

        nama = f"og-{slug or 'utama'}.png"
        tujuan = out / nama
        buat_kartu(judul, sub, aksen, url, label, tujuan)

        # kartu situs utama juga dipakai sebagai social preview GitHub (rasio 2:1)
        if slug == "":
            preview_dari = tujuan

    if preview_dari:
        img = Image.open(preview_dari).resize((1280, 640))
        img.save(out / "github-social-preview.png", format="PNG", optimize=True)
        print("  ✓ github-social-preview.png (unggah di Settings → Social preview)")

    print("Selesai. Pasang lewat tag og:image (lihat templates/og-meta-snippet.html).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
