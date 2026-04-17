# Mine WorkNet Bot

Bot for [Mine WorkNet](https://minework.net) — AI data labeling marketplace built on AWP.

## Setup di VPS

### Prerequisites
- Ubuntu 20.04+ / Debian
- `curl`, `wget`, `sudo`, `git`, `python3` access
- GitHub token (untuk clone repo)

### Langkah-Langkah

```bash
# 1. Clone repo
git clone https://github.com/<YOUR_GITHUB>/mining-bot.git
cd mining-bot

# 2. Jalankan setup
bash setup.sh

# 3. Edit .env — Masukin wallet private key + proxy
nano .env

# 4. Jalankan bot
bash start.sh
```

## Setup Wallet

lu perlu masukin **private key** wallet lu (format `0x...`).

```bash
# Edit .env:
nano .env
# Set: MINING_WALLET_PRIVATE_KEY=0xyour_private_key_here
```

⚠️ **PERINGATAN:** Private key sangat sensitif! Jangan share atau push ke git.

## Pakai Proxy

Edit `.env`:
```bash
HTTP_PROXY=http://user:password@proxy.example.com:8080
HTTPS_PROXY=http://user:password@proxy.example.com:8080
```

## Commands

| Command | Description |
|---------|-------------|
| `bash start.sh` | Start mining bot |
| `python mine-skill/scripts/run_tool.py agent-control status` | Cek status |
| `python mine-skill/scripts/run_tool.py agent-control stop` | Stop bot |
| `tail -f mining.log` | View live logs |

## Quality Mode

Default: **Quality over quantity** (max_parallel=1)

Edit `.env`:
```bash
QUALITY_MODE=true   # untuk kualitas
QUALITY_MODE=false  # untuk kuantitas (lebih cepat)
```

## Datasets

| Dataset | Deskripsi |
|---------|-----------|
| `ds_wikipedia` | Artikel Wikipedia (rekomendasi) |
| `ds_arxiv` | Paper akademik arXiv |
| `ds_community` | Konten dari komunitas |

Multi-dataset (comma-separated):
```bash
DATASETS=ds_wikipedia,ds_arxiv
```

## Epoch & Rewards

- **Epoch:** Reset setiap hari UTC 00:00
- **Target:** 80 submissions per epoch untuk qualify
- **Settlement:** ~7AM WIB (UTC 00:00)
- **Credit Score:** Berdasarkan accuracy + participation

## Troubleshooting

### "No active mining session"
```bash
bash start.sh
```

### processed=0 terus
```bash
# Clear stale state
CLEAR_STATE=true bash start.sh
```

### Rate limit (429)
```bash
# Tambah interval di .env
INTERVAL=120
```

### Check logs
```bash
tail -f mining.log
```

## Update Bot

```bash
cd ~/.openclaw/workspace/mine-skill
git pull origin main
```

## Disclaimer

- Bot mengsubmit data labeling tasks ke platform Minework
- Rewards dalam bentuk credit score & token
- Pastikan VPS online 24/7 untuk maximize submissions
