export default function Header() {
  return (
    <header className="border-b border-line bg-paper/80 backdrop-blur sticky top-0 z-20">
      <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className="h-7 w-7 rounded-lg bg-ink text-paper grid place-items-center font-serif text-sm">
            S
          </div>
          <div className="leading-tight">
            <div className="text-sm font-semibold tracking-tight">SPUX</div>
            <div className="text-[10px] text-ink-mute -mt-0.5">
              The Agentic Toolbox
            </div>
          </div>
        </div>

        <nav className="flex items-center gap-1 text-sm">
          <a className="btn btn-ghost" href="#tools">Tools</a>
          <a className="btn btn-ghost" href="#status">Status</a>
          <a className="btn btn-ghost" href="https://github.com/agentspux/agentspux.github.io">
            GitHub
          </a>
          <a className="btn btn-primary ml-2" href="#install">Get SPUX</a>
        </nav>
      </div>
    </header>
  );
}
