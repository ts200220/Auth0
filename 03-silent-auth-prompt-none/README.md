# Silent Auth（prompt=none）

前提: **Linux ホスト**（bash）+ Docker Engine / Compose。  
コマンドはラボのルートで実行します。

| サービス | 内容 |
|----------|------|
| `web` | Next.js（**必須:** http://auth0-lab.local:3000） |
| `lab` | Auth0 CLI |

詳細は [`articles/zenn/03-silent-auth-prompt-none.md`](../articles/zenn/03-silent-auth-prompt-none.md)。

## なぜ localhost だけだとゴールしにくいか

Auth0 は **Callback が `localhost` のとき同意スキップをしない**。その結果:

- 通常ログインで **App セッションあり** になっても
- Silent（`prompt=none`）は **`consent_required`** のまま

になりやすいです。ゴール（Silent 成功 → Logout 後 `login_required`）を見るなら **`auth0-lab.local`** が正規手順です。

加えて、`APP_BASE_URL` が lab.local なのに **`localhost` で `/auth/login` を始める**と、`__txn_` Cookie は localhost に付き、Callback は lab.local → **`invalid_state`** になります。ラボは localhost を lab.local へリダイレクトしますが、手入力・ブックマークは lab.local に統一してください。

## 起動

```bash
# hosts（一度だけ）— Linux / macOS
echo '127.0.0.1 auth0-lab.local' | sudo tee -a /etc/hosts
# Windows: 管理者で C:\Windows\System32\drivers\etc\hosts に同じ1行を追加

docker stop 01-nextjs-auth0-v4-login-web-1 02-sso-app-a-b-web-1 2>/dev/null || true
docker compose up -d --build web
```

## CLI

```bash
docker compose --profile cli run --rm lab
```

```bash
bash scripts/check.sh
auth0 login
auth0 tenants use
cd /workspace/web
auth0 qs setup --app --type regular --framework nextjs --name my-next-03 --port 3000 --no-input
bash /workspace/scripts/normalize-env.sh
bash /workspace/scripts/use-lab-host.sh
exit
```

CLI が `Auth token expired` なら `auth0 login` のあと `use-lab-host.sh` を再実行。

```bash
docker compose up -d --force-recreate web
```

ブラウザは **http://auth0-lab.local:3000**（`localhost:3000` ではない）。

## 確認手順（ゴール）

1. 同意つきログイン → **Accept / 許可**  
2. **Silent Auth** → 「Silent Auth — 成功」（ログイン UI なし）  
3. **Log out**  
4. Silent Auth → **`login_required`**

トップの「App セッションあり」はアプリ Cookie です。Silent 成功とは別物です。

## 最初からやり直す

```bash
bash scripts/reset-lab.sh --force
```

## よくある失敗

| 症状 | 対処 |
|------|------|
| Silent が `consent_required` | localhost 利用中か未同意。`use-lab-host.sh` + lab.local で Accept |
| `invalid_state` | localhost / lab.local の Cookie を消し、**lab.local だけ**からやり直し |
| `access_denied` | 同意で拒否した。Accept でやり直す |
| CLI `Auth token expired` | `auth0 login` → `use-lab-host.sh` |
| Auth0 Oops on logout | `/auth/logout` のみ（相対 returnTo 禁止） |
| `Bind :3000` | 他ラボの web を止める |

## フォルダ

```text
03-silent-auth-prompt-none/
├── scripts/use-lab-host.sh   # APP_BASE_URL + Auth0 Callback → auth0-lab.local
├── scripts/normalize-env.sh / reset-lab.sh / check.sh
└── web/src/
    ├── middleware.ts         # localhost → lab.local リダイレクト
    ├── lib/auth0.ts
    └── app/page.tsx / silent/page.tsx / auth-error/page.tsx
```
