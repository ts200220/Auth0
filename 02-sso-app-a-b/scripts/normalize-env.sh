#!/usr/bin/env bash
# web/.env または web-b/.env を正規化する（Linux ホスト想定）
# - 余分な \r を除去
# - AUTH0_* / APP_* の値から囲みクォートを外す
#
# 使い方:
#   bash scripts/normalize-env.sh
#   bash scripts/normalize-env.sh /workspace/web/.env
#   bash scripts/normalize-env.sh /workspace/web-b/.env

set -euo pipefail

ENV_FILE="${1:-}"
if [[ -z "$ENV_FILE" ]]; then
  if [[ -f /workspace/web/.env ]]; then
    ENV_FILE=/workspace/web/.env
  elif [[ -f "$(dirname "$0")/../web/.env" ]]; then
    ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/web/.env"
  else
    echo "normalize-env: .env がありません（スキップ）"
    exit 0
  fi
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "normalize-env: not found: $ENV_FILE（スキップ）"
  exit 0
fi

tmp="$(mktemp)"
tr -d '\r' < "$ENV_FILE" | sed -E \
  -e 's/^(AUTH0_[A-Z0-9_]+)="([^"]*)"/\1=\2/' \
  -e "s/^(AUTH0_[A-Z0-9_]+)='([^']*)'/\\1=\\2/" \
  -e 's/^(APP_[A-Z0-9_]+)="([^"]*)"/\1=\2/' \
  -e "s/^(APP_[A-Z0-9_]+)='([^']*)'/\\1=\\2/" \
  > "$tmp"

mv "$tmp" "$ENV_FILE"
chmod 640 "$ENV_FILE" 2>/dev/null || true
chown node:node "$ENV_FILE" 2>/dev/null || true
echo "normalize-env: OK ($ENV_FILE)"
