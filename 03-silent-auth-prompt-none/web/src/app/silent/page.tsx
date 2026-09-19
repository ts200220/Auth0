import { auth0 } from "@/lib/auth0";

type Props = {
  searchParams: Promise<{ error?: string; message?: string }>;
};

export default async function SilentResultPage({ searchParams }: Props) {
  const params = await searchParams;
  const session = await auth0.getSession();
  const error = params.error;

  if (error === "consent_required") {
    return (
      <main>
        <h1>Silent Auth — consent_required</h1>
        <p>
          localhost では初回同意が必要です。下で同意画面を開き、必ず{" "}
          <strong>Accept / 許可</strong> を押してください。
        </p>
        <p>
          ※ 以前ログに <code>access_denied</code>{" "}
          が出ていました。拒否すると同意は保存されません。
        </p>
        <p>
          <a href="/auth/login?prompt=consent&returnTo=/">
            同意つきログイン（Accept を押す）
          </a>
        </p>
        <p>
          成功するとトップにユーザー情報が出し、そこから Silent を試します。
        </p>
        <p>
          <a href="/">トップへ</a>
        </p>
      </main>
    );
  }

  if (error === "login_required") {
    return (
      <main>
        <h1>Silent Auth — login_required（期待どおりの失敗）</h1>
        <p>Auth0 セッションがありません。Logout 後なら成功です。</p>
        <p>
          <a href="/">トップへ</a>
        </p>
      </main>
    );
  }

  if (error) {
    return (
      <main>
        <h1>Silent Auth — 失敗</h1>
        <p>
          error: <code>{error}</code>
        </p>
        <p>
          <a href="/">トップへ</a>
        </p>
      </main>
    );
  }

  if (session) {
    return (
      <main>
        <h1>Silent Auth — 成功</h1>
        <p>UI なしで認可できました。</p>
        <pre>{JSON.stringify(session.user, null, 2)}</pre>
        <p>
          <a href="/auth/logout">Log out</a> → Silent で login_required を確認
        </p>
        <p>
          <a href="/">トップへ</a>
        </p>
      </main>
    );
  }

  return (
    <main>
      <h1>Silent Auth</h1>
      <p>
        <a href="/">トップで手順どおり進めてください</a>
      </p>
    </main>
  );
}
