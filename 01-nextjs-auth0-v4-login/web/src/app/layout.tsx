import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "01-nextjs-auth0-v4-login",
  description: "Auth0 × Next.js login lab",
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
