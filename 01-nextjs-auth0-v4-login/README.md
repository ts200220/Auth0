# Next.js × Auth0 SDK v4 でログインする

前提: **Linux ホスト**（bash）+ Docker Engine / Compose。  
コマンドはラボのルート（この README / `docker-compose.yml` があるディレクトリ）で実行します。

| サービス | 内容 |
|----------|------|
| `web` | Next.js → http://localhost:3000 |
| `lab` | Auth0 CLI（`auth0 login` / `qs setup`） |

手順の詳細・失敗表は Zenn 記事  
[`Auth0 CLI × Next.js SDK v4 でログインする`](https://zenn.dev/ts200/articles/843f0696393843) を正とします。


## 起動

```bash
docker compose up -d web
```

## CLI（App / .env）

```bash
docker compose --profile cli run --rm lab
```

lab コンテナ内:

```bash
bash scripts/check.sh
auth0 login
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-01 --port 3000 --no-input
bash /workspace/scripts/normalize-env.sh
grep -E '^(AUTH0_|APP_)' .env | sed 's/=.*/=***/'
exit
```

ホストに戻り:

```bash
docker compose up -d --force-recreate web
```

ブラウザで http://localhost:3000 → Log in / Log out

メモ:

- `auth0 login` でブラウザが開かない場合は、表示された activate URL をホストのブラウザで開く  
- `tenants use` は矢印で選んで Enter  
- `normalize-env.sh` は `qs setup` が付けた囲みクォートなどを除去する（`web` 起動時にも自動実行）

## 最初からやり直す

```bash
bash scripts/reset-lab.sh --force
```

続けて lab で App / `.env` を作り直す:

```bash
docker compose --profile cli run --rm lab
```

```bash
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-01 --port 3000 --no-input
bash /workspace/scripts/normalize-env.sh
grep -E '^(AUTH0_|APP_)' .env | sed 's/=.*/=***/'
exit
```

```bash
docker compose up -d --force-recreate web
```

オプション:

| フラグ | 意味 |
|--------|------|
| `--force` | 確認プロンプトを出さない |
| `--full` | CLI ログイン（`.auth0-config`）も消す |
| `--keep-app` | Auth0 App は残し、ローカル `.env` だけ消す |
| `--no-recreate` | 終了後に `web` を recreate しない |

CLI セッションが切れているときは、先に lab で `auth0 login` してから再実行する。

## よくある失敗（短縮）

| 症状 | 対処 |
|------|------|
| `DomainResolutionError` | `.env` を確認 → `normalize-env.sh` → `docker compose up -d --force-recreate web` |
| `/auth/login` が 404 | `middleware.ts` と matcher を確認 |
| callback エラー | Callback は `/auth/callback`（v3 の `/api/auth/callback` ではない） |
| CLI がブラウザを開けない | activate URL をホストで手動オープン |
| 別テナントに App ができている | `auth0 tenants use` で対象を固定 |
| `docker: command not found` | Docker Engine と Compose プラグインを入れる |

## フォルダ一覧（要約）

```text
01-nextjs-auth0-v4-login/             # ラボのルート
├── docker-compose.yml / Dockerfile
├── scripts/check.sh
├── scripts/normalize-env.sh          # .env 正規化
├── scripts/reset-lab.sh              # 最初からやり直す
├── scripts/docker-entrypoint-web.sh  # web 起動（normalize 含む）
├── .auth0-config/                    # CLI ログイン（gitignore）
└── web/
    ├── .env                          # qs setup が書く（gitignore）
    └── src/
        ├── middleware.ts
        ├── lib/auth0.ts
        └── app/page.tsx
```
