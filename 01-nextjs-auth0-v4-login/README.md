# Next.js × Auth0 SDK v4 でログインする

| サービス | 内容 |
|----------|------|
| `web` | Next.js → http://localhost:3000 |
| `lab` | Auth0 CLI（`auth0 login` / `qs setup`） |

## 起動

ラボのルート（この README があるディレクトリ）で:

```bash
docker compose up -d web
```

## CLI（App / .env）

同じくラボのルートで:

```bash
docker compose --profile cli run --rm lab
```

```bash
bash scripts/check.sh
auth0 login
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-01 --port 3000 --no-input
```

→ http://localhost:3000 → Log in / Log out

## フォルダ一覧（要約）

```text
01-nextjs-auth0-v4-login/             # ラボのルート（相対パス）
├── docker-compose.yml / Dockerfile   # 実行環境
├── scripts/check.sh                  # 前提チェック
├── scripts/docker-entrypoint-web.sh  # web 起動
├── .auth0-config/                    # CLI ログイン（gitignore）
└── web/
    ├── .env                          # qs setup が書く（gitignore）
    └── src/
        ├── middleware.ts             # /auth/* マウント
        ├── lib/auth0.ts              # Auth0Client
        └── app/page.tsx              # ログイン UI
```
