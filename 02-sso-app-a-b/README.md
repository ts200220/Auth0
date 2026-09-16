# 同一テナント SSO（App A / App B）

前提: **Linux ホスト**（bash）+ Docker Engine / Compose。  
Windows / macOS / PowerShell / Git Bash 向けの手順は扱いません。  
コマンドはラボのルート（この README / `docker-compose.yml` があるディレクトリ）で実行します。

| サービス | 内容 |
|----------|------|
| `web` | App A → http://localhost:3000（イメージもここでビルド） |
| `web-b` | App B → http://localhost:3001（同じイメージを共有） |
| `lab` | Auth0 CLI（`auth0 login` / `qs setup` / `setup-app-b.sh`） |

手順の詳細は Zenn 記事  
[`articles/zenn/02-sso-app-a-b.md`](../articles/zenn/02-sso-app-a-b.md) を正とします。

## 起動

01 ラボが :3000 を使っている場合は先に止める:

```bash
docker stop 01-nextjs-auth0-v4-login-web-1 2>/dev/null || true
```

```bash
docker compose up -d --build web web-b
```

初回は `web` だけがイメージをビルドし、`web-b` / `lab` は同じタグを共有します。

## CLI（App A / App B / .env）

```bash
docker compose --profile cli run --rm lab
```

lab コンテナ内（起動時に `scripts/*.sh` の CRLF を除去）:

```bash
bash scripts/check.sh
auth0 login
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-02-a --port 3000 --no-input
bash /workspace/scripts/normalize-env.sh
bash /workspace/scripts/setup-app-b.sh
exit
```

ホストに戻り:

```bash
docker compose up -d --force-recreate web web-b
```

Dashboard → Applications → **my-next-02-b** → Connections で、App A と同じ Connection を有効にする。

ブラウザ:

1. http://localhost:3000 → Log in  
2. http://localhost:3001/auth/login → **パスワード再入力なし**  
   - 「アクセスを要求」などの **同意画面は初回だけ・失敗ではない** → 許可  
3. A で Log out 後、B の `/auth/login` → 再ログインが必要

## 最初からやり直す

```bash
bash scripts/reset-lab.sh --force
```

| フラグ | 意味 |
|--------|------|
| `--force` | 確認プロンプトを出さない |
| `--full` | CLI ログイン（`.auth0-config`）も消す |
| `--keep-app` | Auth0 App は残し、ローカル `.env` だけ消す |
| `--no-recreate` | 終了後に `web` / `web-b` を recreate しない |

## よくある失敗（短縮）

| 症状 | 対処 |
|------|------|
| `Bind ...:3000 failed` | 01 ラボなどを止めてから再起動 |
| B でもパスワードを求められる | Connections 不一致 / 別テナント |
| 「アクセスを要求しています」 | 同意（consent）。許可して進む |
| B が callback エラー | Callback / Logout URL に `:3001` が無い |
| Logout しても B が入れる | A の logout が Auth0 セッションを消していない |
| `DomainResolutionError` | `.env` 確認 → `normalize-env.sh` → `--force-recreate` |
| `$'\r': command not found` | lab を入れ直す（起動時に CRLF 除去） |

## フォルダ一覧（要約）

```text
02-sso-app-a-b/
├── docker-compose.yml / Dockerfile
├── scripts/check.sh
├── scripts/normalize-env.sh
├── scripts/setup-app-b.sh      # App B + web-b/.env
├── scripts/reset-lab.sh
├── scripts/docker-entrypoint-web.sh
├── .auth0-config/              # CLI ログイン（gitignore）
├── web/                        # App A（:3000）
│   └── .env
└── web-b/                      # App B（:3001）
    └── .env
```
