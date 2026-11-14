# 🤖 Offline AI — Terminal Assistant

> A lightweight, fully offline AI assistant for your terminal — powered by **Qwen 2.5 1.5B** via Ollama.  
> Ask anything right from your shell. No internet needed, no API keys, no data leaving your machine.

<p align="center">
  <img src="https://img.shields.io/badge/model-Qwen%202.5%201.5B-blue?style=flat-square" alt="Model">
  <img src="https://img.shields.io/badge/size-~1GB-green?style=flat-square" alt="Size">
  <img src="https://img.shields.io/badge/license-MIT-yellow?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/version-1.11-orange?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/bash-4.0%2B-purple?style=flat-square" alt="Bash">
</p>

---

## 📖 Table of Contents

- [Features](#-features)
- [Demo](#-demo)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Color Coding](#-color-coding)
- [Configuration](#-configuration)
- [Files Created](#-files-created)
- [Uninstall](#-uninstall)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

---

## ✨ Features

- 🔒 **100% Offline** — runs entirely on your machine, no internet after install
- 🪶 **Lightweight** — only ~1GB model, works on CPU with just 2GB RAM
- 🎨 **Color-Coded Output** — headings, code, bullets, warnings auto-highlighted
- 🐚 **Shell Mode** — persistent `ai>` prompt with arrow-key history (↑ ↓)
- 🚀 **Auto-Start on Boot** — systemd service, works right after reboot
- 🌍 **Global Command** — works like `ls`, `pwd` from any directory
- 📥 **Unlimited Input** — pipe long files, code, logs directly into it
- 🎯 **Multiple Modes** — fast, deep, recommend, normal
- 🧠 **Context-Aware** — remembers chat history across sessions
- 🎛️ **Quiet Mode** — clean output, no banner (great for scripts)
- 🎨 **Markdown Rendering** — beautifies AI response with colors
- ⚡ **No API Keys** — nothing to configure, nothing to pay for

---

## 📸 Demo

```bash
$ ai --shell
   ___    ____    __  __ _ _
  /   |  |  _ \  |  \/  (_) |
 / /| |  | |_) | | |\/| | | |
/ ___ |  |  _ <  | |  | | | |
/_/  |_| |_| \_\ |_|  |_|_|_|
         O F F L I N E   A I
  Made by Chandan   (v1.11)
  GitHub:   https://github.com/chandan-44
  LinkedIn: https://linkedin.com/in/chandan-kumar-eh
  ──────────────────────────────────────────────

[Shell mode — type 'exit' or Ctrl+D to quit]
[Arrow keys ↑↓ = history | clear | multi | -f/-d/-r/-n | Tab = completion]

ai> what is SQL injection

## What is SQL Injection

SQL Injection is a type of attack where an attacker inserts
malicious SQL code into input fields...

ai> -d
[mode: deep]

ai(deep)> explain TLS handshake

## TLS Handshake

1. Client sends "ClientHello" with supported cipher suites
2. Server responds with "ServerHello" and certificate
3. ...

ai> ↑                # recall previous question
ai> exit
```

---

## 📋 Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| OS | Linux / macOS | Kali / Ubuntu / Debian |
| RAM | 2 GB | 4 GB |
| Disk | ~1.5 GB free | 3 GB |
| CPU | Any x86_64 / ARM64 | Multi-core |
| GPU | Not required | Optional (speeds up) |
| Bash | 4.0+ | 5.0+ |

**No internet needed after first install.**

---

## 🚀 Installation

### Step 1 — Clone the repository

```bash
git clone https://github.com/Chandan-44/ARMIL.git
cd ARMIL
```

### Step 2 — Make the script executable

```bash
chmod +x setup.sh
```

### Step 3 — Run the installer

```bash
./setup.sh
```

**What the installer does (automatically):**

1. Checks if `curl` is installed
2. Installs Ollama if not present
3. Configures Ollama to **auto-start on boot** (systemd service)
4. Downloads the **Qwen 2.5 1.5B** model (~1GB)
5. Installs the `ai` command globally at `/usr/local/bin/ai`
6. (If sudo missing) Falls back to `~/.local/bin/ai` and adds to `PATH`

**Time:** ~3-5 minutes depending on internet speed (model download is ~1GB).

### Step 4 — Verify installation

Open a **new terminal** (or run `source ~/.bashrc`), then:

```bash
ai -h
```

You should see the banner and help menu. Done! ✅

---

## 📖 Usage

### Basic — Ask Anything

```bash
ai "what is SQL injection"
ai "explain TLS handshake"
ai "define XSS"
ai "how does a firewall work"
```

### Modes

| Flag | Mode | Best For |
|------|------|----------|
| *(none)* | Normal | General questions, balanced answer |
| `-f`, `--fast` | Fast | Quick definitions, 1-3 line answers |
| `-d`, `--deep` | Deep | Detailed explanations with examples and steps |
| `-r`, `--recommend` | Recommend | Learning roadmaps — "what should I learn next" |

**Examples:**

```bash
ai -f "define XSS"
ai -d "explain SQL injection in detail"
ai -r "I know basic Linux and networking"
```

### Quiet Mode (No Banner)

```bash
ai -q "what is XSS"
ai -q -f "list 3 types of XSS"
```

Perfect for scripts, redirects, or piping:

```bash
ai -q "what is XSS" > notes.txt
```

### Shell Mode — Persistent `ai>` Prompt

```bash
ai --shell
```

Once inside:

```
ai> what is SQL injection
(… answer …)

ai> -d
[mode: deep]

ai(deep)> explain TLS handshake
(… detailed answer …)

ai> -n
[mode: normal]

ai> what is XSS
(… answer …)

ai> ↑               # recall previous question (arrow keys!)
ai> exit
```

**Built-in shell commands:**

| Command | Action |
|---------|--------|
| `exit` / `quit` / `:q` / `Ctrl+D` | Quit shell mode |
| `clear` | Clear terminal + chat history + AI memory |
| `multi` | Multi-line question (end with `EOF` on its own line) |
| `-f` / `--fast` | Set mode to fast for next questions |
| `-d` / `--deep` | Set mode to deep |
| `-r` / `--recommend` | Set mode to recommend |
| `-n` / `--normal` | Reset to normal mode |
| `↑` / `↓` | Previous / next question (saved across sessions) |
| `Ctrl+R` | Reverse search in history |
| `Ctrl+L` | Clear screen only |
| `Tab` | File completion |

### Interactive Mode (Classic You:/AI: Style)

```bash
ai -i
```

```
You: what is SQL injection
AI:
## SQL Injection
...

You: exit
```

### Piping / File Input — Unlimited Length

```bash
# Explain a long question from a file
ai -d - < long_question.txt

# Explain source code
cat code.py | ai -d - "explain this code"

# Analyze nmap output
nmap -sV target.com | ai -d - "analyze these results"

# Summarize log file
cat /var/log/syslog | ai -q - "find suspicious entries"
```

The `-` (dash) tells `ai` to read from stdin. **No length limit** — works with files of any size.

### Session Management

```bash
ai -c      # clear terminal + chat history + AI memory
ai -s      # show storage status (history, memory, shell history)
ai -h      # show full help menu
ai -v      # show version info
```

---

## 🎨 Color Coding

The `ai` command color-codes AI responses for easy reading:

| Element | Color | Example |
|---------|-------|---------|
| `# Heading` | Bold Cyan | `# What is XSS` |
| `## Sub-heading` | Bold Magenta | `## Types of XSS` |
| Normal text | Light Grey | Regular sentences |
| `**bold**` / key terms | Bold Yellow | `**Stored XSS**` |
| Code / commands | Bold Green | `curl -X POST ...` |
| Numbered list `1. 2. 3.` | Bold Blue | `1.` `2.` `3.` |
| Bullets `-` `*` | Bold Blue | `- item` |
| Quotes / notes | Dark Grey | `> Note: ...` |
| Warnings / errors | Red | `Warning: never trust input` |

**Colors auto-disable when piped** — clean text for redirection:

```bash
ai -d "explain XSS" > notes.txt   # plain text, no escape codes
```

---

## ⚙️ Configuration

### Change the Model

Edit `/usr/local/bin/ai` and change:

```bash
MODEL="qwen2.5:1.5b"
```

**Any Ollama-supported model works:**

| Model | Size | Notes |
|-------|------|-------|
| `qwen2.5:1.5b` | ~1.0 GB | **Default** — best size/quality balance |
| `llama3.2:1b` | ~1.3 GB | Smaller, weaker on Hindi/structured answers |
| `llama3.2:3b` | ~2.0 GB | Better reasoning, needs more RAM |
| `phi3:mini` | ~2.3 GB | Strong reasoning, slow on CPU |
| `mistral:7b` | ~4.1 GB | Excellent quality, needs 8GB RAM |
| `qwen2.5:3b` | ~1.9 GB | Great upgrade from default |

After changing, pull the model:

```bash
ollama pull qwen2.5:3b
```

### Change the System Prompt

In `/usr/local/bin/ai`, find `build_prompt_file()` and edit:

```bash
echo "Reply ONLY in English."
```

Change to whatever you want — e.g. add role instructions, tone, or constraints.

### Change Install Location

By default, the installer tries `/usr/local/bin/ai` (global) and falls back to `~/.local/bin/ai` (user-level). To force a specific location, edit the top of `setup-ai.sh`:

```bash
AI_SCRIPT="$HOME/.local/bin/ai"
```

---

## 📁 Files Created

| Path | Purpose |
|------|---------|
| `/usr/local/bin/ai` (or `~/.local/bin/ai`) | The `ai` command itself |
| `~/.ai_chat_history` | All questions asked (with timestamp + mode) |
| `~/.ai_memory` | Persistent context injected into every prompt |
| `~/.ai_shell_history` | Shell mode arrow-key history |
| `/etc/systemd/system/ollama.service` | Auto-start service (systemd) |

---

## 🗑️ Uninstall

```bash
# Remove the ai command
sudo rm -f /usr/local/bin/ai

# Remove history + memory
rm -f ~/.ai_chat_history ~/.ai_memory ~/.ai_shell_history

# (Optional) remove the model
ollama rm qwen2.5:1.5b

# (Optional) remove Ollama entirely
sudo systemctl disable --now ollama
curl -fsSL https://ollama.com/install.sh | sh -s -- --uninstall 2>/dev/null || true
```

---

## 🛠️ Troubleshooting

### `ai: command not found` after install

Your PATH may be missing `~/.local/bin` (if installer fell back to user-level path):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Ollama not running

```bash
sudo systemctl status ollama
sudo systemctl start ollama
```

If systemd service is missing:

```bash
ollama serve &
```

### Model not found

```bash
ollama pull qwen2.5:1.5b
```

### Slow responses

1B/1.5B models are fast on modern CPUs but slower on older hardware. If you have a GPU:

```bash
# Ollama auto-detects CUDA/Metal — just ensure drivers are installed
nvidia-smi   # check NVIDIA GPU status
```

To speed up repeat queries, keep model in RAM:

```bash
# Add to ~/.bashrc
export OLLAMA_KEEP_ALIVE=30m
```

### Arrow keys not working in shell mode

Make sure you're using **bash ≥ 4.0** (check: `bash --version`) and a **real interactive terminal** (not through some minimal shell). If needed, update bash:

```bash
# Debian/Ubuntu
sudo apt install --only-upgrade bash
```

### "Nothing to clear" message

Means `~/.ai_chat_history` and `~/.ai_memory` are already empty — no action taken. This is normal if you haven't asked any questions yet.

### First response is slow

The model has to load from disk into RAM on first use (~5-10 seconds). Subsequent queries are instant.

---

## 🤝 Contributing

Contributions are welcome! For major changes, please open an issue first to discuss what you'd like to change.

**Ideas for future improvements:**

- [ ] Output to file flag (`-o out.txt`)
- [ ] Save/load conversations (`--save`, `--load`)
- [ ] Voice input (via `whisper` or similar)
- [ ] Config file (`~/.ai_config`)
- [ ] Multiple model profiles (e.g. `ai coder "..."`, `ai hacker "..."`)
- [ ] Web search fallback (offline search index)
- [ ] Windows (WSL) installer variant

**How to contribute:**

```bash
# 1. Fork the repo (on GitHub)
# 2. Clone your fork
git clone https://github.com/chandan-44/ARMIL.git
cd ARMIL

# 3. Create a branch
git checkout -b feature/my-feature

# 4. Make changes, commit
git commit -m "Add: my new feature"

# 5. Push and open a PR
git push origin feature/my-feature
```

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

**TL;DR:** Free to use, modify, distribute. Just keep the copyright notice.

---

## 👨‍💻 Author

**Chandan Kumar**

- 🐙 GitHub: [@chandan-44](https://github.com/chandan-44)
- 💼 LinkedIn: [chandan-kumar-eh](https://linkedin.com/in/chandan-kumar-eh)
- 🎯 Focus: Cybersecurity, Offline AI, Tooling

---

## 🙏 Acknowledgements

- [Ollama](https://ollama.com/) — for making local LLMs dead simple
- [Qwen Team / Alibaba Cloud](https://huggingface.co/Qwen) — for the excellent open model
- The offline AI and FOSS community

---

## ⭐ Show Your Support

If this project helped you, please consider:

- ⭐ **Starring** the repo
- 🐛 **Reporting bugs** via issues
- 💡 **Suggesting features**
- 🔀 **Contributing** code
- 📢 **Sharing** with friends and the cybersecurity community

Every star means a lot! 🌟

---

<p align="center">
  <i>Built with ❤️ for the terminal-first, privacy-conscious community.</i>
</p>

<p align="center">
  <sub>Made in India 🇮🇳 | Powered by Qwen + Ollama</sub>
</p>
