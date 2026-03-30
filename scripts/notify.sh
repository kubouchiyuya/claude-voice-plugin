#!/bin/bash
# claude-voice-notify - スタンドアロン音声通知スクリプト
#
# 使い方:
#   ./notify.sh "メッセージ"                          # デフォルトキャラで読み上げ
#   ./notify.sh "メッセージ" complete 3 1.2           # タイプ/スピーカーID/速度を指定
#   ./notify.sh list                                  # VOICEVOXキャラクター一覧
#   ./notify.sh set-speaker 3                         # デフォルトキャラを変更
#   ./notify.sh set-provider google                   # プロバイダー変更 (voicevox/google)
#   ./notify.sh set-volume 0.5                         # デフォルト音量変更 (0.0〜1.0)
#   ./notify.sh on / off / status                     # 音声オン/オフ

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STATE_FILE="$SCRIPT_DIR/.voice-enabled"
CONFIG_FILE="$SCRIPT_DIR/.voice-config"
VOICEVOX_URL="${VOICEVOX_URL:-http://localhost:50021}"

# --- 設定の読み込み ---
DEFAULT_SPEAKER="${VOICEVOX_SPEAKER:-3}"
DEFAULT_PROVIDER="voicevox"
DEFAULT_SPEED="1.0"
DEFAULT_VOLUME="1.0"
GOOGLE_VOICE="${GOOGLE_TTS_VOICE:-ja-JP-Neural2-B}"
GOOGLE_API_KEY="${GOOGLE_TTS_API_KEY:-}"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

# --- コマンド処理 ---
case "$1" in
  on)
    echo "1" > "$STATE_FILE"
    echo "[claude-voice-notify] 音声通知: ON"
    exit 0
    ;;
  off)
    echo "0" > "$STATE_FILE"
    echo "[claude-voice-notify] 音声通知: OFF"
    exit 0
    ;;
  status)
    ENABLED="ON"
    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "0" ]; then
      ENABLED="OFF"
    fi
    echo "[claude-voice-notify]"
    echo "  音声通知: $ENABLED"
    echo "  プロバイダー: $DEFAULT_PROVIDER"
    echo "  スピーカーID: $DEFAULT_SPEAKER"
    echo "  速度: $DEFAULT_SPEED"
    echo "  音量: $DEFAULT_VOLUME"
    exit 0
    ;;
  list)
    echo "[claude-voice-notify] VOICEVOXキャラクター一覧:"
    echo ""
    if curl -s --max-time 2 "$VOICEVOX_URL/speakers" > /dev/null 2>&1; then
      curl -s "$VOICEVOX_URL/speakers" | python3 -c "
import json, sys
speakers = json.load(sys.stdin)
for s in speakers:
    for st in s['styles']:
        marker = ' ★' if st['id'] == int('${DEFAULT_SPEAKER}') else ''
        print(f'  {st[\"id\"]:3d}: {s[\"name\"]}（{st[\"name\"]}）{marker}')
"
    else
      echo "  VOICEVOXに接続できません。起動してください。"
    fi
    exit 0
    ;;
  set-speaker)
    NEW_SPEAKER="${2:-}"
    if [ -z "$NEW_SPEAKER" ]; then
      echo "使い方: notify.sh set-speaker <ID>"
      echo "キャラ一覧: notify.sh list"
      exit 1
    fi
    # 設定ファイルを更新
    if [ -f "$CONFIG_FILE" ]; then
      grep -v "^DEFAULT_SPEAKER=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "DEFAULT_SPEAKER=$NEW_SPEAKER" >> "$CONFIG_FILE"
    # キャラ名を取得
    CHAR_NAME=$(curl -s --max-time 2 "$VOICEVOX_URL/speakers" 2>/dev/null | python3 -c "
import json, sys
speakers = json.load(sys.stdin)
for s in speakers:
    for st in s['styles']:
        if st['id'] == int('$NEW_SPEAKER'):
            print(f'{s[\"name\"]}（{st[\"name\"]}）')
            sys.exit()
print('ID $NEW_SPEAKER')
" 2>/dev/null || echo "ID $NEW_SPEAKER")
    echo "[claude-voice-notify] デフォルトキャラを変更: $CHAR_NAME (ID: $NEW_SPEAKER)"
    exit 0
    ;;
  set-provider)
    NEW_PROVIDER="${2:-}"
    if [ -z "$NEW_PROVIDER" ]; then
      echo "使い方: notify.sh set-provider <voicevox|google>"
      exit 1
    fi
    if [ -f "$CONFIG_FILE" ]; then
      grep -v "^DEFAULT_PROVIDER=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "DEFAULT_PROVIDER=$NEW_PROVIDER" >> "$CONFIG_FILE"
    echo "[claude-voice-notify] プロバイダーを変更: $NEW_PROVIDER"
    exit 0
    ;;
  set-volume)
    NEW_VOLUME="${2:-1.0}"
    if ! python3 -c "v=float('$NEW_VOLUME'); assert 0.0<=v<=1.0" 2>/dev/null; then
      echo "エラー: 音量は 0.0〜1.0 の範囲で指定してください"
      exit 1
    fi
    if [ -f "$CONFIG_FILE" ]; then
      grep -v "^DEFAULT_VOLUME=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "DEFAULT_VOLUME=$NEW_VOLUME" >> "$CONFIG_FILE"
    echo "[claude-voice-notify] デフォルト音量を変更: ${NEW_VOLUME}"
    exit 0
    ;;
  set-speed)
    NEW_SPEED="${2:-1.0}"
    if [ -f "$CONFIG_FILE" ]; then
      grep -v "^DEFAULT_SPEED=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "DEFAULT_SPEED=$NEW_SPEED" >> "$CONFIG_FILE"
    echo "[claude-voice-notify] デフォルト速度を変更: ${NEW_SPEED}x"
    exit 0
    ;;
  set-google-key)
    NEW_KEY="${2:-}"
    if [ -z "$NEW_KEY" ]; then
      echo "使い方: notify.sh set-google-key <API_KEY>"
      exit 1
    fi
    if [ -f "$CONFIG_FILE" ]; then
      grep -v "^GOOGLE_API_KEY=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "GOOGLE_API_KEY=$NEW_KEY" >> "$CONFIG_FILE"
    echo "[claude-voice-notify] Google TTS APIキーを設定しました"
    exit 0
    ;;
  set-google-voice)
    NEW_VOICE="${2:-ja-JP-Neural2-B}"
    if [ -f "$CONFIG_FILE" ]; then
      grep -v "^GOOGLE_VOICE=" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" || true
      mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    fi
    echo "GOOGLE_VOICE=$NEW_VOICE" >> "$CONFIG_FILE"
    echo "[claude-voice-notify] Google TTS音声を変更: $NEW_VOICE"
    exit 0
    ;;
esac

# --- 音声が無効なら即終了 ---
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "0" ]; then
  exit 0
fi

# --- メッセージ解析 ---
MESSAGE="${1:-}"
TYPE="${2:-complete}"
SPEAKER="${3:-$DEFAULT_SPEAKER}"
SPEED="${4:-$DEFAULT_SPEED}"
PROVIDER="${NOTIFY_PROVIDER:-$DEFAULT_PROVIDER}"

if [ -z "$MESSAGE" ]; then
  case "$TYPE" in
    complete) MESSAGE="タスクが完了しました" ;;
    confirm)  MESSAGE="確認をお願いします" ;;
    error)    MESSAGE="エラーが発生しました" ;;
    explain)  MESSAGE="解説を開始します" ;;
    *)        MESSAGE="お知らせがあります" ;;
  esac
fi

# --- VOICEVOX ---
try_voicevox() {
  if ! curl -s --max-time 0.5 "$VOICEVOX_URL/version" > /dev/null 2>&1; then
    return 1
  fi

  ENCODED_TEXT=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$MESSAGE" 2>/dev/null)
  QUERY=$(curl -s --max-time 5 -X POST \
    "$VOICEVOX_URL/audio_query?text=${ENCODED_TEXT}&speaker=$SPEAKER")

  if [ -z "$QUERY" ]; then
    return 1
  fi

  # 速度・音量調整
  QUERY=$(echo "$QUERY" | python3 -c "
import json,sys
q = json.load(sys.stdin)
q['speedScale'] = float(sys.argv[1])
q['volumeScale'] = float(sys.argv[2])
print(json.dumps(q))
" "$SPEED" "$DEFAULT_VOLUME" 2>/dev/null || echo "$QUERY")

  TMPFILE=$(mktemp /tmp/claude-voice-XXXXXX.wav)
  HTTP_CODE=$(curl -s -o "$TMPFILE" -w "%{http_code}" --max-time 30 -X POST \
    -H "Content-Type: application/json" \
    -d "$QUERY" \
    "$VOICEVOX_URL/synthesis?speaker=$SPEAKER")

  if [ "$HTTP_CODE" = "200" ] && [ -s "$TMPFILE" ]; then
    afplay -v "$DEFAULT_VOLUME" "$TMPFILE" 2>/dev/null
    rm -f "$TMPFILE" 2>/dev/null
    return 0
  else
    rm -f "$TMPFILE" 2>/dev/null
    return 1
  fi
}

# --- Google Cloud TTS ---
try_google_tts() {
  if [ -z "$GOOGLE_API_KEY" ]; then
    echo "[claude-voice-notify] Google TTS APIキーが未設定です。notify.sh set-google-key <KEY> で設定してください" >&2
    return 1
  fi

  TMPFILE=$(mktemp /tmp/claude-voice-XXXXXX.mp3)

  RESPONSE=$(curl -s --max-time 10 -X POST \
    "https://texttospeech.googleapis.com/v1/text:synthesize?key=$GOOGLE_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"input\": {\"text\": $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$MESSAGE")},
      \"voice\": {\"languageCode\": \"ja-JP\", \"name\": \"$GOOGLE_VOICE\"},
      \"audioConfig\": {\"audioEncoding\": \"MP3\", \"speakingRate\": $SPEED}
    }")

  AUDIO_CONTENT=$(echo "$RESPONSE" | python3 -c "
import json,sys,base64
data = json.load(sys.stdin)
if 'audioContent' in data:
    sys.stdout.buffer.write(base64.b64decode(data['audioContent']))
else:
    print(data.get('error',{}).get('message','Unknown error'), file=sys.stderr)
    sys.exit(1)
" > "$TMPFILE" 2>&1)

  if [ $? -eq 0 ] && [ -s "$TMPFILE" ]; then
    afplay -v "$DEFAULT_VOLUME" "$TMPFILE" 2>/dev/null
    rm -f "$TMPFILE" 2>/dev/null
    return 0
  else
    echo "[claude-voice-notify] Google TTS エラー: $AUDIO_CONTENT" >&2
    rm -f "$TMPFILE" 2>/dev/null
    return 1
  fi
}

# --- メイン ---
case "$PROVIDER" in
  voicevox)
    if ! try_voicevox; then
      echo "[claude-voice-notify] VOICEVOXに接続できません。起動してください (http://localhost:50021)" >&2
      exit 1
    fi
    ;;
  google)
    if ! try_google_tts; then
      exit 1
    fi
    ;;
  *)
    echo "[claude-voice-notify] 未対応プロバイダー: $PROVIDER (voicevox / google)" >&2
    exit 1
    ;;
esac
