// Static tool catalog — in production this would be hydrated from
// /registry/registry.json at build time.

export type Platform = "macOS" | "Linux" | "Windows";

export interface Tool {
  id: string;
  title: string;
  description: string;
  platform: Platform[];
  category: "setup" | "providers" | "network" | "agents" | "context";
  icon: string;            // emoji — keeps zero-asset bundle
  verified: boolean;
  author: string;
}

export const TOOLS: Tool[] = [
  {
    id: "init",
    title: "SPUX Initializer",
    description: "First-time setup: VSCode, Cline, ~/.spux config, and the spux CLI.",
    platform: ["macOS", "Linux"],
    category: "setup",
    icon: "✦",
    verified: true,
    author: "spux",
  },
  {
    id: "vscode-setup",
    title: "VSCode Power-User Setup",
    description: "Curated extension bundle for AI + agentic workflows.",
    platform: ["macOS", "Linux", "Windows"],
    category: "setup",
    icon: "🧩",
    verified: true,
    author: "spux",
  },
  {
    id: "llm-connect",
    title: "LLM Provider Connector",
    description: "Securely store API keys for Claude, OpenAI, and Gemini.",
    platform: ["macOS", "Linux"],
    category: "providers",
    icon: "🔑",
    verified: true,
    author: "spux",
  },
  {
    id: "proxy",
    title: "Local Proxy Setup",
    description: "Wire shell, git, and npm to a development HTTP/HTTPS proxy.",
    platform: ["macOS", "Linux"],
    category: "network",
    icon: "🌐",
    verified: true,
    author: "spux",
  },
  {
    id: "cline-anthropic-proxy",
    title: "Cline + Anthropic (SF Bedrock Proxy)",
    description:
      "Installs VSCode + Cline and wires it to Claude via a local Salesforce Bedrock proxy on :9999.",
    platform: ["macOS"],
    category: "setup",
    icon: "🤖",
    verified: true,
    author: "rarnado",
  },
  {
    id: "research-delegate",
    title: "A2A · Research Delegate",
    description: "Let Cline delegate web-research subtasks to a Secondary agent.",
    platform: ["macOS", "Linux", "Windows"],
    category: "agents",
    icon: "🤝",
    verified: true,
    author: "spux",
  },
  {
    id: "filesystem-readonly",
    title: "MCP · Filesystem (Read-only)",
    description: "Give your LLM read-only context over a chosen project folder.",
    platform: ["macOS", "Linux", "Windows"],
    category: "context",
    icon: "📁",
    verified: true,
    author: "spux",
  },
];

export const CATEGORIES: { id: Tool["category"]; label: string }[] = [
  { id: "setup",     label: "Setup" },
  { id: "providers", label: "Providers" },
  { id: "network",   label: "Network" },
  { id: "agents",    label: "Agents (A2A)" },
  { id: "context",   label: "Context (MCP)" },
];
