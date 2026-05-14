"use client";

import { useState } from "react";

type State = "ok" | "warn" | "err" | "mute";

interface Item {
  label: string;
  state: State;
  detail: string;
}

const INITIAL: Item[] = [
  { label: "VSCode",     state: "ok",   detail: "1.92 · /usr/local/bin/code" },
  { label: "Cline",      state: "ok",   detail: "saoudrizwan.claude-dev v3.4" },
  { label: "spux CLI",   state: "ok",   detail: "v0.1.0" },
  { label: "Anthropic",  state: "ok",   detail: "ANTHROPIC_API_KEY set" },
  { label: "OpenAI",     state: "warn", detail: "Key not set" },
  { label: "Gemini",     state: "mute", detail: "Skipped" },
  { label: "Proxy",      state: "ok",   detail: "http://127.0.0.1:8080" },
];

export default function StatusMonitor() {
  const [items] = useState<Item[]>(INITIAL);

  return (
    <aside className="card p-5">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-sm font-semibold tracking-tight">Status</h2>
        <span className="text-xs text-ink-mute">live · mocked</span>
      </div>
      <ul className="space-y-3">
        {items.map((it) => (
          <li key={it.label} className="flex items-start gap-3">
            <span className={`dot dot-${it.state} mt-1.5`} aria-hidden />
            <div className="flex-1 min-w-0">
              <div className="text-sm font-medium">{it.label}</div>
              <div className="text-xs text-ink-mute truncate">{it.detail}</div>
            </div>
          </li>
        ))}
      </ul>
      <div className="mt-5 pt-4 border-t border-line text-xs text-ink-mute">
        Backed by <code className="font-mono">core/engine.sh status --json</code>
      </div>
    </aside>
  );
}
