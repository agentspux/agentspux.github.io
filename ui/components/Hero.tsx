"use client";

import { useState } from "react";

const INSTALL = "curl -sL get.agentspux.ai/init | bash";

export default function Hero() {
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    await navigator.clipboard.writeText(INSTALL);
    setCopied(true);
    setTimeout(() => setCopied(false), 1400);
  };

  return (
    <section id="install" className="max-w-6xl mx-auto px-6 pt-16 pb-10">
      <div className="max-w-3xl">
        <span className="chip mb-5">✦ open source · mit licensed</span>
        <h1 className="font-serif text-5xl md:text-6xl tracking-tight leading-[1.05] mb-5">
          The agentic toolbox{" "}
          <span className="text-accent">for the rest of us.</span>
        </h1>
        <p className="text-lg text-ink-soft leading-relaxed max-w-2xl mb-8">
          One-click setup for Claude, Cline, MCP, and A2A. No more cryptic
          READMEs. No more dependency hell. Just tools that work.
        </p>

        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={copy}
            className="card flex items-center gap-3 px-4 py-3 hover:bg-paper-sunk"
          >
            <span className="text-accent font-mono text-sm">$</span>
            <code className="font-mono text-sm">{INSTALL}</code>
            <span className="text-xs text-ink-mute ml-2">
              {copied ? "✓ copied" : "click to copy"}
            </span>
          </button>
          <a
            href="https://github.com/agentspux/agentspux.github.io"
            className="btn btn-ghost"
          >
            View on GitHub →
          </a>
        </div>
      </div>
    </section>
  );
}
