type Props = {
  searchParams: Promise<{ error?: string; message?: string }>;
};

/** 通常ログイン / 同意ログインの失敗先（Silent 専用ページに回流させない） */
export default async function AuthErrorPage({ searchParams }: Props) {
  const params = await searchParams;
  const error = params.error ?? "unknown";
  const message = params.message;

  const denied = error === "access_denied";

  return (
    <main>
      <h1>ログイン / 同意に失敗しました</h1>
      <p>
        error: <code>{error}</code>
      </p>
      {message ? (
        <p>
          message: <code>{message}</code>
        </p>
      ) : null}

      {denied ? (
        <p>
          同意画面で <strong>拒否 / Cancel</strong> が選ばれました。もう一度開き、必ず{" "}
          <strong>許可 / Accept</strong> を押してください。
        </p>
      ) : error === "invalid_state" ? (
        <p>
          ログイン開始時と Callback のホストが食い違っています（例:{" "}
          <code>localhost</code> で開始 → <code>auth0-lab.local</code> に戻る）。
          サイトデータを消し、必ず <code>http://auth0-lab.local:3000</code>{" "}
          だけからやり直してください。
        </p>
      ) : (
        <p>
          Auth0 の Oops 画面だった場合はタブを閉じ、下のリンクからやり直してください。
        </p>
      )}

      <p>
        <a href="/auth/login?prompt=consent&returnTo=/">
          同意つきログインをやり直す（許可を押す）
        </a>
      </p>
      <p>
        <a href="/">トップへ</a>
      </p>
    </main>
  );
}
