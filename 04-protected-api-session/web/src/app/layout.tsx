import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "04-protected-api-session",
  description: "Auth0 × Next.js protected API (session) lab",
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
