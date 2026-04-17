#!/bin/bash
# ═══════════════════════════════════════════════════════
# Mine WorkNet Bot — Setup Script
# For VPS deployment
# ═══════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Mine WorkNet Bot — Setup Installer${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"

# ── Detect OS ────────────────────────────────────────
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH_STR="x86_64"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    ARCH_STR="arm64"
else
    echo -e "${RED}Unsupported arch: $ARCH${NC}"
    exit 1
fi

# ── Paths ────────────────────────────────────────────
INSTALL_DIR="${HOME}/.mining-bot"
BIN_DIR="${HOME}/.local/bin"
SKILL_DIR="${HOME}/.openclaw/workspace/mine-skill"
export PATH="${BIN_DIR}:${PATH}"

# ── Create directories ───────────────────────────────
mkdir -p "${BIN_DIR}"
mkdir -p "${INSTALL_DIR}"
mkdir -p "${HOME}/.openclaw/workspace"

# ── Step 1: Clone mine-skill ─────────────────────────
echo -e "\n${YELLOW}[1/6] Installing mine-skill...${NC}"

if [ -d "${SKILL_DIR}" ]; then
    echo "mine-skill already exists, pulling latest..."
    cd "${SKILL_DIR}" && git pull origin main
else
    git clone https://github.com/awp-worknet/mine-skill.git "${SKILL_DIR}"
fi
echo -e "${GREEN}✓ mine-skill installed${NC}"

# ── Step 2: Create venv ─────────────────────────────
echo -e "\n${YELLOW}[2/6] Setting up Python virtual environment...${NC}"

if [ ! -d "${SKILL_DIR}/.venv" ]; then
    python3 -m venv "${SKILL_DIR}/.venv"
fi
"${SKILL_DIR}/.venv/bin/pip" install -q --upgrade pip
"${SKILL_DIR}/.venv/bin/pip}" install -q -r "${SKILL_DIR}/requirements.txt"
echo -e "${GREEN}✓ Virtual environment ready${NC}"

# ── Step 3: Install Node.js (if needed) ────────────
echo -e "\n${YELLOW}[3/6] Checking Node.js...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js not found. Installing...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
fi
echo -e "${GREEN}✓ Node.js $(node --version)${NC}"

# ── Step 4: Install OpenClaw ───────────────────────
echo -e "\n${YELLOW}[4/6] Checking OpenClaw...${NC}"

if ! command -v openclaw &> /dev/null; then
    echo -e "${YELLOW}Installing OpenClaw CLI...${NC}"
    curl -fsSL https://openclaw.ai/install.sh | bash -
    mv openclaw "${BIN_DIR}/openclaw"
fi
echo -e "${GREEN}✓ OpenClaw $(openclaw --version 2>/dev/null || echo 'installed')${NC}"

# ── Step 5: Copy files ────────────────────────────
echo -e "\n${YELLOW}[5/6] Deploying config files...${NC}"

cp start.sh "${INSTALL_DIR}/start.sh"
cp .env.example "${INSTALL_DIR}/.env.example"
chmod +x "${INSTALL_DIR}/start.sh"

echo -e "${GREEN}✓ Files deployed to ${INSTALL_DIR}${NC}"

# ── Step 6: Create .env from example ──────────────
if [ ! -f "${INSTALL_DIR}/.env" ]; then
    cp "${INSTALL_DIR}/.env.example" "${INSTALL_DIR}/.env"
    echo -e "${YELLOW}⚠ Created .env — please edit with your config${NC}"
fi

echo -e "\n${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Edit ${INSTALL_DIR}/.env with your wallet & proxy"
echo -e "  2. Run: bash ${INSTALL_DIR}/start.sh"
echo -e "  3. For help: python ${SKILL_DIR}/scripts/run_tool.py --help"
echo -e "${NC}"
