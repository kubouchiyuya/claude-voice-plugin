<div align="center">

<a href="./README.md"><img src="https://img.shields.io/badge/🌐%20English-active-F97316?style=flat-square" /></a>
<a href="./README_ja.md"><img src="https://img.shields.io/badge/🇯🇵%20日本語-gray?style=flat-square" /></a>

<br/><br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=12,20,30&height=200&section=header&text=claude-voice-plugin&fontSize=40&fontColor=fff&animation=fadeIn&desc=Zero-Context%20Voice%20Plugin%20for%20Claude%20Code&descSize=18&descAlignY=70" width="100%"/>

<img src="https://raw.githubusercontent.com/kubouchiyuya/kubouchiyuya/main/avatar.jpg" width="120" style="border-radius:50%; margin-top:16px"/>

[![Typing SVG](https://readme-typing-svg.demolab.com?font=Fira+Code&weight=700&size=22&duration=3000&pause=1000&color=F97316&center=true&vCenter=true&multiline=true&width=900&height=140&lines=Zero+Context+Cost+%F0%9F%94%87;Hooks-Based+Auto+Notify+%E2%80%94+No+MCP+Server+Needed;VOICEVOX+Powered+%E2%80%94+Free+%26+Local)](https://github.com/DenverCoder1/readme-typing-svg)

[![GitHub](https://img.shields.io/badge/GitHub-kubouchiyuya-181717?style=for-the-badge&logo=github)](https://github.com/kubouchiyuya)
[![X](https://img.shields.io/badge/@kubouchiyuya-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/kubouchiyuya)
[![LP](https://img.shields.io/badge/Consulting%20LP-F97316?style=for-the-badge&logo=vercel&logoColor=white)](https://consulting-payment-tool.vercel.app)

![Stars](https://img.shields.io/github/stars/kubouchiyuya/claude-voice-plugin?style=flat-square&color=F97316)
![Forks](https://img.shields.io/github/forks/kubouchiyuya/claude-voice-plugin?style=flat-square&color=gray)
![License](https://img.shields.io/github/license/kubouchiyuya/claude-voice-plugin?style=flat-square)
<img src="https://komarev.com/ghpvc/?username=kubouchiyuya&label=Views&color=F97316&style=flat-square"/>

</div>

---

## What This Does

This repository provides the plugin edition of voice notifications for Claude Code. It uses Claude Code Hooks so the automation runs without a standing MCP server and without consuming context tokens.

That makes it the lightest-weight option in the voice stack: local, fast, and ready to attach directly to a Claude Code workflow.

---

## ✨ Features

| Feature | Description |
|---|---|
| Zero context cost | Hooks-triggered notification with no always-on process |
| Local VOICEVOX | Free default engine on your machine |
| Optional cloud TTS | Switch providers with configuration only |
| `/voice` command | Manage voice behavior from inside Claude Code |
| VS Code support | Toggle voice behavior in the editor |
| Bash-first design | Simple shell workflow for automation |

---

## 🚀 Quick Start

### Star First

> This repo follows the same star-gated philosophy as the MCP version.

### Install

```bash
git clone https://github.com/kubouchiyuya/claude-voice-plugin.git \
  ~/.claude/plugins/voice-notify
```

### Enable

```json
{
  "enabledPlugins": {
    "voice-notify": true
  }
}
```

### Test

```bash
~/.claude/plugins/voice-notify/scripts/notify.sh "Plugin active"
```

---

## 🏗️ Architecture

```mermaid
graph TD
    A[Claude Code] -->|Stop / Notification| B[hooks/hooks.json]
    B -->|shell| C[scripts/notify.sh]
    C --> D{Provider}
    D -->|default| E[VOICEVOX localhost:50021]
    D -->|optional| F[Google Cloud TTS]
    E --> G[afplay / system playback]
    F --> G
    A -->|/voice command| H[commands/voice.md]
    H --> C
    A -->|on-demand help| I[skills/voice-notify/SKILL.md]
    I --> C
```

---

## 🛠️ Tech Stack

![Shell](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![VOICEVOX](https://img.shields.io/badge/VOICEVOX-Free-brightgreen?style=for-the-badge)
![Claude%20Code](https://img.shields.io/badge/Claude%20Code-Plugin-F97316?style=for-the-badge)
![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)

---

## 👤 Author

<div align="center">

| | |
|---|---|
| **Yuya Kubouchi (MASA2 / MASA Sub)** | Beauty Salon Owner → AI Architect |
| Location | Osaka, Japan |
| System | AKATSUKI / Miyabi Society |
| Identity | AI × Beauty Industry × Non-Engineer |

*"I do not code first. I design the workflow and let AI execute it."*

</div>

---

<div align="center">

**If this plugin saved tokens, give it a star.**

</div>
