<div align="center">

# ▣ AgentSpux

### **Zero-Trust Security for Autonomous AI Agents.**

[![License: MIT](https://img.shields.io/badge/License-MIT-black.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Live-10b981?style=for-the-badge)](https://agentspux.ai)

</div>

---

## What is AgentSpux?

**AgentSpux** is an inline, high-performance virtualization proxy and security gateway built to intercept, sanitize, and govern **MCP tool loops** and **A2A networks** in real time.

It sits between your autonomous agents and the tools they call, inspecting every JSON-RPC invocation before execution — blocking path traversal, prompt injection, and other policy violations at the protocol layer with sub-millisecond overhead.

---

## Core Pillars

- **Inline Stream Sanitization** — a high-throughput data-plane engine built in Go, parsing streams with sub-millisecond latency overhead.
- **Granular RBAC & RLS Policies** — multi-tenant workspace rules, user access roles, and rate limits via an intuitive control plane dashboard.
- **Protocol-Agnostic Design** — native integration for MCP clients (Claude, Cursor) with modular compilation readiness for custom A2A layers.

---

## This Repo

This repository hosts the static marketing site for AgentSpux, served via GitHub Pages at [agentspux.github.io](https://agentspux.github.io/).

```bash
git clone https://github.com/agentspux/agentspux.github.io.git
cd agentspux.github.io
open index.html
```

No build step, no framework — `index.html` is a single static file styled with Tailwind CSS (via CDN).

---

## License

MIT © 2026 AgentSpux.
