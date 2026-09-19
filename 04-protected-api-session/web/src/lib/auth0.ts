import { Auth0Client } from "@auth0/nextjs-auth0/server";

/**
 * Zenn 04 の最小構成。
 * audience / RBAC / Bearer は後続ハンズオンで足す。
 */
export const auth0 = new Auth0Client();
