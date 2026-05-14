// Local preview of the GitHub Pages build.
// Mirrors production by serving `out/` under the same basePath used in CI.
//
//   npm run preview:pages   →   http://localhost:4000/spux-io/
//
// Useful to catch broken asset paths BEFORE pushing to main.

import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "out");
const BASE = process.env.NEXT_PUBLIC_BASE_PATH || "/spux-io";
const PORT = Number(process.env.PORT || 4000);

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js":   "application/javascript; charset=utf-8",
  ".css":  "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg":  "image/svg+xml",
  ".png":  "image/png",
  ".ico":  "image/x-icon",
  ".woff2":"font/woff2",
  ".txt":  "text/plain; charset=utf-8",
};

if (!fs.existsSync(ROOT)) {
  console.error(`✖  No build found at ${ROOT}`);
  console.error("   Run `npm run build:pages` first.");
  process.exit(1);
}

const server = http.createServer((req, res) => {
  let url = req.url || "/";
  // Redirect "/" → basePath so the dev experience matches Pages.
  if (url === "/") {
    res.writeHead(302, { Location: `${BASE}/` });
    return res.end();
  }
  if (!url.startsWith(BASE)) {
    res.writeHead(404).end(`Not under ${BASE}`);
    return;
  }
  let rel = url.slice(BASE.length) || "/";
  rel = rel.split("?")[0];
  if (rel.endsWith("/")) rel += "index.html";

  const file = path.join(ROOT, rel);
  if (!file.startsWith(ROOT)) {
    return res.writeHead(403).end("Forbidden");
  }
  fs.readFile(file, (err, buf) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain" });
      return res.end(`Not found: ${rel}`);
    }
    res.writeHead(200, { "Content-Type": MIME[path.extname(file)] || "application/octet-stream" });
    res.end(buf);
  });
});

server.listen(PORT, () => {
  console.log(`\n  ✦ SPUX Pages preview\n`);
  console.log(`     → http://localhost:${PORT}${BASE}/\n`);
});
