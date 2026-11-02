const CACHE_NAME = "rpg-fichas-v2";
const APP_SHELL = ["/", "/manifest.webmanifest", "/icon.svg"];
const CATALOGS = [
  "/api/arquetipos",
  "/api/origens",
  "/api/poderes-paranormais",
  "/api/catalogo/habilidades",
  "/api/catalogo/rituais",
  "/api/catalogo/armas",
  "/api/catalogo/protecoes",
  "/api/catalogo/modificacoes",
  "/api/catalogo/maldicoes-armas",
  "/api/catalogo/modificacoes-protecoes",
  "/api/catalogo/maldicoes-protecoes",
  "/api/catalogo/inventario/operacionais",
  "/api/catalogo/inventario/acessorios",
  "/api/catalogo/inventario/explosivos",
  "/api/catalogo/inventario/amaldi%C3%A7oados",
  "/api/catalogo/inventario/paranormais",
  "/api/catalogo/inventario/medicamentos",
  "/api/catalogo/inventario/municoes"
];

self.addEventListener("install", event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await cache.addAll(APP_SHELL);
    await Promise.all(CATALOGS.map(async url => {
      try {
        const response = await fetch(url);
        if (response.ok) await cache.put(url, response);
      } catch (error) {
        console.warn(`Catálogo ainda não foi armazenado offline: ${url}`, error);
      }
    }));
    await self.skipWaiting();
  })());
});

self.addEventListener("activate", event => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(names
      .filter(name => name.startsWith("rpg-fichas-") && name !== CACHE_NAME)
      .map(name => caches.delete(name)));
    await self.clients.claim();
  })());
});

self.addEventListener("fetch", event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== "GET" || url.origin !== self.location.origin) return;

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    const isCatalog = url.pathname.startsWith("/api/catalogo/") ||
      ["/api/arquetipos", "/api/origens", "/api/poderes-paranormais"].includes(url.pathname);

    try {
      const response = await fetch(request);
      if (response.ok && (isCatalog || request.mode === "navigate")) {
        await cache.put(isCatalog ? request : "/", response.clone());
      }
      if (response.ok) return response;
      if (isCatalog) return (await cache.match(request)) || response;
      return response;
    } catch (error) {
      if (isCatalog) {
        const cached = await cache.match(request);
        if (cached) return cached;
      }
      if (request.mode === "navigate") {
        const cachedPage = await cache.match("/");
        if (cachedPage) return cachedPage;
      }
      throw error;
    }
  })());
});
