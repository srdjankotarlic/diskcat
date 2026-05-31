# 📀 DiskCat

**A simple, free catalog for video & production people — track which drive holds the footage from which shoot, and find it in seconds.**

No signup. No install required. Works offline. Your data stays in your browser.

### 👉 Live app: https://srdjankotarlic.github.io/diskcat/

![DiskCat](icon.svg)

---

## Why
If you shoot video, you know the pain: footage spread across dozens of drives, SD cards and laptops, and no idea *which one* a past shoot is on. DiskCat is a clean little catalog so you always know.

## Features
- **Drives & locations** — HDD, SSD, SD/CF cards, USB, NAS, cloud, laptop (each with its own icon)
- **Log shoots** — name, date (exact or approximate), client/project, tags, location, notes
- **Backup tracking** — mark a shoot as stored on *multiple* drives → it shows a **✓ backed up** badge, and a counter shows how many shoots are **not** backed up yet
- **Instant search** — find a shoot by name, client, tag or year and see exactly which drive(s) it's on
- **Capacity & free space** — set each drive's size; see fill bars and a total **free space** overview ("where do I have room?")
- **Works offline (PWA)** — open it once, then add it to your home screen and use it without internet
- **Export / Import** — one-click JSON backup you fully control

## How to use it (3 ways)
1. **Just open the link** → [open DiskCat](https://srdjankotarlic.github.io/diskcat/). It works immediately; your data is saved in your browser.
   - On a phone: open the link → browser menu → **Add to Home Screen**. Now it behaves like an installed app.
2. **Download a copy** → grab `index.html` from this repo and double-click it. Runs locally, even offline.
3. **Host your own** → it's plain static files (`index.html`, `manifest.webmanifest`, `sw.js`, `icon.svg`). Drop them on any free host (Netlify, Cloudflare Pages, GitHub Pages).

## Data & privacy
All data lives in your browser's `localStorage` — nothing is uploaded anywhere. Use **Export** now and then to keep a backup file. To move to another device, Export on one and Import on the other.

> Want a **shared, live version** for a team (everyone with a link sees & edits the same data)? That's a small optional add-on with a free Supabase backend — open an issue and I'll add a guide.

## License
MIT — free to use, modify and share.
