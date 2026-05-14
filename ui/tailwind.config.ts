import type { Config } from "tailwindcss";

/**
 * Claude / Gemini-inspired palette.
 * Warm off-white surface, soft borders, deep ink text, and a single
 * coral accent for interactive emphasis.
 */
const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        ink:     { DEFAULT: "#1f1d1b", soft: "#3b3936", mute: "#7a7670" },
        paper:   { DEFAULT: "#faf9f6", raised: "#ffffff", sunk: "#f3f1ec" },
        line:    { DEFAULT: "#e7e3dc", strong: "#d8d2c8" },
        accent:  { DEFAULT: "#ff6f3c", soft: "#ffe4d6", deep: "#d8521f" },
        ok:      "#2ea44f",
        warn:    "#d99e00",
        err:     "#d83a2c",
      },
      fontFamily: {
        sans: ['"Inter"', "ui-sans-serif", "system-ui", "sans-serif"],
        mono: ['"JetBrains Mono"', "ui-monospace", "SFMono-Regular", "monospace"],
        serif: ['"Tiempos Text"', "ui-serif", "Georgia", "serif"],
      },
      boxShadow: {
        card:    "0 1px 0 rgba(0,0,0,0.02), 0 4px 14px -8px rgba(0,0,0,0.08)",
        "card-hover": "0 1px 0 rgba(0,0,0,0.02), 0 10px 28px -12px rgba(0,0,0,0.16)",
      },
      borderRadius: {
        xl2: "1.25rem",
      },
    },
  },
  plugins: [],
};
export default config;
