<div align="center">

```
   ███████╗██████╗ ██╗   ██╗██╗  ██╗
   ██╔════╝██╔══██╗██║   ██║╚██╗██╔╝
   ███████╗██████╔╝██║   ██║ ╚███╔╝
   ╚════██║██╔═══╝ ██║   ██║ ██╔██╗
   ███████║██║     ╚██████╔╝██╔╝ ██╗
   ╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝
```

### **The Agentic Toolbox for the rest of us.**

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Made for Humans](https://img.shields.io/badge/Made_for-Humans-ff6f3c?style=for-the-badge)](https://agentspux.ai)
[![Open Source](https://img.shields.io/badge/Open-Source-2ea44f?style=for-the-badge)](https://github.com/agentspux/agentspux.github.io)

</div>

---

## ✨ What is SPUX?

**SPUX** is an open-source, community-driven repository that gives non-technical users **one-click access** to the agentic AI revolution. No more decoding cryptic READMEs. No more fighting Python versions. No more "works-on-my-machine."

If a task takes more than one command, SPUX wraps it.

```bash
curl -sL get.agentspux.ai/init | bash
```

That's it. You're set up.

---

## 🚀 Run SPUX Locally (this repo)

This repo has **two runnable surfaces** — the shell tooling and the dashboard UI. You can use either independently.

### 1. Shell tooling (no install required)

```bash
# from the repo root
bash spux-init.sh                       # first-time setup (idempotent)
bash core/engine.sh status              # see what's connected
bash core/validate.sh scripts/*.sh      # security-audit every script
bash scripts/cline-anthropic-proxy.sh   # install Cline + SF Bedrock proxy
```

Every script wears the same premium UI from `.spux-utils/ui.sh` (boxed
headers, progress bars, success emojis, sudo prompts).

### 2. Dashboard UI (Next.js)

```bash
cd ui
npm install        # one-time
npm run dev        # → http://localhost:3000
```

For a Pages-shaped production preview:

```bash
cd ui
npm run build:pages       # static export under /spux-io
npm run preview:pages     # → http://localhost:4000/spux-io/
```

The dashboard reads its tool catalog from `ui/lib/tools.ts` (which mirrors
`registry/registry.json`). To add a new card, append an entry to both files.

### 3. Run a single tool by alias (once `get.agentspux.ai` is live)

```bash
curl -sL get.agentspux.ai/init                    | bash
curl -sL get.agentspux.ai/cline-anthropic-proxy   | bash
curl -sL get.agentspux.ai/vscode-setup            | bash
```

The redirect logic lives in `registry/worker.js` (Cloudflare Worker) and
resolves friendly IDs from `registry/registry.json` to the raw GitHub URLs.

---

## 🌐 Deploying the Dashboard to GitHub Pages

The UI is a **fully-static Next.js export** — no Node server needed in
production. It can be hosted free on **GitHub Pages**.

The deploy workflow **auto-detects** which kind of Pages target it's in, so
you can pick whichever URL shape you prefer.

### Option A — Organization Pages (recommended)  → `https://agentspux.github.io/`

Cleanest URL, served from the root of the org domain. Requires a repo named
**exactly** `<org>.github.io`.

```bash
# 1. Create the special repo under your org
gh repo create agentspux/agentspux.github.io --public --source=. --push

# 2. In github.com/agentspux/agentspux.github.io → Settings → Pages
#    Source: "GitHub Actions"

# 3. Done. Live at https://agentspux.github.io/
```

### Option B — Project Pages  → `https://agentspux.github.io/spux-io/`

Useful if you want this repo under its own subpath alongside other org repos.

```bash
gh repo create agentspux/spux-io --public --source=. --push
# Then: Settings → Pages → Source: "GitHub Actions"
# Live at https://agentspux.github.io/spux-io/
```

### How the auto-detection works

`.github/workflows/deploy-pages.yml` inspects `$GITHUB_REPOSITORY` at build time:

| Repo name                     | Detected as    | `basePath`  | Final URL                                  |
|-------------------------------|----------------|-------------|--------------------------------------------|
| `agentspux.github.io`         | Org Pages      | *(empty)*   | `https://agentspux.github.io/`             |
| `spux-io` (or any other name) | Project Pages  | `/spux-io`  | `https://agentspux.github.io/spux-io/`     |

You don't have to edit any config — the workflow figures it out.

### Preview the Pages build locally

Mirror the project-Pages shape exactly before pushing:

```bash
cd ui
npm run build:pages       # builds with NEXT_PUBLIC_BASE_PATH=/spux-io
npm run preview:pages     # serves at http://localhost:4000/spux-io/
```

For an Org-Pages preview (no basePath):

```bash
cd ui
NEXT_PUBLIC_BASE_PATH= npm run build      # empty basePath
npx serve out                              # → http://localhost:3000/
```

### How the static export works

- `next.config.mjs` sets `output: "export"` → emits a plain `out/` folder of
  HTML/CSS/JS, no Node runtime required.
- `basePath` is derived from `NEXT_PUBLIC_BASE_PATH` so every link and asset
  resolves correctly under whichever URL Pages serves from.
- `out/.nojekyll` tells Pages **not** to strip the `_next/` folder.
- `trailingSlash: true` makes every route a `/foo/index.html` file, since
  Pages doesn't do server-side rewrites.

### Custom domain (optional)  → `https://agentspux.ai`

1. Add `agentspux.ai` to a file at `ui/public/CNAME` (one line, no protocol).
2. Point your DNS at GitHub Pages — `A` records to `185.199.108–111.153`,
   plus a `CNAME` for `www`.
3. In **Settings → Pages**, set the custom domain to `agentspux.ai` and
   tick **Enforce HTTPS**.
4. Use the **Org Pages** repo so the basePath stays empty.

---

## 🎯 Who is this for?

- **Researchers** who want to wire up Claude/GPT/Gemini without learning Docker.
- **Students** who want to experiment with MCP, A2A, and agent orchestration.
- **Power users** who'd rather *use* AI than *babysit* it.
- **Developers** who want a clean, vetted registry of automation scripts.

---

## 🚀 Quick Start

### Initialize SPUX

```bash
curl -sL get.agentspux.ai/init | bash
```

This installs:
- ✅ VSCode (if missing) + the Cline extension
- ✅ A local `~/.spux/` config directory
- ✅ The `spux` CLI for running scripts by alias

### Run any tool by alias

```bash
spux run proxy          # Configure a local proxy
spux run vscode-setup   # Install curated extensions
spux run llm-connect    # Wire up your API keys
```

Or directly:

```bash
curl -sL get.agentspux.ai/proxy | bash
```

---

## 🧱 Architecture

```
SPUX/
├── .github/         # CI workflows + script validation
├── core/            # SPUX-Engine: env detection & setup
├── registry/        # registry.json — alias → script URL
├── scripts/         # Verified official scripts
├── community/       # Sandboxed user submissions
├── specs/           # A2A protocol + MCP node templates
├── ui/              # Next.js + Tailwind dashboard
├── .spux-utils/     # Shared shell helpers (UI consistency)
└── spux-init.sh     # The flagship initializer
```

---

## 🪄 Core Concepts

### 1. The Registry
A simple `registry.json` maps friendly aliases to raw script URLs:

```json
{ "proxy": "scripts/proxy-setup.sh", "llm-connect": "scripts/llm-connect.sh" }
```

A redirect worker (Vercel/Cloudflare) at `get.agentspux.ai/[id]` resolves each alias to a raw GitHub URL — keeping install commands short and memorable.

### 2. The SPUX Manifest
Every script declares itself:

```bash
# <SPUX_MANIFEST>
# ID: proxy
# Title: Local Proxy Setup
# Author: rarnado
# Description: Configures a local HTTP/HTTPS proxy for development.
# Platform: macOS | Linux
# </SPUX_MANIFEST>
```

This metadata powers the UI's **Tool Store**.

### 3. A2A & MCP
- **A2A Bridge** — a YAML spec for Agent-to-Agent handshakes (`specs/a2a/`).
- **MCP Hub** — pluggable Model Context Protocol configs (`specs/mcp/`).

Toggle these on from the dashboard to instantly extend your LLM's reach.

---

## 🛡️ Safety First

- 🔍 **Automated audits** — every community script is regex-scanned for malicious patterns.
- 🤖 **AI logic review** — suspicious flow control gets flagged for human review.
- 🧑‍⚖️ **Human-in-the-loop** — `sudo` and system-directory writes always prompt the user.
- 📜 **MIT licensed** — fork, remix, ship.

---

## 🎨 The UI

A **Next.js + Tailwind** dashboard inspired by the calm minimalism of Claude, Slack, and Gemini. Browse tools as cards, click ▶ to copy/run, and watch live status indicators for VSCode, your LLM connections, and proxies.

```bash
cd ui && pnpm install && pnpm dev
```

Open <http://localhost:3000>.

---

## 🤝 Contributing

1. Drop your script in `community/<your-handle>/`.
2. Add the `SPUX_MANIFEST` header.
3. Open a PR — CI runs the security audit automatically.
4. Once merged, your script gets a registry alias.

See [`community/README.md`](community/README.md) for the full template.

---

## 📜 License

MIT © 2026 Ray Arnado & SPUX contributors.

<div align="center">

**Built for the rest of us.**

</div>
