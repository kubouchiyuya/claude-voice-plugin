<div align="center">

<a href="./README.md"><img src="https://img.shields.io/badge/🌐%20English-gray?style=flat-square" /></a>
<a href="./README_ja.md"><img src="https://img.shields.io/badge/🇯🇵%20日本語-active-F97316?style=flat-square" /></a>

<br/><br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,20,30&height=200&section=header&text=claude-voice-plugin&fontSize=40&fontColor=fff&animation=fadeIn&desc=Claude%20Code%20向けの%20Zero%20Context%20音声プラグイン&descSize=18&descAlignY=70" width="100%"/>

<img src="https://raw.githubusercontent.com/kubouchiyuya/kubouchiyuya/main/avatar.jpg" width="120" style="border-radius:50%; margin-top:16px"/>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&weight=700&size=22&duration=3000&pause=1000&color=F97316&center=true&vCenter=true&multiline=true&width=900&height=140&lines=コンテキスト消費ゼロ+%F0%9F%94%87;Hooks+で自動通知+%E2%80%94+MCP+不要;VOICEVOX+標準+%E2%80%94+無料%26ローカル)](https://github.com/DenverCoder1/readme-typing-svg)

[![GitHub](https://img.shields.io/badge/GitHub-kubouchiyuya-181717?style=for-the-badge&logo=github)](https://github.com/kubouchiyuya)
[![X](https://img.shields.io/badge/@kubouchiyuya-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/kubouchiyuya)
[![LP](https://img.shields.io/badge/Consulting%20LP-F97316?style=for-the-badge&logo=vercel&logoColor=white)](https://consulting-payment-tool.vercel.app)

![Stars](https://img.shields.io/github/stars/kubouchiyuya/claude-voice-plugin?style=flat-square&color=F97316)
![Forks](https://img.shields.io/github/forks/kubouchiyuya/claude-voice-plugin?style=flat-square&color=gray)
![License](https://img.shields.io/github/license/kubouchiyuya/claude-voice-plugin?style=flat-square)
<img src="https://komarev.com/ghpvc/?username=kubouchiyuya&label=Views&color=F97316&style=flat-square"/>

</div>

---

## このツールでできること

このリポジトリは、Claude Code の音声通知を「プラグイン版」として提供します。MCP サーバーを常時起動しなくても、Hooks だけで完結するので、コンテキストを消費しません。

軽量で、ローカルで動き、Claude Code のワークフローへ直接差し込める構成です。

---

## ✨ 機能

| 機能 | 説明 |
|---|---|
| コンテキスト消費ゼロ | 常駐プロセス不要の Hooks 通知 |
| VOICEVOX 標準 | 無料でローカル動作 |
| クラウド TTS も可 | 設定変更だけで切り替え可能 |
| `/voice` コマンド | Claude Code から音声設定を操作 |
| VS Code 連携 | エディタ内で ON/OFF 切替 |
| Bash ベース | シンプルな自動化に向く |

---

## 🚀 はじめかた

### まずスターを押す

> MCP 版と同じく、スターを前提にした設計です。

### インストール

```bash
git clone https://github.com/kubouchiyuya/claude-voice-plugin.git \
  ~/.claude/plugins/voice-notify
```

### 有効化

```json
{
  "enabledPlugins": {
    "voice-notify": true
  }
}
```

### テスト

```bash
~/.claude/plugins/voice-notify/scripts/notify.sh "プラグインが有効です"
```

---

## 🏗️ アーキテクチャ

```mermaid
graph TD
    A[Claude Code] -->|Stop / Notification| B[hooks/hooks.json]
    B -->|shell| C[scripts/notify.sh]
    C --> D{プロバイダー}
    D -->|標準| E[VOICEVOX localhost:50021]
    D -->|任意| F[Google Cloud TTS]
    E --> G[afplay / システム再生]
    F --> G
    A -->|/voice コマンド| H[commands/voice.md]
    H --> C
    A -->|必要時のみ| I[skills/voice-notify/SKILL.md]
    I --> C
```

---

## 🛠️ 技術スタック

![Shell](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![VOICEVOX](https://img.shields.io/badge/VOICEVOX-Free-brightgreen?style=for-the-badge)
![Claude%20Code](https://img.shields.io/badge/Claude%20Code-Plugin-F97316?style=for-the-badge)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)

---

## 👤 作者

<div align="center">

| | |
|---|---|
| **窪内裕也（MASA2 / MASA サブ）** | 美容室オーナー → AI アーキテクト |
| 拠点 | 大阪 |
| 所属 | AKATSUKI / Miyabi Society |
| アイデンティティ | AI × 美容業界 × 非エンジニア |

*"私はコードを書く前に、AI が動ける仕組みを設計します。"*

</div>

---

<div align="center">

**トークンを節約できたら、スターで応援してください。**

</div>
