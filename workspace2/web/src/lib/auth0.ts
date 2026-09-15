import { Auth0Client } from "@auth0/nextjs-auth0/server";

/**
 * Zenn 01 / 記事 02 相当の最小構成。
 * audience / RBAC / custom claims は後続ハンズオンで足す。
 */
export const auth0 = new Auth0Client();
