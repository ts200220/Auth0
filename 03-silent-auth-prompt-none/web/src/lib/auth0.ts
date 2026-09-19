import { Auth0Client } from "@auth0/nextjs-auth0/server";
import { NextResponse } from "next/server";

function oauthErrorCode(error: unknown): string {
  if (!error || typeof error !== "object") return "authorization_error";
  const e = error as { code?: unknown; cause?: { code?: unknown } };
  if (typeof e.cause?.code === "string" && e.cause.code.length > 0) {
    return e.cause.code;
  }
  if (typeof e.code === "string" && e.code.length > 0) return e.code;
  return "authorization_error";
}

function oauthErrorMessage(error: unknown): string {
  if (!(error instanceof Error)) return String(error);
  const cause = (error as { cause?: unknown }).cause;
  if (cause instanceof Error && cause.message) return cause.message;
  return error.message;
}

/**
 * Zenn 03: Silent Auth 用。
 * - Silent（returnTo が /silent）の失敗だけ /silent?error=... へ
 * - 同意ログインなど通常フローの失敗は /auth-error へ（silent に回流させない）
 */
export const auth0 = new Auth0Client({
  authorizationParameters: {
    scope: "openid profile email",
  },
  async onCallback(error, context) {
    const base = context.appBaseUrl ?? process.env.APP_BASE_URL ?? "http://localhost:3000";
    const returnTo = context.returnTo || "/";
    const silentFlow = returnTo === "/silent" || returnTo.startsWith("/silent?");

    if (error) {
      const path = silentFlow ? "/silent" : "/auth-error";
      const url = new URL(path, base);
      url.searchParams.set("error", oauthErrorCode(error));
      url.searchParams.set("message", oauthErrorMessage(error));
      return NextResponse.redirect(url);
    }

    return NextResponse.redirect(new URL(returnTo, base));
  },
});
