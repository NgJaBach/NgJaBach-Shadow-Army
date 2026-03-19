#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# OpenAI Shadow Ledger — @BachsSlave2Bot startup script
# Usage: bash scripts/run_openai_bot.sh
# ─────────────────────────────────────────────────────────────

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOT_DIR="$REPO_ROOT/OpenAIUsageBot"
VENV_DIR="$REPO_ROOT/.venv"

cd "$REPO_ROOT"

# ── 1. Virtual environment ────────────────────────────────────
if [ ! -d "$VENV_DIR" ]; then
    echo "[setup] Creating virtual environment at .venv ..."
    python -m venv "$VENV_DIR"
fi

# Activate — handles both Git Bash on Windows and Unix
if [ -f "$VENV_DIR/Scripts/activate" ]; then
    # shellcheck disable=SC1091
    source "$VENV_DIR/Scripts/activate"
elif [ -f "$VENV_DIR/bin/activate" ]; then
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
else
    echo "[error] Could not find venv activation script. Aborting."
    exit 1
fi

# ── 2. Dependencies ───────────────────────────────────────────
echo "[setup] Installing / verifying dependencies ..."
pip install -q --upgrade requests python-dotenv

# ── 3. Env check ─────────────────────────────────────────────
ENV_FILE="$BOT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "[error] $ENV_FILE not found. Copy .env.example and fill in your secrets."
    exit 1
fi

if grep -q "PUT_TOKEN_HERE\|PUT_KEY_HERE" "$ENV_FILE"; then
    echo "[error] .env still contains placeholder values. Fill in real credentials."
    exit 1
fi

# ── 4. Launch ─────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  OpenAI Shadow Ledger — @BachsSlave2Bot"
echo "  Bot dir : $BOT_DIR"
echo "  Poll    : ${POLL_INTERVAL_MINS:-60} min  |  Limit: \$${DAILY_SPEND_LIMIT:-5.00}/day"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec python "$BOT_DIR/openai_usage_bot.py"
