import { NextResponse } from "next/server";
import { auth0 } from "@/lib/auth0";

export const GET = auth0.withApiAuthRequired(async function GET() {
  const session = await auth0.getSession();
  return NextResponse.json({
    message: "protected route — session required",
    user: session?.user ?? null,
  });
});
