import { auth0 } from "@/lib/auth0";

/** Zenn 03: Silent Auth。localhost では App セッション≠Silent 成功になりうる */
export default async function Home() {
  const session = await auth0.getSession();
  const base = process.env.APP_BASE_URL ?? "http://localhost:3000";
  const isLocalhost = /localhost|127\.0\.0\.1/.test(base);

  return (
    <main>
      <h1>Silent Auth（prompt=none）</h1>
      <p>
        いまの APP_BASE_URL: <code>{base}</code>
      </p>

      {isLocalhost ? (
        <p>
          <strong>注意:</strong> Callback が localhost のとき、Auth0 は Silent（
          <code>prompt=none</code>）で <code>consent_required</code>{" "}
          を返しやすいです。App セッションがあっても Silent
          成功とは限りません。確実に成功させるなら lab で{" "}
          <code>bash scripts/use-lab-host.sh</code> を実行し、
          <code>http://auth0-lab.local:3000</code> で開いてください。
        </p>
      ) : (
        <p>
          lab.local ホストを使用中です。同意 → Silent 成功 → Logout →{" "}
          <code>login_required</code> を確認します。
        </p>
      )}

      {session ? (
        <>
          <p>
            App セッションあり:{" "}
            {(session.user.name as string | undefined) ??
              (session.user.email as string | undefined)}
          </p>
          <ol>
            <li>
              （未同意なら）{" "}
              <a href="/auth/login?prompt=consent&returnTo=/">
                同意つきログイン → Accept
              </a>
            </li>
            <li>
              <a href="/auth/login?prompt=none&returnTo=/silent">
                Silent Auth（prompt=none）
              </a>
            </li>
            <li>
              <a href="/auth/logout">Log out</a> → Silent →{" "}
              <code>login_required</code>
            </li>
          </ol>
          <pre>{JSON.stringify(session.user, null, 2)}</pre>
        </>
      ) : (
        <ol>
          <li>
            <a href="/auth/login?prompt=consent&returnTo=/">
              同意つきログイン（Accept）
            </a>
          </li>
          <li>
            <a href="/auth/login?prompt=none&returnTo=/silent">Silent Auth</a>
          </li>
          <li>
            <a href="/auth/logout">Log out</a> → Silent → login_required
          </li>
        </ol>
      )}
    </main>
  );
}
