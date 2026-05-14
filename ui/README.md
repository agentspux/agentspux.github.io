# SPUX UI

The Claude / Gemini-inspired dashboard for browsing and launching SPUX tools.

## Stack
- **Next.js 14** (App Router)
- **Tailwind CSS** with a custom warm-paper palette + coral accent
- **TypeScript**, fully typed
- Zero asset files — emojis as iconography (intentional, keeps bundle tiny)

## Develop

```bash
cd ui
pnpm install   # or: npm install
pnpm dev
```

Open <http://localhost:3000>.

## Pages & components

```
app/
├── layout.tsx        # root shell, fonts, global background
├── globals.css       # Tailwind layers + tokens
└── page.tsx          # dashboard: hero + tool grid + status sidebar
components/
├── Header.tsx        # sticky nav
├── Hero.tsx          # tagline + click-to-copy install command
├── ToolCard.tsx      # Slack/Linear-style tool card
└── StatusMonitor.tsx # live status of VSCode / Cline / proxy / providers
lib/
└── tools.ts          # static catalog (mirrors registry.json)
```

## Status monitor (real data)

The `StatusMonitor` currently renders mocked items. To wire it up to the
local SPUX engine, expose a tiny route that runs:

```bash
core/engine.sh status --json
```

…and have the component poll `/api/status` every 5–10 seconds.

## Design tokens

| Token             | Value     | Use                          |
| ----------------- | --------- | ---------------------------- |
| `paper`           | `#faf9f6` | App background               |
| `paper-raised`    | `#ffffff` | Cards, inputs                |
| `paper-sunk`      | `#f3f1ec` | Hover, code blocks           |
| `ink`             | `#1f1d1b` | Primary text                 |
| `ink-soft`        | `#3b3936` | Secondary text               |
| `ink-mute`        | `#7a7670` | Tertiary / metadata          |
| `accent`          | `#ff6f3c` | CTAs, accents (Claude coral) |
| `line`            | `#e7e3dc` | Borders                      |

## Build

```bash
pnpm build
pnpm start
```
