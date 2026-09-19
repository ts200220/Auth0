import type { NextRequest } from "next/server";
import { NextResponse } from "next/server";
import { auth0 } from "./lib/auth0";

/**
 * APP_BASE_URL が auth0-lab.local なのに localhost で /auth/login すると、
 * __txn_ Cookie は localhost に付き、Callback は lab.local → invalid_state になる。
 * その取り違えを防ぐため、ベース URL のホストへ寄せる。
 */
function redirectToConfiguredHost(request: NextRequest): NextResponse | null {
  const base = process.env.APP_BASE_URL;
  if (!base) return null;

  let configured: URL;
  try {
    configured = new URL(base);
  } catch {
    return null;
  }

  const host = request.headers.get("host") ?? "";
  const configuredHost = configured.host; // hostname:port
  if (!configuredHost || host === configuredHost) return null;

  const isLocalRequest =
    host.startsWith("localhost") || host.startsWith("127.0.0.1");
  const configuredIsLab = configured.hostname.endsWith(".local");
  if (!(isLocalRequest && configuredIsLab)) return null;

  const url = request.nextUrl.clone();
  url.protocol = configured.protocol;
  url.hostname = configured.hostname;
  url.port = configured.port;
  return NextResponse.redirect(url);
}

export async function middleware(request: NextRequest) {
  const hostRedirect = redirectToConfiguredHost(request);
  if (hostRedirect) return hostRedirect;

  return await auth0.middleware(request);
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|sitemap.xml|robots.txt).*)",
  ],
};
