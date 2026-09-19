#!/usr/bin/env bash
# Silent Auth を localhost 以外で通すため、APP_BASE_URL と Auth0 App URL を切り替える
#
# 理由: Auth0 は Callback が localhost のとき同意スキップをしない。
#       App セッションがあっても prompt=none が consent_required になりやすい。
#
# ホスト側（先に実行）:
#   # Linux
#   echo '127.0.0.1 auth0-lab.local' | sudo tee -a /etc/hosts
#   # Windows (管理者): C:\Windows\System32\drivers\etc\hosts に同じ1行
#
# lab 内:
#   bash /workspace/scripts/use-lab-host.sh
#
# ホストに戻り:
#   docker compose up -d --force-recreate web
#   ブラウザは http://auth0-lab.local:3000 を開く（localhost:3000 ではない）

set -euo pipefail

LAB_HOST="${LAB_HOST:-auth0-lab.local}"
BASE_URL="${BASE_URL:-http://${LAB_HOST}:3000}"
ENV_FILE="${ENV_FILE:-/workspace/web/.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "use-lab-host: .env がありません: $ENV_FILE" >&2
  exit 1
fi

if ! command -v auth0 >/dev/null 2>&1; then
  echo "use-lab-host: lab コンテナ内で実行してください。" >&2
  exit 1
fi

bash /workspace/scripts/normalize-env.sh "$ENV_FILE" || true

read_env() {
  local key="$1"
  grep -E "^[[:space:]]*${key}=" "$ENV_FILE" \
    | head -n1 \
    | tr -d '\r' \
    | sed -E "s/^[[:space:]]*${key}=//; s/^[\"']//; s/[\"']\$//; s/[[:space:]]+\$//" \
    || true
}

CLIENT_ID="$(read_env AUTH0_CLIENT_ID)"
if [[ -z "$CLIENT_ID" ]]; then
  echo "use-lab-host: AUTH0_CLIENT_ID がありません。" >&2
  exit 1
fi

tmp="$(mktemp)"
awk -v base="$BASE_URL" '
  BEGIN { done=0 }
  /^[[:space:]]*APP_BASE_URL=/ { print "APP_BASE_URL=" base; done=1; next }
  { print }
  END { if (!done) print "APP_BASE_URL=" base }
' "$ENV_FILE" > "$tmp"
mv "$tmp" "$ENV_FILE"
bash /workspace/scripts/normalize-env.sh "$ENV_FILE" || true
chown node:node "$ENV_FILE" 2>/dev/null || true
chmod 640 "$ENV_FILE" 2>/dev/null || true

echo "== Auth0 App URL を更新: ${CLIENT_ID} =="
auth0 apps update "$CLIENT_ID" \
  --callbacks "${BASE_URL}/auth/callback" \
  --logout-urls "${BASE_URL}" \
  --origins "${BASE_URL}" \
  --web-origins "${BASE_URL}" \
  --no-input

echo
echo "OK: APP_BASE_URL=${BASE_URL}"
echo
echo "次:"
echo "  1. ホストの hosts に 127.0.0.1 ${LAB_HOST} があること"
echo "  2. docker compose up -d --force-recreate web"
echo "  3. ブラウザ: ${BASE_URL} （Cookie は localhost と別）"
echo "  4. 同意つきログイン → Accept → Silent Auth"
