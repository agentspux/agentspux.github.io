"use client";

import { useMemo, useState } from "react";
import Header from "@/components/Header";
import Hero from "@/components/Hero";
import ToolCard from "@/components/ToolCard";
import StatusMonitor from "@/components/StatusMonitor";
import { TOOLS, CATEGORIES, type Tool } from "@/lib/tools";

export default function Page() {
  const [query, setQuery] = useState("");
  const [cat, setCat] = useState<Tool["category"] | "all">("all");

  const filtered = useMemo(() => {
    return TOOLS.filter((t) => {
      const matchCat = cat === "all" || t.category === cat;
      const q = query.trim().toLowerCase();
      const matchQ =
        !q ||
        t.title.toLowerCase().includes(q) ||
        t.description.toLowerCase().includes(q) ||
        t.id.toLowerCase().includes(q);
      return matchCat && matchQ;
    });
  }, [query, cat]);

  return (
    <>
      <Header />
      <Hero />

      <main className="max-w-6xl mx-auto px-6 pb-24 grid lg:grid-cols-[1fr_300px] gap-8">
        <section id="tools">
          {/* Search + filters */}
          <div className="flex flex-col sm:flex-row gap-3 mb-6">
            <div className="relative flex-1">
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search tools…"
                className="w-full bg-paper-raised border border-line rounded-full
                           pl-10 pr-4 py-2.5 text-sm placeholder:text-ink-mute
                           focus:outline-none focus:ring-2 focus:ring-accent"
              />
              <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-ink-mute text-sm">
                ⌕
              </span>
            </div>
            <div className="flex flex-wrap gap-1.5">
              <button
                onClick={() => setCat("all")}
                className={`btn ${cat === "all" ? "btn-primary" : "btn-ghost"}`}
              >
                All
              </button>
              {CATEGORIES.map((c) => (
                <button
                  key={c.id}
                  onClick={() => setCat(c.id)}
                  className={`btn ${cat === c.id ? "btn-primary" : "btn-ghost"}`}
                >
                  {c.label}
                </button>
              ))}
            </div>
          </div>

          {/* Grid */}
          {filtered.length > 0 ? (
            <div className="grid sm:grid-cols-2 gap-4">
              {filtered.map((t) => (
                <ToolCard key={t.id} tool={t} />
              ))}
            </div>
          ) : (
            <div className="card p-10 text-center text-ink-mute">
              No tools match “{query}”.
            </div>
          )}
        </section>

        <div id="status" className="lg:sticky lg:top-20 lg:self-start">
          <StatusMonitor />
        </div>
      </main>

      <footer className="border-t border-line">
        <div className="max-w-6xl mx-auto px-6 py-8 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-ink-mute">
          <div>
            © 2026 SPUX · MIT Licensed · Built with ♥ for the rest of us.
          </div>
          <div className="flex gap-4">
            <a className="hover:text-ink" href="#tools">Tools</a>
            <a className="hover:text-ink" href="https://github.com/agentspux/agentspux.github.io">GitHub</a>
            <a className="hover:text-ink" href="/community">Contribute</a>
          </div>
        </div>
      </footer>
    </>
  );
}
