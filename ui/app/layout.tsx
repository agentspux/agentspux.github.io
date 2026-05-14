import "./globals.css";
import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "SPUX — The Agentic Toolbox for the rest of us",
  description:
    "An open-source registry of one-click automation scripts for non-technical users.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen">
        <div className="relative z-10">{children}</div>
      </body>
    </html>
  );
}
