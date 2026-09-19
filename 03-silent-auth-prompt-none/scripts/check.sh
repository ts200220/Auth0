#!/usr/bin/env bash
# 記事 03 の前提チェック（lab コンテナ内で実行）
set -euo pipefail

echo "== versions =="
node -v
npm -v
auth0 --version

echo
echo "== Next.js app =="
if [[ -f /workspace/web/package.json ]]; then
  echo "web/package.json: OK"
  if [[ -d /workspace/web/node_modules/next ]]; then
    echo "next installed: OK"
  else
    echo "next installed: (not yet — run: docker compose up web)"
  fi
else
  echo "ERROR: web/package.json がありません"
  exit 1
fi

echo
echo "== auth0 config =="
ls -la "${XDG_CONFIG_HOME:-$HOME/.config}/auth0" 2>/dev/null || echo "(empty — run: auth0 login)"

echo
echo "OK: Next.js + Auth0 CLI の環境です。"
echo "Next.js: docker compose up web → http://localhost:3000"
echo "CLI:     auth0 login → auth0 tenants list → auth0 tenants use"
