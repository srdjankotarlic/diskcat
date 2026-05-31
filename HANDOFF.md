# DiskCat — Technical Handoff

Everything another developer or AI needs to understand, run, change and ship this project.

## 1. What it is
**DiskCat** is a small web app for video / production people to catalog **which storage drive holds the footage from which shoot**, so they can find it instantly. It replaces messy spreadsheets. Audience: camera operators, editors, photographers, small production houses.

- **Live demo (hosted):** https://srdjankotarlic.github.io/diskcat/
- **Repo (public):** https://github.com/srdjankotarlic/diskcat
- **One-file download (release):** https://github.com/srdjankotarlic/diskcat/releases/latest/download/diskcat.html

## 2. Tech stack (intentionally minimal)
- **Pure static front-end:** one `index.html` with inline CSS + vanilla JavaScript. **No build step, no framework, no dependencies, no backend.**
- **Storage:** browser `localStorage` only (key `diskcat.v1`). Nothing is uploaded anywhere.
- **Fonts:** Google Fonts CDN (Inter + JetBrains Mono) with system-font fallbacks.
- **PWA:** `manifest.webmanifest` + `sw.js` (service worker, network-first, offline app shell) → installable / "Add to Home Screen".
- **Hosting:** GitHub Pages (branch `main`, root). Static; any static host works (Netlify, Cloudflare Pages, etc.).

## 3. File structure
```
index.html            # the entire app (markup + <style> + <script>)
manifest.webmanifest  # PWA manifest
sw.js                 # service worker (offline cache, network-first)
icon.svg              # app/home-screen icon — cute cat peeking over a hard drive
favicon.svg           # browser-tab icon — cute cat face (more legible when tiny)
README.md             # user-facing readme
HANDOFF.md            # this file
```
The downloadable single file `diskcat.html` (release asset) is `index.html` with the favicon inlined as a data-URI and the manifest/service-worker links removed, so it works as one standalone file. It is generated from `index.html`; if you change `index.html`, rebuild it (see §7).

## 4. Data model (in `state`, persisted to localStorage)
```js
state = { drives: [], events: [] }

drive = {
  id,            // unique string
  label,         // number / id, e.g. "07" (optional)
  name,          // friendly name, e.g. "Samsung T7" (optional)
  kind,          // 'hdd' | 'ssd' | 'sd' | 'usb' | 'nas' | 'cloud' | 'laptop'
  status,        // 'active' | 'full' | 'archived'
  capacity,      // number or null (total size)
  used,          // number or null (used size)
  capUnit,       // 'TB' | 'GB'
  note, createdAt
}

event = {        // a "shoot" / footage entry
  id,
  name,          // required
  date,          // ISO 'YYYY-MM-DD' or null
  dateDisplay,   // free-text date when approximate (e.g. "~2022"), or null
  approx,        // bool — use dateDisplay instead of date
  driveIds: [],  // array of drive ids the footage is stored on (2+ => "backed up")
  client,        // optional
  tags: [],      // optional array of strings
  stage,         // '' | 'raw' | 'edited' | 'delivered' | 'archived'  (post-production status)
  location, note, createdAt
}
```
`migrate()` backfills missing fields so old saved data keeps working.

## 5. Features
- Drives grid (type icon, capacity fill bar + free space, list of shoots), drive detail, all-footage list, live search.
- **Backup tracking:** an event on 2+ drives shows "✓ backed up"; a top KPI counts shoots **not** backed up.
- **Space overview** KPIs: drives, shoots, not-backed-up, total free space.
- Filters: year chips, client dropdown, "not backed up" toggle, **stage** dropdown; sort by date/name.
- Add/edit/delete drives & events; multi-drive picker (toggle chips) in the event modal.
- Export/Import JSON backup; **CSV export**; **Print** a drive's contents (opens a clean print window).
- Light/Dark theme toggle (persisted in `localStorage` `diskcat.theme`).
- Quick-add from an empty search; keyboard shortcuts (`/` search, `N` new, `Esc` close); in-app Help (`?`).
- Browser back/forward navigation (pushState/popstate); brand logo → home.
- Empty start with a "Load sample data" button.

## 6. How it works (flow)
On load → `load()` reads `localStorage` → `render()` paints the current view. All mutations (save/delete drive or event) update `state`, call `save()` (write localStorage), then `render()`. A single `render()` function recomputes the header KPIs, filters and the active view (drives grid / detail / list / search). No server round-trips.

## 7. Build / run / deploy
- **Run locally:** open `index.html` in a browser (or `python3 -m http.server` in the folder for the PWA/service-worker to work, since SW needs http/https).
- **Deploy:** push to `main`; GitHub Pages serves it. (Any static host works.)
- **Rebuild the single-file release asset** after editing `index.html`:
  ```bash
  python3 - <<'PY'
  import base64,re
  svg=open("favicon.svg","rb").read()
  uri="data:image/svg+xml;base64,"+base64.b64encode(svg).decode()
  h=open("index.html",encoding="utf-8").read()
  h=h.replace('<link rel="icon" href="favicon.svg" type="image/svg+xml">','<link rel="icon" href="'+uri+'" type="image/svg+xml">')
  h=h.replace('<link rel="manifest" href="manifest.webmanifest">\n','')
  h=h.replace('<link rel="apple-touch-icon" href="icon.svg">\n','')
  h=re.sub(r"if\('serviceWorker' in navigator\)\{[^\n]*\}\n?","",h)
  open("diskcat.html","w",encoding="utf-8").write(h)
  PY
  gh release upload v1.0 diskcat.html --clobber   # update the download
  ```

## 8. Ideas / roadmap (not built yet)
- **Phase 2 — shared/team version:** optional Supabase backend (Postgres + realtime) so a team sees & edits the same data via one link, like the author's private sister app. Would add a small config (URL + publishable key) and swap the localStorage layer for Supabase calls, keeping localStorage as offline cache.
- Possible extras: PNG icons for nicer iOS install, multi-language, per-drive last-verified date, drag-reorder.

## 9. License
MIT.
