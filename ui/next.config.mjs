/** @type {import('next').NextConfig} */

// When deploying to GitHub Pages under
//   https://<org>.github.io/<repo>/
// we need a basePath so all assets and links resolve correctly.
//
// In CI we set:   NEXT_PUBLIC_BASE_PATH=/spux-io
// Locally it stays empty so `npm run dev` keeps working at "/".
const basePath = process.env.NEXT_PUBLIC_BASE_PATH || "";

const nextConfig = {
  reactStrictMode: true,

  // Static HTML export — no Node server needed.
  output: "export",

  // GitHub Pages can't rewrite `/foo` → `/foo/index.html`,
  // so emit one folder per route with index.html inside.
  trailingSlash: true,

  // GitHub Pages doesn't run the Next.js Image Optimizer.
  images: { unoptimized: true },

  basePath,
  assetPrefix: basePath || undefined,

  env: {
    NEXT_PUBLIC_BASE_PATH: basePath,
  },
};

export default nextConfig;
