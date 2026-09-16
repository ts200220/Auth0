#!/usr/bin/env bash
# web コンテナ起動: .env 正規化 → node で next dev
set -euo pipefail

mkdir -p /workspace/web/node_modules /workspace/web/.next
chown -R node:node /workspace/web/node_modules /workspace/web/.next 2>/dev/null || true

# qs setup 直後の囲みクォートなどを起動前に直す（DomainResolutionError 予防）
if [[ -f /workspace/scripts/normalize-env.sh ]]; then
  bash /workspace/scripts/normalize-env.sh /workspace/web/.env || true
fi

# auth0 qs setup が root で .env を 600 にすると node から読めない
if [[ -f /workspace/web/.env ]]; then
  chown node:node /workspace/web/.env
  chmod 640 /workspace/web/.env
fi
if [[ -f /workspace/web/.env.local ]]; then
  chown node:node /workspace/web/.env.local
  chmod 640 /workspace/web/.env.local
fi

cd /workspace/web
exec gosu node bash -lc 'npm install && npm run dev -- --hostname 0.0.0.0 --port 3000'
