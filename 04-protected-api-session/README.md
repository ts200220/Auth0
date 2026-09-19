# 保護 API（セッション）と `/api/me`

前提: **Linux ホスト**（bash）+ Docker Engine / Compose。  
コマンドはラボのルート（この README / `docker-compose.yml` があるディレクトリ）で実行します。

| サービス | 内容 |
|----------|------|
| `web` | Next.js → http://localhost:3000 |
| `lab` | Auth0 CLI（`auth0 login` / `qs setup`） |

詳細は [`articles/zenn/04-protected-api-session.md`](../articles/zenn/04-protected-api-session.md)。

## 起動

01〜03 が :3000 を使っている場合は先に止める:

```bash
docker stop 01-nextjs-auth0-v4-login-web-1 02-sso-app-a-b-web-1 03-silent-auth-prompt-none-web-1 2>/dev/null || true
```

```bash
docker compose up -d --build web
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
auth0 qs setup --app --type regular --framework nextjs --name my-next-04 --port 3000 --no-input
bash /workspace/scripts/normalize-env.sh
grep -E '^(AUTH0_|APP_)' .env | sed 's/=.*/=***/'
exit
```

ホストに戻り:

```bash
docker compose up -d --force-recreate web
```

## 確認手順（ゴール）

1. シークレット（未ログイン）で http://localhost:3000/api/me → **401**
2. http://localhost:3000 で **Log in**
3. 同じブラウザで http://localhost:3000/api/me → **200** + `user`
4. **Log out** 後に再度 `/api/me` → **401**

`curl` だけだと Cookie が無いので常に 401（仕様どおり）。

## 最初からやり直す

```bash
bash scripts/reset-lab.sh --force
```

| フラグ | 意味 |
|--------|------|
| `--force` | 確認プロンプトを出さない |
| `--full` | CLI ログイン（`.auth0-config`）も消す |
| `--keep-app` | Auth0 App は残し、ローカル `.env` だけ消す |
| `--no-recreate` | 終了後に `web` を recreate しない |

## よくある失敗

| 症状 | 対処 |
|------|------|
| `Bind ... 3000 failed` | 01〜03 の web を止める |
| `DomainResolutionError` | `normalize-env.sh` → `docker compose up -d --force-recreate web` |
| 常に 401 | 未ログイン、または別ブラウザで Cookie が無い |
| `curl` だけ 401 | 仕様どおり（Cookie 未送信） |

## フォルダ

```text
04-protected-api-session/
├── scripts/normalize-env.sh / reset-lab.sh / check.sh
└── web/src/
    ├── lib/auth0.ts
    ├── middleware.ts
    ├── app/page.tsx
    └── app/api/me/route.ts   # withApiAuthRequired ← 今回の焦点
```
