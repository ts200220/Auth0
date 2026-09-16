import { Auth0Client } from "@auth0/nextjs-auth0/server";

/** Zenn 02 App B。AUTH0_SECRET は A と別（App セッションは独立）。 */
export const auth0 = new Auth0Client();
