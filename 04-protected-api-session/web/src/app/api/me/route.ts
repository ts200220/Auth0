import { NextResponse } from "next/server";
import { auth0 } from "@/lib/auth0";

/**
 * Zenn 04: セッション必須の保護 API。
 * Resource Server / Bearer 検証は後続（08 / 10）で扱う。
 */
export const GET = auth0.withApiAuthRequired(async function GET() {
  const session = await auth0.getSession();
  return NextResponse.json({
    message: "protected route — session required",
    user: session?.user ?? null,
  });
});
