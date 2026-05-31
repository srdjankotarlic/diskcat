# 📀 DiskCat

**Know which drive your footage is on — instantly.**

A free, offline-first tool for video & production people to catalog which storage drive holds the footage from each shoot. No signup is needed for local use, and optional cloud sync uses your own Supabase project.

### ▶️ Use it now: https://srdjankotarlic.github.io/diskcat/

<img src="favicon.svg" width="96" alt="DiskCat">

---

## The problem it solves
Footage piles up across dozens of drives, SD cards and laptops — and six months later, *which one* was that shoot on? DiskCat is a tiny, searchable catalog so you always know — and whether it's backed up.

## How to use it — 3 steps
1. **Add your drives** — click **Add drive**: pick the type (HDD, SSD, SD card, USB, NAS, cloud, laptop), give it a number/name, and (optionally) its size.
2. **Log your shoots** — click **＋ New entry**: name, date, and tick **which drive(s)** it's on. Optionally add client, tags, or stage (raw / edited / delivered).
3. **Find anything** — type in the **search** (shoot, client, tag, year) and instantly see which drive(s) it's on. Or browse **Drives** to see what's on each.

That's the whole app — it's meant to be obvious. Open it and you'll get it in 30 seconds (there's a **?** help button in the corner too).

## Get it / install — pick one (all easy)
- **Just open the link** → https://srdjankotarlic.github.io/diskcat/ — works immediately.
- **Make it an app** → in Chrome/Edge on **Windows or Mac**, click **“Install app”** in the address bar; on a **phone**, use **Add to Home Screen**. One click, no App Store installer, works offline.
- **Download one file** → grab **[`diskcat.html`](https://github.com/srdjankotarlic/diskcat/releases/latest/download/diskcat.html)** and double-click it. The whole app is that single file.

Local mode needs no accounts and no setup. Cloud sync is optional and self-owned.

## What it does
- 🗂️ **Drives of every kind** — HDD, SSD, SD/CF card, USB, NAS, cloud, laptop (each with its own icon)
- 🔎 **Instant search** — find a shoot and see which drive(s) hold it
- ✅ **Backup tracking** — footage saved on 2+ drives shows **✓ backed up**; a counter shows how many shoots are **not** backed up yet
- 📊 **Space overview** — capacity bars per drive + total **free space** across everything
- 🏷️ **Clients, tags & stage** — group and filter (raw / edited / delivered / archived)
- 🔗 **Share via link** — hand your whole list to a colleague with one link (they get an editable copy)
- ☁️ **Self-owned cloud sync** — use your own Supabase project for owner/editor/viewer roles and public read-only links
- 🧭 **Guided setup** — Cloud sync includes Copy SQL, Test connection, archive ID copy, and Last synced status
- 💾 **Export / Import / CSV / Print** — back up, move between devices, open in Excel, or print a drive's contents for a physical label
- 🌗 **Light & dark theme**, ⌨️ shortcuts (`/` search, `N` new entry), 📴 **works offline**

## Sharing & cloud
- **Now (local):** click **Share** → you get a link that contains a copy of your archive. Send it to someone; they open it and get an editable copy. It's a snapshot — their edits stay theirs, yours stay yours.
- **Optional cloud mode:** click **Cloud sync** and connect your own Supabase project. DiskCat does not host your cloud data. The person/company that creates the Supabase project owns and maintains that data.
- **Read-only without account:** owners can create a public read-only cloud link. Viewers can search and open drives without signing in, but cannot edit.
- **Team editing:** owners can create viewer/editor invite links. Invited people sign in to the archive owner's Supabase project.

Full setup: [docs/CLOUD_SETUP.md](docs/CLOUD_SETUP.md)

## Your data & privacy
In local mode, everything is stored **in your browser only**. In cloud mode, data is uploaded only to the Supabase project you entered in **Cloud sync**. The public DiskCat app ships without a default database, so the maintainer is not storing other people's archives.

Click **Export** now and then to keep a backup file. To move without cloud: **Export** on one device, **Import** on the other.

## Roadmap (planned)
- 🌍 Multiple languages
- 🗓️ Per-drive “last verified” date and simple reports

*Want one of these sooner? [Open an issue](https://github.com/srdjankotarlic/diskcat/issues).*

## Make it your own (open source)
DiskCat is **one `index.html` file** — plain HTML / CSS / JavaScript, **no build step**. Optional cloud sync loads the public Supabase browser SDK from a CDN. So it's easy to change:
1. **Fork** the repo (or download `index.html`).
2. Open it in any code editor, tweak, and refresh the page to see changes.
3. Easy things you can add yourself: extra storage types or stages, your studio's name/logo, more fields, different colors.

Pull requests are welcome. **MIT license** — free to use, modify and share.

---
Built for editors, shooters, photographers and live-production folks. If it saves you one frantic drive-hunt, it did its job. 🎬
