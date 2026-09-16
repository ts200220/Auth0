import { auth0 } from "@/lib/auth0";

/** Zenn 02: App B（:3001）— IdP セッションがあればパスワード再入力なし */
export default async function Home() {
  const session = await auth0.getSession();

  if (!session) {
    return (
      <main>
        <p>App B（:3001）— 未ログイン</p>
        <p>
          <a href="/auth/login">Log in</a>
        </p>
        <p>
          先に{" "}
          <a href="http://localhost:3000">App A</a>{" "}
          でログインしてからここに来ると SSO を確認できます。
        </p>
      </main>
    );
  }

  return (
    <main>
      <p>
        App B（:3001）ログイン中:{" "}
        {(session.user.name as string | undefined) ??
          (session.user.email as string | undefined)}
      </p>
      <pre>{JSON.stringify(session.user, null, 2)}</pre>
      <p>
        <a href="http://localhost:3000">App A</a>
        {" · "}
        <a href="/auth/logout">Log out</a>
      </p>
    </main>
  );
}
