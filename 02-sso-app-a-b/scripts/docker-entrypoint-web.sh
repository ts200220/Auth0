#!/usr/bin/env bash
# Next.js コンテナ起動: .env 正規化 → node で next dev
# 環境変数:
#   APP_DIR  既定 /workspace/web
#   PORT     既定 3000
set -euo pipefail

APP_DIR="${APP_DIR:-/workspace/web}"
PORT="${PORT:-3000}"

mkdir -p "${APP_DIR}/node_modules" "${APP_DIR}/.next"
chown -R node:node "${APP_DIR}/node_modules" "${APP_DIR}/.next" 2>/dev/null || true

if [[ -f /workspace/scripts/normalize-env.sh ]]; then
  bash /workspace/scripts/normalize-env.sh "${APP_DIR}/.env" || true
fi

if [[ -f "${APP_DIR}/.env" ]]; then
  chown node:node "${APP_DIR}/.env"
  chmod 640 "${APP_DIR}/.env"
fi
if [[ -f "${APP_DIR}/.env.local" ]]; then
  chown node:node "${APP_DIR}/.env.local"
  chmod 640 "${APP_DIR}/.env.local"
fi

cd "${APP_DIR}"
exec gosu node bash -lc "npm install && npm run dev -- --hostname 0.0.0.0 --port ${PORT}"
