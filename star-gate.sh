#!/bin/bash
# スターゲート - スターなしでの使用を完全ブロック

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERIFIED_FILE="$SCRIPT_DIR/.star-verified"
REPO_OWNER="kubouchiyuya"
REPO_NAME="claude-voice-plugin"

check_star() {
  local repo_name="${1:-$REPO_NAME}"

  # すでに認証済みの場合はスキップ
  if [ -f "$VERIFIED_FILE" ]; then
    local cached_user
    cached_user=$(cat "$VERIFIED_FILE" 2>/dev/null)
    # キャッシュ有効期間: 7日（604800秒）
    local file_age
    file_age=$(( $(date +%s) - $(stat -f %m "$VERIFIED_FILE" 2>/dev/null || stat -c %Y "$VERIFIED_FILE" 2>/dev/null || echo 0) ))
    if [ "$file_age" -lt 604800 ]; then
      return 0  # 認証済み、通過
    fi
    # 期限切れ → 再チェック
  fi

  echo ""
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║   ⭐ Star Gate — 使用前認証が必要です     ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo ""
  echo "  このツールを使うには GitHub での Star が必要です。"
  echo "  https://github.com/$REPO_OWNER/$repo_name"
  echo ""
  echo "  ※ 「Star」とは？"
  echo "     GitHubの「お気に入り登録」機能です。"
  echo "     ページ右上の ☆ ボタンをクリックするだけです。"
  echo "     無料で、作者への応援になります。"
  echo ""

  local max_retries=3
  local attempt=0

  while [ $attempt -lt $max_retries ]; do
    read -r -p "  GitHubユーザー名を入力してください: " GITHUB_USER

    if [ -z "$GITHUB_USER" ]; then
      echo "  ❌ ユーザー名が空です。再度入力してください。"
      attempt=$((attempt + 1))
      continue
    fi

    echo "  🔍 @$GITHUB_USER のスター状態を確認中..."

    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/users/$GITHUB_USER/starred/$REPO_OWNER/$repo_name" 2>/dev/null)

    if [ "$http_code" = "204" ]; then
      echo ""
      echo "  ✅ @$GITHUB_USER さん、スターありがとうございます！"
      echo "  🎉 認証完了。ツールが使えるようになりました。"
      echo ""
      echo "$GITHUB_USER" > "$VERIFIED_FILE"
      return 0
    elif [ "$http_code" = "404" ]; then
      echo ""
      echo "  ❌ @$GITHUB_USER はまだスターを押していません。"
      echo ""
      echo "  以下のURLを開いて ☆ Star をクリックしてください:"
      echo "  → https://github.com/$REPO_OWNER/$repo_name"
      echo ""
      read -r -p "  ブラウザで開きますか？ [y/N]: " OPEN_BROWSER
      if [ "$OPEN_BROWSER" = "y" ] || [ "$OPEN_BROWSER" = "Y" ]; then
        open "https://github.com/$REPO_OWNER/$repo_name" 2>/dev/null || \
        xdg-open "https://github.com/$REPO_OWNER/$repo_name" 2>/dev/null || true
        echo "  Starを押したら、もう一度ユーザー名を入力してください。"
      fi
      attempt=$((attempt + 1))
    elif [ "$http_code" = "000" ] || [ "$http_code" = "0" ]; then
      echo "  ⚠️  ネットワークに接続できません。インターネット接続を確認してください。"
      exit 1
    else
      echo "  ⚠️  確認中にエラーが発生しました（HTTP $http_code）。"
      echo "  GitHubユーザー名が正しいか確認してください。"
      attempt=$((attempt + 1))
    fi
  done

  echo ""
  echo "  ❌ 認証に3回失敗しました。"
  echo "  Star後に再度実行してください:"
  echo "  https://github.com/$REPO_OWNER/$repo_name"
  echo ""
  exit 1
}
