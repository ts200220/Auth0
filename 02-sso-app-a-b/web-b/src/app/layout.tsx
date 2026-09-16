import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "App B — SSO lab",
  description: "Auth0 × Next.js SSO App B (:3001)",
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
