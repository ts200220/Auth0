# 保護 APIとセッション

| サービス | 内容 |
|----------|------|
| `web` | Next.js → http://localhost:3000 |
| `lab` | Auth0 CLI（`auth0 login` / `qs setup`） |

01（ログイン）の続きです。差分は **`GET /api/me`（セッション必須）** です。

## 起動

01 の `workspace1` が 3000 を使っている場合は先に止める:

```bash
# workspace1 側
docker compose stop web
```

ラボのルート（この README があるディレクトリ）で:

```bash
docker compose up -d web
```

`.env` の値に `"..."` が残っていると `DomainResolutionError` になります（両端の `"` を外す）。

## CLI（App / .env）

01 と同じく、`.env` が無ければ:

```bash
docker compose --profile cli run --rm lab
```

```bash
bash scripts/check.sh
auth0 login
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-02 --port 3000 --no-input
```

ホスト側:

```bash
docker compose up -d --force-recreate web
```

## 確認

1. シークレットウィンドウで http://localhost:3000/api/me → **401**
2. http://localhost:3000 で Log in
3. 同じブラウザで http://localhost:3000/api/me → **200** + `user`
4. トップの「GET /api/me」リンクでも可

## フォルダ一覧（要約）

```text
workspace2/
├── docker-compose.yml / Dockerfile
├── scripts/
└── web/src/
    ├── middleware.ts
    ├── lib/auth0.ts
    ├── app/page.tsx              # ログイン UI + /api/me リンク
    └── app/api/me/route.ts       # withApiAuthRequired
```
