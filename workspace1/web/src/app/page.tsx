import { auth0 } from "@/lib/auth0";

/**
 * Zenn 01: ログイン〜セッション表示のみ。
 * Social / RBAC / Org / Custom DB などの導線は、対応ハンズオン実装後に足す。
 */
export default async function Home() {
  const session = await auth0.getSession();

  if (!session) {
    return (
      <main>
        <p>未ログインです。</p>
        <p>
          <a href="/auth/login">Log in</a>
        </p>
      </main>
    );
  }

  return (
    <main>
      <p>
        ログイン中:{" "}
        {(session.user.name as string | undefined) ??
          (session.user.email as string | undefined)}
      </p>
      <pre>{JSON.stringify(session.user, null, 2)}</pre>
      <p>
        <a href="/auth/logout">Log out</a>
      </p>
    </main>
  );
}
