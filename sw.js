/* DiskCat service worker — offline app shell */
const CACHE = 'diskcat-v7';
const ASSETS = ['./', './index.html', './manifest.webmanifest', './icon.svg', './favicon.svg'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const u = new URL(e.request.url);
  if (u.origin !== location.origin) return; // fonts/CDN -> network
  // network-first: always fresh when online, cached copy when offline
  e.respondWith(
    fetch(e.request).then(resp => {
      const cp = resp.clone();
      caches.open(CACHE).then(c => c.put(e.request, cp));
      return resp;
    }).catch(() => caches.match(e.request).then(r => r || caches.match('./index.html')))
  );
});
