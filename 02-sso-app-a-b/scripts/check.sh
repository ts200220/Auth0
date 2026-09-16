#!/usr/bin/env bash
# 記事 02 の前提チェック（lab コンテナ内で実行）
set -euo pipefail

echo "== versions =="
node -v
npm -v
auth0 --version

echo
echo "== Next.js apps =="
for app in web web-b; do
  if [[ -f "/workspace/${app}/package.json" ]]; then
    echo "${app}/package.json: OK"
  else
    echo "ERROR: ${app}/package.json がありません"
    exit 1
  fi
done

echo
echo "== auth0 config =="
ls -la "${XDG_CONFIG_HOME:-$HOME/.config}/auth0" 2>/dev/null || echo "(empty — run: auth0 login)"

echo
echo "OK: App A/B + Auth0 CLI の環境です。"
echo "App A: docker compose up -d web     → http://localhost:3000"
echo "App B: docker compose up -d web-b   → http://localhost:3001"
echo "CLI:   auth0 login → auth0 tenants list → auth0 tenants use"
