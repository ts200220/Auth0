#!/usr/bin/env bash
# Windows Docker Desktop でも node_modules / .env にアクセスできるようにする
set -euo pipefail

mkdir -p /workspace/web/node_modules /workspace/web/.next
chown -R node:node /workspace/web/node_modules /workspace/web/.next 2>/dev/null || true

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
