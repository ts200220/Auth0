#!/usr/bin/env bash
# App B（:3001）を CLI で作り、web-b/.env を書く（lab 内で実行）
#
# 前提:
#   - auth0 login && auth0 tenants use 済み
#   - App A の web/.env がある（qs setup 済み）
#
# 使い方:
#   bash /workspace/scripts/setup-app-b.sh
#
# 環境変数:
#   APP_B_NAME  既定: my-next-02-b

set -euo pipefail

APP_B_NAME="${APP_B_NAME:-my-next-02-b}"
ENV_A="${ENV_A:-/workspace/web/.env}"
ENV_B="${ENV_B:-/workspace/web-b/.env}"

if ! command -v auth0 >/dev/null 2>&1; then
  echo "auth0 CLI がありません。lab コンテナ内で実行してください。" >&2
  exit 1
fi

if [[ ! -f "$ENV_A" ]]; then
  echo "App A の .env がありません: $ENV_A" >&2
  echo "先に: cd /workspace/web && auth0 qs setup --app --type regular --framework nextjs --name my-next-02-a --port 3000 --no-input" >&2
  exit 1
fi

bash /workspace/scripts/normalize-env.sh "$ENV_A" || true

read_env() {
  local key="$1"
  local f="$2"
  grep -E "^[[:space:]]*${key}=" "$f" \
    | head -n1 \
    | tr -d '\r' \
    | sed -E "s/^[[:space:]]*${key}=//; s/^[\"']//; s/[\"']\$//; s/[[:space:]]+\$//" \
    || true
}

DOMAIN="$(read_env AUTH0_DOMAIN "$ENV_A")"
if [[ -z "$DOMAIN" ]]; then
  echo "AUTH0_DOMAIN が $ENV_A にありません。" >&2
  exit 1
fi

if ! auth0 apps list --no-input >/dev/null 2>&1; then
  echo "Auth0 CLI にログインできていません。" >&2
  echo "先に: auth0 login && auth0 tenants use" >&2
  exit 1
fi

echo "== App B を作成: ${APP_B_NAME} =="
json="$(auth0 apps create \
  --name "${APP_B_NAME}" \
  --type regular \
  --callbacks "http://localhost:3001/auth/callback" \
  --logout-urls "http://localhost:3001" \
  --web-origins "http://localhost:3001" \
  --reveal-secrets \
  --json \
  --no-input)"

CLIENT_ID="$(echo "$json" | jq -r '.client_id // .clientId // empty')"
CLIENT_SECRET="$(echo "$json" | jq -r '.client_secret // .clientSecret // empty')"

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || "$CLIENT_ID" == "null" ]]; then
  echo "apps create の応答から Client ID/Secret を取れませんでした。" >&2
  echo "$json" >&2
  exit 1
fi

SECRET="$(openssl rand -hex 32)"

cat > "$ENV_B" <<EOF
APP_BASE_URL=http://localhost:3001
AUTH0_DOMAIN=${DOMAIN}
AUTH0_CLIENT_ID=${CLIENT_ID}
AUTH0_CLIENT_SECRET=${CLIENT_SECRET}
AUTH0_SECRET=${SECRET}
EOF

bash /workspace/scripts/normalize-env.sh "$ENV_B"
chown node:node "$ENV_B" 2>/dev/null || true
chmod 640 "$ENV_B" 2>/dev/null || true

echo
echo "OK: ${ENV_B}"
echo "  APP_BASE_URL=http://localhost:3001"
echo "  AUTH0_DOMAIN=${DOMAIN}"
echo "  AUTH0_CLIENT_ID=${CLIENT_ID}"
echo "  AUTH0_CLIENT_SECRET=***"
echo "  AUTH0_SECRET=***"
echo
echo "次:"
echo "  1. Dashboard → Applications → ${APP_B_NAME} → Connections"
echo "     App A と同じ Connection を有効にする"
echo "  2. ホスト: docker compose up -d --force-recreate web web-b"
echo "  3. http://localhost:3000 → Log in → http://localhost:3001/auth/login"
