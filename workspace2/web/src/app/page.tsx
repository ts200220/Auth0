import { auth0 } from "@/lib/auth0";

/**
 * Zenn 02: ログイン UI + 保護 API（/api/me）への導線。
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
        <p>
          <a href="/api/me">GET /api/me</a>（未ログインなら 401）
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
        <a href="/api/me">GET /api/me</a>（ログイン済みなら 200）
      </p>
      <p>
        <a href="/auth/logout">Log out</a>
      </p>
    </main>
  );
}
