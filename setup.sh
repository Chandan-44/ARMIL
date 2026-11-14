#!/usr/bin/env bash
# ============================================================
#   Offline AI Setup Script — Qwen 2.5 1.5B
#   Made by Chandan
#   GitHub:   https://github.com/chandan-44
#   LinkedIn: https://linkedin.com/in/chandan-kumar-eh
#   Version:  v1.11  (shell mode: arrow keys + history)
# ============================================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}"
echo "=============================================="
echo "   Offline AI Installer — v1.11"
echo "   Made by Chandan"
echo "=============================================="
echo -e "${NC}"

echo -e "${YELLOW}[*] Checking dependencies...${NC}"
command -v curl &>/dev/null || { echo -e "${RED}[!] curl not found.${NC}"; exit 1; }

# ---------- Ollama ----------
if ! command -v ollama &>/dev/null; then
    echo -e "${YELLOW}[*] Installing Ollama...${NC}"
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo -e "${GREEN}[✓] Ollama already installed${NC}"
fi

# ---------- Auto-start ----------
echo -e "${YELLOW}[*] Configuring ollama auto-start on boot...${NC}"
if command -v systemctl &>/dev/null; then
    if systemctl list-unit-files 2>/dev/null | grep -q '^ollama.service'; then
        sudo systemctl enable ollama.service >/dev/null 2>&1 || true
        sudo systemctl start ollama.service  >/dev/null 2>&1 || true
        echo -e "${GREEN}[✓] ollama.service enabled${NC}"
    else
        sudo tee /etc/systemd/system/ollama.service >/dev/null <<EOF
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=$(command -v ollama) serve
User=$(id -un)
Restart=always
RestartSec=3
Environment="HOME=$HOME"

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable ollama.service >/dev/null 2>&1
        sudo systemctl start ollama.service  >/dev/null 2>&1
        echo -e "${GREEN}[✓] Custom ollama.service enabled${NC}"
    fi
fi

if ! pgrep -x "ollama" >/dev/null; then
    nohup ollama serve >/dev/null 2>&1 &
    sleep 3
fi

# ---------- Model ----------
MODEL_PRIMARY="qwen2.5:1.5b"
if ollama list 2>/dev/null | grep -q "^${MODEL_PRIMARY}"; then
    echo -e "${GREEN}[✓] ${MODEL_PRIMARY} already downloaded${NC}"
else
    echo -e "${YELLOW}[*] Pulling ${MODEL_PRIMARY} (~1.0GB)...${NC}"
    ollama pull "$MODEL_PRIMARY"
    echo -e "${GREEN}[✓] ${MODEL_PRIMARY} ready${NC}"
fi

# ---------- Install path ----------
if [[ -w /usr/local/bin ]] || sudo -n true 2>/dev/null; then
    AI_SCRIPT="/usr/local/bin/ai"; USE_SUDO=1
else
    AI_SCRIPT="$HOME/.local/bin/ai"; USE_SUDO=0
    mkdir -p "$HOME/.local/bin"
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

echo -e "${YELLOW}[*] Installing 'ai' command at $AI_SCRIPT${NC}"

# ---------- Write ai script ----------
TMP_AI=$(mktemp)
cat > "$TMP_AI" <<'AIEOF'
#!/usr/bin/env bash
# ============================================================
#   ai — Offline AI assistant (v1.11)
#   Made by Chandan
#   GitHub:   https://github.com/chandan-44
#   LinkedIn: https://linkedin.com/in/chandan-kumar-eh
# ============================================================

MODEL="qwen2.5:1.5b"
HIST_FILE="$HOME/.ai_chat_history"
MEM_FILE="$HOME/.ai_memory"
SHELL_HIST="$HOME/.ai_shell_history"   # dedicated history for shell mode arrows
QUIET=0

# ---------- Colors ----------
C_TITLE='\033[1;36m'
C_SUBTITLE='\033[1;35m'
C_TEXT='\033[0;37m'
C_KEY='\033[1;33m'
C_CODE='\033[1;32m'
C_BULLET='\033[1;34m'
C_QUOTE='\033[0;90m'
C_WARN='\033[0;31m'
C_PROMPT='\033[1;35m'
C_RESET='\033[0m'

# ---------- Banner ----------
banner() {
    [[ "$QUIET" -eq 1 ]] && return
    echo -e "\033[1;35m   ___    ____    __  __ _ _\033[0m"
    echo -e "\033[1;35m  /   |  |  _ \\  |  \\/  (_) |\033[0m"
    echo -e "\033[1;35m / /| |  | |_) | | |\\/| | | |\033[0m"
    echo -e "\033[1;35m/ ___ |  |  _ <  | |  | | | |\033[0m"
    echo -e "\033[1;35m/_/  |_| |_| \\_\\ |_|  |_|_|_|\033[0m"
    echo -e "\033[1;36m         O F F L I N E   A I\033[0m"
    echo -e "\033[1;36m  Made by Chandan   (v1.11)\033[0m"
    echo -e "\033[0;34m  GitHub:   https://github.com/chandan-44\033[0m"
    echo -e "\033[0;34m  LinkedIn: https://linkedin.com/in/chandan-kumar-eh\033[0m"
    echo -e "\033[0;90m  ──────────────────────────────────────────────\033[0m"
    echo ""
}

# ---------- Help ----------
show_help() {
    banner
    echo -e "${C_TITLE}USAGE${C_RESET}"
    echo -e "  ai [OPTION] \"your question\""
    echo -e "  ai [OPTION] -            # read from stdin"
    echo -e "  echo \"q\" | ai [OPTION]"
    echo -e "  ai -i                    # interactive chat"
    echo -e "  ai --shell               # shell mode (ai> prompt)"
    echo ""
    echo -e "${C_TITLE}MODES${C_RESET}"
    echo -e "  ${C_CODE}-f, --fast${C_RESET}         Quick short answer"
    echo -e "  ${C_CODE}-d, --deep${C_RESET}         Detailed step-by-step answer"
    echo -e "  ${C_CODE}-r, --recommend${C_RESET}    Suggest next topics to learn"
    echo -e "  ${C_CODE}(default)${C_RESET}          Normal balanced answer"
    echo ""
    echo -e "${C_TITLE}SESSION${C_RESET}"
    echo -e "  ${C_CODE}-i, --interactive${C_RESET}  Interactive chat (You:/AI: style)"
    echo -e "  ${C_CODE}--shell${C_RESET}            Shell mode (ai> prompt, arrow keys work)"
    echo -e "  ${C_CODE}-c, --clear${C_RESET}        Clear screen + history + memory"
    echo -e "  ${C_CODE}-s, --status${C_RESET}       Show history/memory info"
    echo ""
    echo -e "${C_TITLE}INPUT${C_RESET}"
    echo -e "  ${C_CODE}-${C_RESET}                     Read question from stdin (no length limit)"
    echo ""
    echo -e "${C_TITLE}DISPLAY${C_RESET}"
    echo -e "  ${C_CODE}-q, --quiet${C_RESET}        Skip banner (clean output)"
    echo ""
    echo -e "${C_TITLE}INFO${C_RESET}"
    echo -e "  ${C_CODE}-h, --help${C_RESET}         Show help"
    echo -e "  ${C_CODE}-v, --version${C_RESET}      Version"
    echo ""
    echo -e "${C_TITLE}EXAMPLES${C_RESET}"
    echo -e "  \033[0;36mai \"what is SQL injection\"${C_RESET}"
    echo -e "  \033[0;36mai -q \"define XSS\"${C_RESET}                   (no banner)"
    echo -e "  \033[0;36mai --shell${C_RESET}                           (ai> prompt + arrow keys)"
    echo -e "  \033[0;36mai -d - < long_question.txt${C_RESET}"
    echo ""
}

show_version() {
    echo "ai (offline) — v1.11"
    echo "Model    : $MODEL"
    echo "Language : English"
    echo "Colors   : enabled (auto-disabled when piped)"
    echo "Modes    : -i (chat) | --shell (persistent + history) | -q (quiet)"
    echo "Author   : Chandan"
    echo "GitHub   : https://github.com/chandan-44"
    echo "LinkedIn : https://linkedin.com/in/chandan-kumar-eh"
}

# ---------- Clear ----------
clear_data() {
    if [[ -t 1 ]]; then
        clear 2>/dev/null || printf '\033[2J\033[H'
    fi
    local cleared=0
    [[ -f "$HIST_FILE" ]] && { rm -f "$HIST_FILE"; cleared=1; }
    [[ -f "$MEM_FILE"  ]] && { rm -f "$MEM_FILE";  cleared=1; }
    [[ -f "$SHELL_HIST" ]] && { rm -f "$SHELL_HIST"; cleared=1; }
    command -v ollama &>/dev/null && ollama stop "$MODEL" >/dev/null 2>&1 || true

    if [[ "$cleared" -eq 1 ]]; then
        echo -e "${C_CODE}[✓]${C_RESET} Terminal, chat history, shell history and AI memory cleared."
    else
        echo -e "${C_KEY}[!]${C_RESET} Terminal cleared. (History and memory were already empty.)"
    fi
}

# ---------- Status ----------
show_status() {
    echo -e "${C_TITLE}AI Storage Status${C_RESET}"
    if [[ -f "$HIST_FILE" ]]; then
        echo -e "  ${C_KEY}History:${C_RESET} $HIST_FILE  ($(wc -l < "$HIST_FILE") lines, $(du -h "$HIST_FILE" | cut -f1))"
    else
        echo -e "  ${C_KEY}History:${C_RESET} ${C_QUOTE}(not created yet)${C_RESET}"
    fi
    [[ -f "$MEM_FILE" ]] && echo -e "  ${C_KEY}Memory :${C_RESET} $MEM_FILE  ($(wc -l < "$MEM_FILE") lines)" \
                         || echo -e "  ${C_KEY}Memory :${C_RESET} ${C_QUOTE}(not created yet)${C_RESET}"
    [[ -f "$SHELL_HIST" ]] && echo -e "  ${C_KEY}Shell  :${C_RESET} $SHELL_HIST  ($(wc -l < "$SHELL_HIST") entries)" \
                           || echo -e "  ${C_KEY}Shell  :${C_RESET} ${C_QUOTE}(not created yet)${C_RESET}"
    echo ""
}

# ---------- Build prompt ----------
build_prompt_file() {
    local mode="$1"; local qfile="$2"; local outfile="$3"
    local mem=""
    [[ -f "$MEM_FILE" ]] && mem=$(cat "$MEM_FILE")

    {
        echo "Reply ONLY in English."
        echo ""
        printf 'Format response in clean Markdown: use "## Heading" for sections, "- " for bullets, "```" for code blocks, and **bold** for key terms.\n\n'
        [[ -n "$mem" ]] && printf '[Memory: %s]\n\n' "$mem"
        case "$mode" in
            fast)      printf 'Answer in 1-3 lines max. No extra explanation.\n\nQuestion:\n' ;;
            deep)      printf 'Give a detailed, structured answer with real examples, steps, and edge cases.\n\nQuestion:\n' ;;
            recommend) printf 'Based on the user current knowledge, give a numbered roadmap of what to learn NEXT with short reasoning per step.\n\nUser info:\n' ;;
            *)         printf 'Answer clearly and concisely.\n\nQuestion:\n' ;;
        esac
        cat "$qfile"
    } > "$outfile"
}

# ---------- Colorizer ----------
colorize_line() {
    local line="$1"
    if [[ -z "$line" ]]; then echo ""; return; fi
    if [[ "$line" =~ ^\`\`\` ]]; then printf '%b%s%b\n' "$C_QUOTE" "$line" "$C_RESET"; return; fi
    if [[ "$line" =~ ^#\ + ]]; then printf '%b%s%b\n' "$C_TITLE" "$line" "$C_RESET"; return; fi
    if [[ "$line" =~ ^#{2,6}\ + ]]; then printf '%b%s%b\n' "$C_SUBTITLE" "$line" "$C_RESET"; return; fi
    if [[ "$line" =~ ^(---|\*\*\*|___)$ ]]; then printf '%b%s%b\n' "$C_QUOTE" "$line" "$C_RESET"; return; fi
    if [[ "$line" =~ ^(Warning|WARNING|Error|ERROR|Caution|CAUTION) ]]; then printf '%b%s%b\n' "$C_WARN" "$line" "$C_RESET"; return; fi
    if [[ "$line" =~ ^([[:space:]]*)([0-9]+\.)(.*)$ ]]; then
        printf '%s%b%s%b%s\n' "${BASH_REMATCH[1]}" "$C_BULLET" "${BASH_REMATCH[2]}" "$C_RESET" "${BASH_REMATCH[3]}"
        return
    fi
    if [[ "$line" =~ ^([[:space:]]*)([-*+])[[:space:]](.*)$ ]]; then
        printf '%s%b%s%b %s\n' "${BASH_REMATCH[1]}" "$C_BULLET" "${BASH_REMATCH[2]}" "$C_RESET" "${BASH_REMATCH[3]}"
        return
    fi
    if [[ "$line" =~ ^\>\ ? ]]; then printf '%b%s%b\n' "$C_QUOTE" "$line" "$C_RESET"; return; fi

    local out="$line"
    if [[ "$out" == *'`'* ]]; then
        local rest="$out"; out=""
        while [[ "$rest" == *'`'* ]]; do
            local pre="${rest%%\`*}"; rest="${rest#*\`}"
            local code="${rest%%\`*}"; rest="${rest#*\`}"
            out+="${pre}"$'\x01'"${code}"$'\x02'
        done
        out+="$rest"
        out="${out//$'\x01'/$C_CODE}"; out="${out//$'\x02'/$C_TEXT}"
    fi
    if [[ "$out" == *'**'* ]]; then
        local rest2="$out"; out=""
        while [[ "$rest2" == *'**'* ]]; do
            local pre="${rest2%%\*\**}"; rest2="${rest2#*\*\*}"
            local bold="${rest2%%\*\**}"; rest2="${rest2#*\*\*}"
            out+="${pre}"$'\x03'"${bold}"$'\x04'
        done
        out+="$rest2"
        out="${out//$'\x03'/$C_KEY}"; out="${out//$'\x04'/$C_TEXT}"
    fi
    printf '%b%b%b\n' "$C_TEXT" "$out" "$C_RESET"
}

colorize_stream() {
    if [[ ! -t 1 ]]; then cat; return; fi
    local in_code=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^\`\`\` ]]; then
            in_code=$((1 - in_code))
            printf '%b%s%b\n' "$C_QUOTE" "$line" "$C_RESET"
            continue
        fi
        if [[ "$in_code" -eq 1 ]]; then
            printf '%b%s%b\n' "$C_CODE" "$line" "$C_RESET"
        else
            colorize_line "$line"
        fi
    done
}

# ---------- Core: ask one question ----------
ask_once() {
    local mode="$1"; local question="$2"

    local tmpq pf
    tmpq=$(mktemp); pf=$(mktemp)
    printf '%s' "$question" > "$tmpq"
    build_prompt_file "$mode" "$tmpq" "$pf"

    if [[ "$mode" == "fast" ]]; then
        ollama run "$MODEL" "$(cat "$pf")" --verbose false | colorize_stream
    else
        ollama run "$MODEL" "$(cat "$pf")" | colorize_stream
    fi

    rm -f "$tmpq" "$pf"
    echo "[$(date '+%Y-%m-%d %H:%M')] ($mode) $(printf '%s' "$question" | head -c 200)" >> "$HIST_FILE"
}

# ---------- Interactive mode ----------
interactive() {
    banner
    echo -e "${C_KEY}[Interactive mode — 'exit' to quit, 'clear' wipe, 'multi' multi-line]${C_RESET}\n"
    while true; do
        read -e -rp "You: " q
        [[ "$q" == "exit" || "$q" == "quit" ]] && break
        [[ "$q" == "clear" ]] && { clear_data; continue; }
        if [[ "$q" == "multi" ]]; then
            echo -e "${C_QUOTE}(End with 'EOF' on its own line)${C_RESET}"
            tmp=$(mktemp)
            while IFS= read -r line; do
                [[ "$line" == "EOF" ]] && break
                echo "$line" >> "$tmp"
            done
            q=$(cat "$tmp"); rm -f "$tmp"
        fi
        [[ -z "$q" ]] && continue
        history -s "$q"    # <-- save for arrow keys

        echo -e "\n${C_TITLE}AI:${C_RESET}"
        ask_once "normal" "$q"
        echo ""
    done
}

# ---------- Shell mode (with arrow-key history) ----------
shell_mode() {
    banner
    echo -e "${C_QUOTE}[Shell mode — type 'exit' or Ctrl+D to quit]${C_RESET}"
    echo -e "${C_QUOTE}[Arrow keys ↑↓ = history | clear | multi | -f/-d/-r/-n | Tab = completion]${C_RESET}\n"

    # Load previous shell history (if any) into current bash session
    if [[ -f "$SHELL_HIST" ]]; then
        # Make history per-session isolated from user's global ~/.bash_history
        HISTFILE="$SHELL_HIST"
        history -c
        history -r "$SHELL_HIST"
    else
        HISTFILE="$SHELL_HIST"
        history -c
    fi

    # Ensure history isn't truncated by size limits during session
    HISTSIZE=10000
    HISTFILESIZE=10000
    HISTCONTROL=ignoreboth:erasedups   # no dupes, no leading-space entries

    local cur_mode="normal"
    while true; do
        local prompt_str="ai"
        [[ "$cur_mode" != "normal" ]] && prompt_str="ai($cur_mode)"

        # read -e enables readline: arrows, Ctrl+A/E, Ctrl+R, Tab (file completion), etc.
        if ! read -e -rp "$(printf '%b%s>%b ' "$C_PROMPT" "$prompt_str" "$C_RESET")" q; then
            break   # Ctrl+D / EOF
        fi

        # Empty line -> skip
        [[ -z "$q" ]] && continue

        case "$q" in
            exit|quit|":q")
                break ;;
            clear)
                clear_data
                echo -e "${C_QUOTE}[Shell mode — type 'exit' to quit]${C_RESET}"
                echo ""
                continue ;;
            multi)
                echo -e "${C_QUOTE}(End with 'EOF' on its own line)${C_RESET}"
                tmp=$(mktemp)
                while IFS= read -r line; do
                    [[ "$line" == "EOF" ]] && break
                    echo "$line" >> "$tmp"
                done
                q=$(cat "$tmp"); rm -f "$tmp"
                [[ -z "$q" ]] && continue
                ;;
            -f|--fast)      cur_mode="fast";      echo -e "${C_CODE}[mode: fast]${C_RESET}"; continue ;;
            -d|--deep)      cur_mode="deep";      echo -e "${C_CODE}[mode: deep]${C_RESET}"; continue ;;
            -r|--recommend) cur_mode="recommend"; echo -e "${C_CODE}[mode: recommend]${C_RESET}"; continue ;;
            -n|--normal)    cur_mode="normal";    echo -e "${C_CODE}[mode: normal]${C_RESET}"; continue ;;
        esac

        # Save current question to history so ↑ recalls it
        history -s "$q"
        history -w "$SHELL_HIST"

        echo ""
        ask_once "$cur_mode" "$q"
        echo ""
    done

    # Save final history on exit
    history -w "$SHELL_HIST"
}
# ---------- Parse args ----------
MODE="normal"; USE_STDIN=0; ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        -v|--version) show_version; exit 0 ;;
        -c|--clear) clear_data; exit 0 ;;
        -s|--status) show_status; exit 0 ;;
        -i|--interactive) interactive; exit 0 ;;
        --shell) shell_mode; exit 0 ;;
        -q|--quiet) QUIET=1; shift ;;
        -f|--fast) MODE="fast"; shift ;;
        -d|--deep) MODE="deep"; shift ;;
        -r|--recommend) MODE="recommend"; shift ;;
        -) USE_STDIN=1; shift ;;
        *) ARGS+=("$1"); shift ;;
    esac
done

# ---------- Gather question ----------
TMPQ=$(mktemp); PROMPT_FILE=$(mktemp)
trap 'rm -f "$TMPQ" "$PROMPT_FILE"' EXIT

[[ "$USE_STDIN" -eq 1 ]] && cat >> "$TMPQ"
if [[ ${#ARGS[@]} -gt 0 ]]; then
    [[ -s "$TMPQ" ]] && printf '\n\n' >> "$TMPQ"
    printf '%s' "${ARGS[*]}" >> "$TMPQ"
fi
if [[ ! -s "$TMPQ" ]]; then
    if [[ -t 0 ]]; then show_help; exit 0; else cat >> "$TMPQ"; fi
fi
[[ ! -s "$TMPQ" ]] && { echo "Error: no question provided. Use -h."; exit 1; }

# ---------- Run ----------
banner
if [[ "$QUIET" -eq 0 ]]; then
    echo -e "${C_QUOTE}[Mode: $MODE]${C_RESET}"
    echo -e "${C_KEY}Question:${C_RESET}"
    head -c 500 "$TMPQ"; [[ $(wc -c < "$TMPQ") -gt 500 ]] && echo " ..."
    echo ""
    echo -e "${C_QUOTE}──────────────────────────────────────────────${C_RESET}"
    echo -e "${C_TITLE}AI:${C_RESET}"
fi

build_prompt_file "$MODE" "$TMPQ" "$PROMPT_FILE"

if [[ "$MODE" == "fast" ]]; then
    ollama run "$MODEL" "$(cat "$PROMPT_FILE")" --verbose false | colorize_stream
else
    ollama run "$MODEL" "$(cat "$PROMPT_FILE")" | colorize_stream
fi

echo ""
echo "[$(date '+%Y-%m-%d %H:%M')] ($MODE) $(head -c 200 "$TMPQ")" >> "$HIST_FILE"
AIEOF

if [[ "$USE_SUDO" -eq 1 ]]; then
    sudo mv "$TMP_AI" "$AI_SCRIPT"; sudo chmod +x "$AI_SCRIPT"
else
    mv "$TMP_AI" "$AI_SCRIPT"; chmod +x "$AI_SCRIPT"
fi
echo -e "${GREEN}[✓] 'ai' command installed at $AI_SCRIPT${NC}"

command -v ai &>/dev/null || echo -e "${YELLOW}[!] 'ai' not in PATH. Run: export PATH=\"$HOME/.local/bin:\$PATH\"${NC}"

echo ""
echo -e "${CYAN}=============================================="
echo -e "  Setup Complete!   (v1.11)"
echo -e "==============================================${NC}"
echo ""
echo -e "Try:"
echo -e "  ${GREEN}ai --shell${NC}                        (ai> prompt + arrow keys)"
echo -e "  ${GREEN}ai \"what is SQL injection\"${NC}"
echo -e "  ${GREEN}ai -q \"define XSS\"${NC}                (no banner)"
echo -e "  ${GREEN}ai -c${NC}                             (clear screen + memory)"
echo ""
rm -rf ../ARMIL
