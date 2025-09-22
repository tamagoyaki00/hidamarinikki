const CACHE_NAME = 'hidamarinikki_cache_<%= Time.now.to_i %>';
const urlsToCache = [
  '/',
  '<%= asset_path "application.css" %>',
  '<%= asset_path "application.js" %>',
  '<%= asset_path "icon-192.png" %>',
  '<%= asset_path "icon-512.png" %>',
  '<%= asset_path "clover.png" %>',
  '<%= asset_path "green.png" %>',
  '<%= asset_path "heart.png" %>',
  '<%= asset_path "hidamarinikki.logo.png" %>',
  '<%= asset_path "himawari.svg" %>',
  '<%= asset_path "orange.png" %>',
  '<%= asset_path "red.png" %>',
  '<%= asset_path "star.png" %>'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
  );
});