#!/bin/bash
# claude-voice-notify クイック設定パネル
# VSCode のタスクやキーボードショートカットから呼び出し可能

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NOTIFY="$SCRIPT_DIR/notify.sh"
CONFIG_FILE="$SCRIPT_DIR/.voice-config"
VOICEVOX_URL="${VOICEVOX_URL:-http://localhost:50021}"

# 設定読み込み
DEFAULT_SPEAKER=3
DEFAULT_SPEED="1.3"
DEFAULT_VOLUME="0.3"
DEFAULT_PROVIDER="voicevox"
VOICE_LANG="ja"
TERM_EXPLAIN="on"
VOICE_ENABLED="on"
if [ -f "$CONFIG_FILE" ]; then source "$CONFIG_FILE"; fi

# 現在のキャラ名取得
get_char_name() {
  curl -s --max-time 1 "$VOICEVOX_URL/speakers" 2>/dev/null | python3 -c "
import json, sys
speakers = json.load(sys.stdin)
for s in speakers:
    for st in s['styles']:
        if st['id'] == int('$DEFAULT_SPEAKER'):
            print(f'{s[\"name\"]}（{st[\"name\"]}）')
            sys.exit()
print('ID $DEFAULT_SPEAKER')
" 2>/dev/null || echo "ID $DEFAULT_SPEAKER"
}

show_menu() {
  clear 2>/dev/null || true
  CHAR_NAME=$(get_char_name)
  ENABLED="🔊 ON"
  if [ "${VOICE_ENABLED:-on}" = "off" ] || { [ -f "$SCRIPT_DIR/.voice-enabled" ] && [ "$(cat "$SCRIPT_DIR/.voice-enabled")" = "0" ]; }; then
    ENABLED="🔇 OFF"
  fi
  LANG_LABEL="日本語 (ja)"
  if [ "${VOICE_LANG:-ja}" = "en" ]; then LANG_LABEL="English (en)"; fi
  TE_LABEL="ON"
  if [ "${TERM_EXPLAIN:-on}" = "off" ]; then TE_LABEL="OFF"; fi

  echo ""
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║    ⚙️  VB 設定パネル                      ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo ""
  echo "  現在の設定:"
  echo "  ─────────────────────────────────────────"
  echo "  音声: $ENABLED"
  echo "  キャラ: $CHAR_NAME (ID: $DEFAULT_SPEAKER)"
  echo "  速度: ${DEFAULT_SPEED}x"

  # 速度ゲージ表示
  show_speed_gauge "$DEFAULT_SPEED"

  echo "  音量: ${DEFAULT_VOLUME}"

  # 音量ゲージ表示
  show_volume_gauge "$DEFAULT_VOLUME"

  echo "  エンジン: $DEFAULT_PROVIDER"
  echo "  言語: $LANG_LABEL"
  echo "  用語説明: $TE_LABEL"
  echo "  ─────────────────────────────────────────"
  echo ""
  echo "  操作:"
  echo "    1) 🔊 音声 ON/OFF（現在: $ENABLED）"
  echo "    2) 🔉 音量設定（0.1〜1.0）"
  echo "    3) ⏩ 速度設定（0.5〜2.0）"
  echo "    4) 🎤 キャラクター設定"
  echo "    5) 🗾 言語設定（ja/en）（現在: $LANG_LABEL）"
  echo "    6) 📚 用語説明モード ON/OFF（現在: $TE_LABEL）"
  echo "    7) 🔧 エンジン変更"
  echo "    8) 🔊 テスト再生"
  echo "    9) 🗾 方言で選ぶ"
  echo "    q) 閉じる"
  echo ""
  read -p "  選択: " CHOICE
}

show_speed_gauge() {
  local speed=$1
  local gauge=""
  # 0.5 〜 2.0 を 30文字のゲージで表現
  local pos=$(python3 -c "print(int(($speed - 0.5) / 1.5 * 30))" 2>/dev/null || echo 10)
  local i=0
  gauge="  速度: 0.5x ["
  while [ $i -lt 30 ]; do
    if [ $i -eq $pos ]; then
      gauge="${gauge}●"
    else
      gauge="${gauge}─"
    fi
    i=$((i+1))
  done
  gauge="${gauge}] 2.0x"
  echo "$gauge"
}

show_volume_gauge() {
  local vol=$1
  local gauge=""
  # 0.0 〜 1.0 を 30文字のゲージで表現
  local pos=$(python3 -c "print(int($vol / 1.0 * 30))" 2>/dev/null || echo 30)
  local i=0
  gauge="  音量: 0.0  ["
  while [ $i -lt 30 ]; do
    if [ $i -eq $pos ]; then
      gauge="${gauge}●"
    elif [ $i -lt $pos ]; then
      gauge="${gauge}█"
    else
      gauge="${gauge}─"
    fi
    i=$((i+1))
  done
  gauge="${gauge}] 1.0"
  echo "$gauge"
}

volume_adjust() {
  while true; do
    clear 2>/dev/null || true
    echo ""
    echo "  🔉 音量調整"
    echo ""
    show_volume_gauge "$DEFAULT_VOLUME"
    echo ""
    echo "  現在: ${DEFAULT_VOLUME}"
    echo ""
    echo "    +) 大きくする (+0.1)"
    echo "    -) 小さくする (-0.1)"
    echo "    数字) 直接入力 (例: 0.5)"
    echo "    t) この音量でテスト再生"
    echo "    q) 戻る"
    echo ""
    read -p "  選択: " VCHOICE

    case "$VCHOICE" in
      +)
        DEFAULT_VOLUME=$(python3 -c "print(min(1.0, round($DEFAULT_VOLUME + 0.1, 1)))")
        "$NOTIFY" set-volume "$DEFAULT_VOLUME" > /dev/null
        ;;
      -)
        DEFAULT_VOLUME=$(python3 -c "print(max(0.0, round($DEFAULT_VOLUME - 0.1, 1)))")
        "$NOTIFY" set-volume "$DEFAULT_VOLUME" > /dev/null
        ;;
      t)
        "$NOTIFY" "この音量はどうですか？聞き取りやすいですか？" complete
        ;;
      q|Q)
        return
        ;;
      *)
        if python3 -c "v=float('$VCHOICE'); assert 0.0<=v<=1.0" 2>/dev/null; then
          DEFAULT_VOLUME="$VCHOICE"
          "$NOTIFY" set-volume "$DEFAULT_VOLUME" > /dev/null
        else
          echo "  ⚠️ 0.0〜1.0 の範囲で入力してください"
          sleep 1
        fi
        ;;
    esac
  done
}

speed_adjust() {
  while true; do
    clear 2>/dev/null || true
    echo ""
    echo "  ⏩ 速度調整"
    echo ""
    show_speed_gauge "$DEFAULT_SPEED"
    echo ""
    echo "  現在: ${DEFAULT_SPEED}x"
    echo ""
    echo "    +) 速くする (+0.1)"
    echo "    -) 遅くする (-0.1)"
    echo "    数字) 直接入力 (例: 1.3)"
    echo "    t) この速度でテスト再生"
    echo "    q) 戻る"
    echo ""
    read -p "  選択: " SCHOICE

    case "$SCHOICE" in
      +)
        DEFAULT_SPEED=$(python3 -c "print(min(2.0, round($DEFAULT_SPEED + 0.1, 1)))")
        "$NOTIFY" set-speed "$DEFAULT_SPEED" > /dev/null
        ;;
      -)
        DEFAULT_SPEED=$(python3 -c "print(max(0.5, round($DEFAULT_SPEED - 0.1, 1)))")
        "$NOTIFY" set-speed "$DEFAULT_SPEED" > /dev/null
        ;;
      t)
        "$NOTIFY" "この速度はどうですか？聞き取りやすいですか？" complete
        ;;
      q|Q)
        return
        ;;
      *)
        if python3 -c "v=float('$SCHOICE'); assert 0.5<=v<=2.0" 2>/dev/null; then
          DEFAULT_SPEED="$SCHOICE"
          "$NOTIFY" set-speed "$DEFAULT_SPEED" > /dev/null
        else
          echo "  ⚠️ 0.5〜2.0 の範囲で入力してください"
          sleep 1
        fi
        ;;
    esac
  done
}

dialect_select() {
  clear 2>/dev/null || true
  echo ""
  echo "  🗾 方言・地域で選ぶ"
  echo ""

  curl -s "$VOICEVOX_URL/speakers" 2>/dev/null | python3 -c "
import json, sys

speakers = json.load(sys.stdin)

# 方言・地域カテゴリ
regions = {
    '東北弁': {
        'chars': ['東北ずん子', '東北きりたん', '東北イタコ', 'ずんだもん', 'あんこもん'],
        'desc': '東北地方の温かみのあるイントネーション'
    },
    '標準語': {
        'chars': ['四国めたん', '春日部つむぎ', '冥鳴ひまり', 'もち子さん', 'WhiteCUL',
                  '櫻歌ミコ', '小夜/SAYO', '春歌ナナ', '琴詠ニア', 'No.7',
                  'ナースロボ＿タイプＴ', '猫使アル', '猫使ビィ', '満別花丸',
                  '黒沢冴白', 'ユーレイちゃん', 'ぞん子', 'あいえるたん', '栗田まろん'],
        'desc': '標準的な日本語アクセント'
    },
    '九州弁': {
        'chars': ['九州そら'],
        'desc': '九州地方の明るいイントネーション'
    },
    '中部弁': {
        'chars': ['中部つるぎ'],
        'desc': '中部地方のイントネーション'
    },
    '中国地方': {
        'chars': ['中国うさぎ'],
        'desc': '中国地方のやわらかいイントネーション'
    },
    '男性キャラ（標準語）': {
        'chars': ['玄野武宏', '白上虎太郎', '青山龍星', '剣崎雌雄',
                  '†聖騎士 紅桜†', '雀松朱司', '麒ヶ島宗麟', '離途', 'Voidoll'],
        'desc': '男性の標準語ボイス'
    },
    '特殊': {
        'chars': ['後鬼', 'ちび式じい', '雨晴はう', '波音リツ'],
        'desc': '個性的なキャラクターボイス'
    },
}

for region, info in regions.items():
    entries = []
    for s in speakers:
        if s['name'] in info['chars']:
            for st in s['styles']:
                entries.append((st['id'], s['name'], st['name']))
    if entries:
        print(f'  【{region}】 - {info[\"desc\"]}')
        for sid, name, style in entries[:5]:
            print(f'    {sid:3d}: {name}（{style}）')
        if len(entries) > 5:
            print(f'    ... 他 {len(entries)-5} スタイル')
        print()
" 2>/dev/null || true

  echo ""
  read -p "  スピーカーID (戻る: q): " DID
  if [ "$DID" != "q" ] && [ -n "$DID" ]; then
    "$NOTIFY" set-speaker "$DID"
    DEFAULT_SPEAKER="$DID"
    "$NOTIFY" "この方言はどうですか？気に入ってもらえると嬉しいな！" complete
  fi
}

character_select() {
  clear 2>/dev/null || true
  echo ""
  echo "  🎤 キャラクター変更"
  echo ""
  echo "  フィルター:"
  echo "    1) 女性キャラ"
  echo "    2) 男性キャラ"
  echo "    3) 全て表示"
  echo ""
  read -p "  選択 [3]: " GFILTER
  GFILTER="${GFILTER:-3}"

  curl -s "$VOICEVOX_URL/speakers" 2>/dev/null | python3 -c "
import json, sys
speakers = json.load(sys.stdin)
g = '$GFILTER'

female = ['ずんだもん','四国めたん','春日部つむぎ','雨晴はう','波音リツ',
          '冥鳴ひまり','九州そら','もち子さん','WhiteCUL','櫻歌ミコ',
          '小夜/SAYO','春歌ナナ','猫使アル','猫使ビィ','中国うさぎ',
          '栗田まろん','あいえるたん','満別花丸','琴詠ニア','ぞん子',
          'ユーレイちゃん','東北ずん子','東北きりたん','東北イタコ',
          'あんこもん','ナースロボ＿タイプＴ','No.7','黒沢冴白']
male = ['玄野武宏','白上虎太郎','青山龍星','剣崎雌雄','後鬼',
        'ちび式じい','雀松朱司','麒ヶ島宗麟','†聖騎士 紅桜†',
        '中部つるぎ','離途','Voidoll']

for s in speakers:
    if g == '1' and s['name'] not in female: continue
    if g == '2' and s['name'] not in male: continue
    styles = ', '.join(f'{st[\"id\"]}:{st[\"name\"]}' for st in s['styles'])
    print(f'  {s[\"name\"]}: {styles}')
" 2>/dev/null || true

  echo ""
  read -p "  スピーカーID (戻る: q): " CID
  if [ "$CID" != "q" ] && [ -n "$CID" ]; then
    "$NOTIFY" set-speaker "$CID"
    DEFAULT_SPEAKER="$CID"
    "$NOTIFY" "キャラクターを変更しました！この声でお知らせしますね！" complete
  fi
}

lang_select() {
  echo ""
  echo "  🗾 言語設定"
  echo ""
  echo "    1) 日本語 (ja) — デフォルト"
  echo "    2) English (en)"
  echo "    q) 戻る"
  echo ""
  read -p "  選択: " LCHOICE
  case "$LCHOICE" in
    1)
      "$NOTIFY" set-lang ja
      VOICE_LANG="ja"
      ;;
    2)
      "$NOTIFY" set-lang en
      VOICE_LANG="en"
      ;;
    q|Q) return ;;
  esac
}

term_explain_toggle() {
  if [ "${TERM_EXPLAIN:-on}" = "on" ]; then
    "$NOTIFY" set-term-explain off
    TERM_EXPLAIN="off"
    "$NOTIFY" "用語説明をオフにしました。必要なときはいつでもオンに戻せますよ。" complete
  else
    "$NOTIFY" set-term-explain on
    TERM_EXPLAIN="on"
    "$NOTIFY" "用語説明モードをオンにしました。専門用語を分かりやすく説明します。" complete
  fi
}

# --- メインループ ---
while true; do
  show_menu
  case "$CHOICE" in
    1)
      if [ "${VOICE_ENABLED:-on}" = "off" ] || { [ -f "$SCRIPT_DIR/.voice-enabled" ] && [ "$(cat "$SCRIPT_DIR/.voice-enabled")" = "0" ]; }; then
        "$NOTIFY" on
        VOICE_ENABLED="on"
      else
        "$NOTIFY" off
        VOICE_ENABLED="off"
      fi
      ;;
    2) volume_adjust ;;
    3) speed_adjust ;;
    4) character_select ;;
    5) lang_select ;;
    6) term_explain_toggle ;;
    7)
      echo ""
      echo "  エンジン: voicevox / google / coeiroink / aivis_speech"
      echo "           style_bert_vits2 / fish_audio / elevenlabs / openai"
      read -p "  エンジン名: " NEW_ENG
      if [ -n "$NEW_ENG" ]; then
        "$NOTIFY" set-provider "$NEW_ENG"
        DEFAULT_PROVIDER="$NEW_ENG"
      fi
      ;;
    8)
      "$NOTIFY" "テスト再生です。この声とスピードで通知されます" complete
      ;;
    9) dialect_select ;;
    q|Q)
      echo "  設定を保存しました。"
      exit 0
      ;;
  esac
done
