# Auth0 × Next.js：保護 APIとセッション

ログインできた次に必要なのは、「未ログインなら弾く API」です。  
`@auth0/nextjs-auth0` v4 では Route Handler を **セッション必須**にできます。

シリーズでは [03. Silent Auth](./03-silent-auth-prompt-none.md) の次ですが、題材としては **[01. ログイン](./01-nextjs-auth0-v4-login.md) の続編（セッション帯）**です。02/03 を飛ばしても、01 が通っていれば進めます。

付属ラボ(GitHub): [04-protected-api-session](https://github.com/ts200220/Auth0/tree/main/04-protected-api-session)

## ゴール

| 状態 | `GET /api/me` |
|------|----------------|
| 未ログイン | **401** |
| ログイン済み（Cookie 付き） | **200** + `user` |

保護の本体は Auth0 Resource Server ではなく、**SDK のセッション Cookie** です。`withApiAuthRequired` が Cookie を見て、無ければ 401、あればハンドラを実行します。

## 前提

| 項目 | 内容 |
|------|------|
| OS | **Linux**（bash）。Windows / macOS 向け手順は書かない |
| Docker | Engine + Compose が起動済み |
| Auth0 | テナントあり（[01](./01-nextjs-auth0-v4-login.md) と同じで可） |
| 知識 | 01 相当（`/auth/login`・`Auth0Client`・middleware） |

```bash
git clone https://github.com/ts200220/Auth0.git
cd Auth0/04-protected-api-session
```

01〜03 で `.env` 済みでも、**このラボは別ディレクトリ**なので、初回は `qs setup` が必要です。

## 1. ラボを起動する

01〜03 の web が動いていると **3000 番が埋まって**失敗します。先に止めてから起動してください。

```bash
docker stop 01-nextjs-auth0-v4-login-web-1 02-sso-app-a-b-web-1 03-silent-auth-prompt-none-web-1 2>/dev/null || true

# 04 のルートで
docker compose up -d --build web
```

| サービス | 役割 |
|----------|------|
| `web` | Next.js（http://localhost:3000） |
| `lab` | Auth0 CLI（`--profile cli`） |

ホストに Auth0 CLI が無くても問題ありません。`auth0` は **lab コンテナ内**で使います。

## 2. App と `.env`（初回のみ）

```bash
docker compose --profile cli run --rm lab
```

コンテナ内:

```bash
bash scripts/check.sh
auth0 login
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-04 --port 3000 --no-input
bash /workspace/scripts/normalize-env.sh
grep -E '^(AUTH0_|APP_)' .env | sed 's/=.*/=***/'
exit
```

`normalize-env.sh` は `qs setup` が付けた囲みクォートや CRLF を除去します（`web` 起動時にも自動実行）。空の `.env` や値に `"` が残ると **`DomainResolutionError`** になります。

ホスト側:

```bash
docker compose up -d --force-recreate web
```

## 3. 配置済みの保護 API

手で書く必要はありません。差分の中心はこの 1 ファイルです。

```ts
// web/src/app/api/me/route.ts
import { NextResponse } from "next/server";
import { auth0 } from "@/lib/auth0";

export const GET = auth0.withApiAuthRequired(async function GET() {
  const session = await auth0.getSession();
  return NextResponse.json({
    message: "protected route — session required",
    user: session?.user ?? null,
  });
});
```

トップ（`page.tsx`）から `/api/me` へのリンクも置いてあります。

## 4. 動作確認

1. **シークレットウィンドウ**（または未ログイン状態）で http://localhost:3000/api/me  
   → **401**
2. http://localhost:3000 で **Log in**
3. 同じブラウザで http://localhost:3000/api/me  
   → **200** と `user`（`sub` など）
4. **Log out** 後にもう一度 `/api/me` → 再び **401**

ブラウザのアドレスバーで開くのが一番簡単です（同じオリジンなので Cookie が付きます）。

```bash
# Cookie 無しの例（常に 401 になる）
curl -i http://localhost:3000/api/me
```

## 最初からやり直す

```bash
bash scripts/reset-lab.sh --force
```

その後、上記の CLI（`qs setup` → `normalize-env` → recreate）をやり直します。

## よくある失敗

| 症状 | 原因 / 対処 |
|------|-------------|
| `Bind ... 3000 failed` | 01〜03 等が 3000 を使用中 → `docker stop ...-web-1` |
| `auth0: コマンドが見つからない` | ホストではなく `lab` コンテナ内で実行する |
| 常に 401 | 未ログイン、または別ブラウザ／シークレットで Cookie が無い |
| `curl` だけ 401 | 仕様どおり（Cookie を送っていない） |
| `DomainResolutionError` | `.env` が空、または値に `"` が残っている → `normalize-env.sh` → `web` 再作成 |
| `/api/me` が 404 | `web/src/app/api/me/route.ts` が無い／コンテナが古い |

## 混同しやすい2つの「API」

| 名前 | 何か |
|------|------|
| 自分の Route Handler（`/api/me`） | アプリの保護エンドポイント（今回） |
| Auth0 Management API | ユーザー作成・テナント操作（CLI が内部利用） |

Resource Server（`auth0 apis create`）は、**Access Token の `aud`（RBAC）**用です。セッション保護の `/api/me` だけなら必須ではありません。

## CLI でユーザー確認（任意）

```bash
auth0 users search
auth0 users show <USER_ID>
auth0 logs list
```

## フォルダ構成（見る場所）

```text
04-protected-api-session/
├── docker-compose.yml / Dockerfile / scripts/
└── web/src/
    ├── lib/auth0.ts
    ├── middleware.ts
    ├── app/page.tsx           # ログイン UI + /api/me リンク
    └── app/api/me/route.ts    # withApiAuthRequired ← 今回の焦点
```

```text
ブラウザ（Cookie 付き）
  → GET /api/me
  → withApiAuthRequired
  → セッションなし: 401
  → セッションあり: getSession() → 200 + user
```

## まとめ

1. 「ログイン画面」と「保護 API」は別レイヤ  
2. 今回の保護は **セッション Cookie**（Resource Server 不要）  
3. 未ログイン 401 / ログイン後 200 を自分の目で確認する  

前: [03. Silent Auth](./03-silent-auth-prompt-none.md)（読み順）／基盤は [01. ログイン](./01-nextjs-auth0-v4-login.md)  
次: [05. Logout / Refresh](./05-logout-session-refresh.md)  
続けて [08. RBAC](./08-rbac-route-handler.md)。Bearer は [10](./10-bearer-jwks-api.md)、マシン認証は [12](./12-m2m-client-credentials.md)。  

付属ラボ(GitHub): [04-protected-api-session](https://github.com/ts200220/Auth0/tree/main/04-protected-api-session)
