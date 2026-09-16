import { auth0 } from "@/lib/auth0";

/** Zenn 02: App A（:3000）— 同一テナント SSO の入口 */
export default async function Home() {
  const session = await auth0.getSession();

  if (!session) {
    return (
      <main>
        <p>App A（:3000）— 未ログイン</p>
        <p>
          <a href="/auth/login">Log in</a>
        </p>
      </main>
    );
  }

  return (
    <main>
      <p>
        App A（:3000）ログイン中:{" "}
        {(session.user.name as string | undefined) ??
          (session.user.email as string | undefined)}
      </p>
      <pre>{JSON.stringify(session.user, null, 2)}</pre>
      <p>
        <a href="http://localhost:3001/auth/login">App B で SSO 確認</a>
        {" · "}
        <a href="/auth/logout">Log out</a>
      </p>
    </main>
  );
}
