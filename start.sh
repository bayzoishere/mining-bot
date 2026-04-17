#!/bin/bash
# ═══════════════════════════════════════════════════════
# Mine WorkNet Bot — Start Script
# Run this on VPS after setup
# ═══════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.env"

# ── Paths ────────────────────────────────────────────
SKILL_DIR="${HOME}/.openclaw/workspace/mine-skill"
VENV_BIN="${SKILL_DIR}/.venv/bin"
export PATH="${HOME}/.local/bin:${VENV_BIN}:${PATH}"

# ── Validate env ─────────────────────────────────────
if [ -z "${MINING_WALLET_PRIVATE_KEY}" ]; then
    echo "ERROR: MINING_WALLET_PRIVATE_KEY not set in .env"
    echo "You need to set your wallet private key (0x...) in .env"
    exit 1
fi

# ── Proxy support ───────────────────────────────────
if [ -n "${HTTP_PROXY}" ]; then
    export HTTP_PROXY="${HTTP_PROXY}"
    export HTTPS_PROXY="${HTTP_PROXY}"
    export http_proxy="${HTTP_PROXY}"
    export https_proxy="${HTTP_PROXY}"
    echo "Using proxy: ${HTTP_PROXY}"
fi

# ── Kill existing process ─────────────────────────────
pkill -f "run_worker\|run-tool.py agent" 2>/dev/null || true

# ── Clear stale state (optional) ────────────────────
if [ "${CLEAR_STATE}" == "true" ]; then
    echo "Clearing stale worker state..."
    rm -rf "${SKILL_DIR}/output/agent-runs/_worker_state/*" 2>/dev/null || true
fi

# ── Start mining ─────────────────────────────────────
echo "Starting Mine WorkNet Bot..."
echo "Wallet: ${MINING_WALLET_PRIVATE_KEY:0:10}..."
echo "Datasets: ${DATASETS:-ds_wikipedia,ds_arxiv}"
echo "Interval: ${INTERVAL:-60}s"
echo "Proxy: ${HTTP_PROXY:-none}"
echo ""

cd "${SKILL_DIR}"

nohup ${VENV_BIN}/python3 scripts/run_tool.py run-worker "${INTERVAL:-60}" 0 > "${SCRIPT_DIR}/mining.log" 2>&1 &

echo "PID: $!"
echo "Log: ${SCRIPT_DIR}/mining.log"

sleep 5
tail -n 20 "${SCRIPT_DIR}/mining.log"
