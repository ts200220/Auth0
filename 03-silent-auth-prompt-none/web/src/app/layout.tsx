import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "03 Silent Auth (prompt=none)",
  description: "Auth0 × Next.js silent authentication lab",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}
