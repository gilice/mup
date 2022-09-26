'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "canvaskit/canvaskit.js": "2bc454a691c631b07a9307ac4ca47797",
"canvaskit/profiling/canvaskit.js": "38164e5a72bdad0faa4ce740c9b8e564",
"canvaskit/profiling/canvaskit.wasm": "95a45378b69e77af5ed2bc72b2209b94",
"canvaskit/canvaskit.wasm": "bf50631470eb967688cca13ee181af62",
"main.dart.js": "4846ad135a93bc0a18ffd79d180acf68",
"favicon.ico": "1ffe3fa74668203328fee6d9da56644a",
"assets/AssetManifest.json": "5a3f35769e2238ebb95da1a6ae02f579",
"assets/fonts/DM_Sans/DMSans-Italic.ttf": "1ea925903e098f94f5c51566770a2da8",
"assets/fonts/DM_Sans/DMMono-Regular.ttf": "c6d78233d13e36d83688ac5e6ee0927a",
"assets/fonts/DM_Sans/DMSans-Bold.ttf": "b9cec5212f09838534e6215d1f23ed55",
"assets/fonts/DM_Sans/DMSans-Regular.ttf": "7c217bc9433889f55c38ca9d058514d3",
"assets/fonts/DM_Sans/DMSans-MediumItalic.ttf": "a72ea4b3c89082b9308ef3fcabff9824",
"assets/fonts/DM_Sans/DMSans-BoldItalic.ttf": "f83322c859de9fce83f15d5e6714d78d",
"assets/fonts/DM_Sans/DMMono-Italic.ttf": "596eeeac2092da3b9552929a634c7283",
"assets/fonts/DM_Sans/DMMono-MediumItalic.ttf": "d2a6819d6911798a0c618a9460b8dd5d",
"assets/fonts/DM_Sans/DMMono-Medium.ttf": "e0b4b36de3605fff15634209b7015425",
"assets/fonts/DM_Sans/DMMono-Light.ttf": "7b404c88b96f013e886d78a66a53a77b",
"assets/fonts/DM_Sans/DMSans-Medium.ttf": "24bfda9719b2ba60b94a0f9412757d10",
"assets/fonts/DM_Sans/DMMono-LightItalic.ttf": "dfc01ab380970bf72d3e509ce4dc8cf8",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/shaders/ink_sparkle.frag": "2e20de64bc8fe44f4ba31b8dc3a825bc",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/NOTICES": "6ea1b90b8549bbef62974aae5a47dd89",
"flutter.js": "f85e6fb278b0fd20c349186fb46ae36d",
"index.html": "2cf3b22ed70de50854cde3e800590173",
"/": "2cf3b22ed70de50854cde3e800590173",
"version.json": "58751bd8700c57eae95b39cf95b475f2",
"manifest.json": "0ffd77739b0a90702a559b3ec7604404",
"icons/icon-512.png": "1fdee87548c40289ed844cef358fc9ca",
"icons/icon-512-maskable.png": "5a21ea270736ccc5259160ba00b8499a",
"icons/apple-touch-icon.png": "3ae6eb3f45420f45373aedc34f4380f5",
"icons/icon-192-maskable.png": "ace158d0d2f4bd1534f04a6667aec5df",
"icons/icon-192.png": "854ee80719cbff35e9ae5b2e16fce0ca"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
