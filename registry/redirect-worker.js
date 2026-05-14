/**
 * SPUX Redirect Worker
 * --------------------
 * Resolves friendly aliases (e.g. `get.agentspux.ai/proxy`) to the raw GitHub
 * URL of the matching script, so users can install with:
 *
 *   curl -sL get.agentspux.ai/proxy | bash
 *
 * Compatible with Cloudflare Workers and Vercel Edge Functions.
 *
 * Deploy on Cloudflare:
 *   wrangler deploy registry/redirect-worker.js
 *
 * Deploy on Vercel: place at `api/[id].js` and adapt to default export.
 */

const REPO_RAW = "https://raw.githubusercontent.com/agentspux/agentspux.github.io/main";
const REGISTRY_URL = `${REPO_RAW}/registry/registry.json`;

let cache = { data: null, fetchedAt: 0 };
const CACHE_TTL_MS = 60_000; // 60s

async function loadRegistry() {
  const now = Date.now();
  if (cache.data && now - cache.fetchedAt < CACHE_TTL_MS) return cache.data;
  const res = await fetch(REGISTRY_URL, { cf: { cacheTtl: 60 } });
  if (!res.ok) throw new Error(`registry fetch failed: ${res.status}`);
  const data = await res.json();
  cache = { data, fetchedAt: now };
  return data;
}

function resolve(registry, id) {
  return (
    registry.official?.[id] ??
    registry.community?.[id] ??
    null
  );
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const id = url.pathname.replace(/^\/+/, "").split("/")[0];

    if (!id || id === "favicon.ico") {
      return new Response("SPUX redirect — try /init or /proxy", { status: 200 });
    }

    let registry;
    try {
      registry = await loadRegistry();
    } catch (e) {
      return new Response(`Registry unavailable: ${e.message}`, { status: 502 });
    }

    const entry = resolve(registry, id);
    if (!entry) {
      return new Response(`Unknown alias: ${id}`, { status: 404 });
    }

    const target = `${REPO_RAW}/${entry.path}`;
    return Response.redirect(target, 302);
  },
};
