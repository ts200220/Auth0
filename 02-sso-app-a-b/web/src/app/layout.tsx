import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "App A — SSO lab",
  description: "Auth0 × Next.js SSO App A (:3000)",
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
