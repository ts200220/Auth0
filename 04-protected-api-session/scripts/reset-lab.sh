#!/usr/bin/env bash
# 04 ラボを最初からやり直す（Auth0 App 削除 + ローカル .env 削除）
#
# ホスト（ラボのルート）から:
#   bash scripts/reset-lab.sh
#   bash scripts/reset-lab.sh --force
#
# lab コンテナ内から:
#   bash /workspace/scripts/reset-lab.sh
#
# オプション:
#   --force       確認プロンプトを出さない
#   --keep-app    Auth0 App は残し、ローカル .env だけ消す
#   --full        CLI ログイン（.auth0-config）も消す（次回 auth0 login が必要）
#   --no-recreate 終了後に web を --force-recreate しない（ホスト実行時のみ有効）
#
# 環境変数:
#   APP_NAME   削除対象の App 表示名（既定: my-next-04）

set -euo pipefail

APP_NAME="${APP_NAME:-my-next-04}"
FORCE=0
KEEP_APP=0
FULL=0
NO_RECREATE=0

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --keep-app) KEEP_APP=1 ;;
    --full) FULL=1 ;;
    --no-recreate) NO_RECREATE=1 ;;
    -h|--help)
      sed -n '2,20p' "$0"
      exit 0
      ;;
    *)
      echo "不明なオプション: $arg" >&2
      exit 2
      ;;
  esac
done

in_lab() {
  [[ -d /workspace/web ]] && command -v auth0 >/dev/null 2>&1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ホストから呼ばれたら lab 経由で実行（Auth0 CLI はこのイメージ側）
if ! in_lab; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "docker が必要です。または lab 内でこのスクリプトを実行してください。" >&2
    exit 1
  fi
  cd "$ROOT"
  echo "== host: lab コンテナで reset-lab を実行 =="
  # Git Bash が /workspace をホストパスへ書き換えないようにする（Linux では無害）
  export MSYS_NO_PATHCONV=1
  export MSYS2_ARG_CONV_EXCL='*'
  # compose の lab entrypoint を使わず、gosu node bash で実行する
  docker compose --profile cli run --rm --entrypoint gosu lab node \
    bash //workspace/scripts/reset-lab.sh "$@"
  status=$?
  if [[ $status -eq 0 && $NO_RECREATE -eq 0 ]]; then
    echo
    echo "== host: web を作り直す =="
    docker compose up -d --force-recreate web
    echo "Open http://localhost:3000"
    echo "Next: lab -> auth0 login -> tenants use -> qs setup (if .env missing)"
  fi
  exit $status
fi

ENV_FILE="/workspace/web/.env"
ENV_LOCAL="/workspace/web/.env.local"
AUTH0_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/auth0"

echo "== reset-lab (APP_NAME=${APP_NAME}) =="
echo "tenant: $(auth0 tenants list 2>/dev/null | head -n 20 || true)"

if [[ $FORCE -eq 0 ]]; then
  echo
  echo "次を実行します:"
  [[ $KEEP_APP -eq 0 ]] && echo "  - Auth0 App「${APP_NAME}」（および .env の Client ID）を削除"
  echo "  - ${ENV_FILE} / ${ENV_LOCAL} を削除"
  [[ $FULL -eq 1 ]] && echo "  - CLI ログイン設定（${AUTH0_CONFIG_DIR}）を削除"
  echo
  read -r -p "続行しますか？ [y/N] " ans
  case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "中止しました"; exit 0 ;;
  esac
fi

read_env_client_id() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  # コメント行も許容（#AUTH0_CLIENT_ID=...）。囲みクォートは除去する
  grep -E '^[[:space:]]*#?[[:space:]]*AUTH0_CLIENT_ID=' "$f" \
    | head -n1 \
    | tr -d '\r' \
    | sed -E 's/^[[:space:]]*#?[[:space:]]*AUTH0_CLIENT_ID=//; s/^["'\'']//; s/["'\'']$//; s/[[:space:]]+$//' \
    || true
}

find_client_ids() {
  local ids=()
  local from_env
  from_env="$(read_env_client_id "$ENV_FILE")"
  if [[ -n "${from_env}" ]]; then
    ids+=("$from_env")
  fi

  if command -v jq >/dev/null 2>&1; then
    local json
    if json="$(auth0 apps list --json --no-input 2>/dev/null)"; then
      local by_name
      by_name="$(echo "$json" | jq -r --arg n "$APP_NAME" '
        (if type=="array" then . else .[]? // .apps? // empty end)
        | .[]? // .
        | select((.name // .Name // "") == $n)
        | (.client_id // .clientId // .ClientID // empty)
      ' 2>/dev/null | sort -u)"
      while IFS= read -r id; do
        [[ -n "$id" && "$id" != "null" ]] && ids+=("$id")
      done <<< "$by_name"
    fi
  fi

  # 重複除去
  printf '%s\n' "${ids[@]:-}" | awk 'NF && !seen[$0]++'
}

if [[ $KEEP_APP -eq 0 ]]; then
  echo
  echo "== Auth0 App を削除 =="
  if ! auth0 apps list --no-input >/dev/null 2>&1; then
    echo "Auth0 CLI にログインできていません。" >&2
    echo "先に: auth0 login && auth0 tenants use" >&2
    echo "（delete にはアプリ削除権限が必要です。期限切れなら再ログイン）" >&2
    exit 1
  fi

  mapfile -t CLIENT_IDS < <(find_client_ids)
  if [[ ${#CLIENT_IDS[@]} -eq 0 ]]; then
    echo "削除対象の Client ID が見つかりません（App「${APP_NAME}」または .env）。スキップします。"
  else
    for cid in "${CLIENT_IDS[@]}"; do
      cid="${cid//$'\r'/}"
      cid="$(printf '%s' "$cid" | tr -d '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
      [[ -z "$cid" ]] && continue
      echo "delete: $cid"
      auth0 apps delete "$cid" --force --no-input
    done
  fi
fi

echo
echo "== ローカル .env を削除 =="
rm -f "$ENV_FILE" "$ENV_LOCAL"
echo "removed: $ENV_FILE $ENV_LOCAL（存在すれば）"

if [[ $FULL -eq 1 ]]; then
  echo
  echo "== CLI ログイン設定を削除 =="
  # ホストの .auth0-config は compose でマウントされる想定
  if [[ -d /workspace/.auth0-config ]]; then
    rm -rf /workspace/.auth0-config/*
    echo "cleared: /workspace/.auth0-config"
  fi
  if [[ -d "$AUTH0_CONFIG_DIR" ]]; then
    rm -f "$AUTH0_CONFIG_DIR"/config.json "$AUTH0_CONFIG_DIR"/*.json 2>/dev/null || true
    echo "cleared: $AUTH0_CONFIG_DIR (json)"
  fi
fi

echo
echo "完了。次は App / .env を作り直す:"
echo
echo "  docker compose --profile cli run --rm lab"
echo
echo "  # lab 内:"
echo "  auth0 tenants use"
echo "  cd /workspace/web"
echo "  auth0 qs setup --app --type regular --framework nextjs --name ${APP_NAME} --port 3000 --no-input"
echo "  bash /workspace/scripts/normalize-env.sh"
echo "  grep -E '^(AUTH0_|APP_)' .env | sed 's/=.*/=***/'"
echo "  exit"
echo
echo "  # ホスト:"
echo "  docker compose up -d --force-recreate web"
echo "  # → http://localhost:3000"
