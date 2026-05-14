"use client";

import { useState } from "react";
import type { Tool } from "@/lib/tools";

interface Props { tool: Tool; }

export default function ToolCard({ tool }: Props) {
  const [copied, setCopied] = useState(false);
  const cmd = `curl -sL get.agentspux.ai/${tool.id} | bash`;

  const copy = async () => {
    await navigator.clipboard.writeText(cmd);
    setCopied(true);
    setTimeout(() => setCopied(false), 1400);
  };

  return (
    <article className="card p-5 flex flex-col h-full">
      <header className="flex items-start gap-3 mb-3">
        <div
          className="h-10 w-10 rounded-xl bg-paper-sunk border border-line
                     flex items-center justify-center text-lg shrink-0"
          aria-hidden
        >
          {tool.icon}
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="text-sm font-semibold tracking-tight truncate">
            {tool.title}
          </h3>
          <p className="text-xs text-ink-mute">
            by {tool.author}
            {tool.verified && (
              <span className="ml-2 text-ok">✓ verified</span>
            )}
          </p>
        </div>
      </header>

      <p className="text-sm text-ink-soft leading-relaxed mb-4 flex-1">
        {tool.description}
      </p>

      <div className="flex flex-wrap gap-1.5 mb-4">
        {tool.platform.map((p) => (
          <span key={p} className="chip">{p}</span>
        ))}
      </div>

      <div className="flex items-center gap-2">
        <button
          onClick={copy}
          className="btn btn-ghost flex-1 justify-center"
          aria-label={`Copy install command for ${tool.title}`}
        >
          <span className="font-mono text-xs truncate">
            {copied ? "✓ copied" : cmd}
          </span>
        </button>
        <button
          className="btn btn-accent"
          aria-label={`Run ${tool.title}`}
          title="Run via local SPUX agent"
        >
          ▶
        </button>
      </div>
    </article>
  );
}
