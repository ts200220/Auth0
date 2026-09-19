import { auth0 } from "@/lib/auth0";

/** Zenn 04: ログイン + 保護 API（/api/me）の確認 */
export default async function Home() {
  const session = await auth0.getSession();

  if (!session) {
    return (
      <main>
        <h1>保護 API（セッション）</h1>
        <p>未ログインです。</p>
        <ol>
          <li>
            <a href="/api/me">GET /api/me</a>（いまは <strong>401</strong>）
          </li>
          <li>
            <a href="/auth/login">Log in</a>
          </li>
          <li>
            ログイン後にもう一度 <a href="/api/me">/api/me</a>（<strong>200</strong>）
          </li>
        </ol>
      </main>
    );
  }

  return (
    <main>
      <h1>保護 API（セッション）</h1>
      <p>
        ログイン中:{" "}
        {(session.user.name as string | undefined) ??
          (session.user.email as string | undefined)}
      </p>
      <ol>
        <li>
          <a href="/api/me">GET /api/me</a>（Cookie 付き → <strong>200</strong> + user）
        </li>
        <li>
          <a href="/auth/logout">Log out</a> → 再度 /api/me で <strong>401</strong>
        </li>
      </ol>
      <pre>{JSON.stringify(session.user, null, 2)}</pre>
    </main>
  );
}
