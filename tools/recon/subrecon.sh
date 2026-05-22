#!/usr/bin/env bash
#
#  subrecon.sh — Subdomain Enumeration Pipeline
#  Malcu 🦅 | github.com/muhammad194494-pixel/malcu
#
#  Usage: ./subrecon.sh target.com [--fast] [--deep]
#
#  🔍 Passive Recon → Merge & Dedup → DNS Resolution → Port Scan → Report
#

set -euo pipefail

# ─── Colour ──────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
banner()  { echo -e "${BLUE}[🔍]${NC} $*"; }
success() { echo -e "${GREEN}[✅]${NC} $*"; }
warn()    { echo -e "${YELLOW}[⚠️]${NC}  $*"; }
error()   { echo -e "${RED}[❌]${NC} $*"; }
info()    { echo -e "${CYAN}[→]${NC}  $*"; }

# ─── Usage ───────────────────────────────────────────────
usage() {
    cat <<EOF
Usage: $(basename "$0") <domain> [--fast|--deep]

  domain    Target domain (example.com)
  --fast    Minimal passive sources only
  --deep    Enable brute-force + permutation scanning

EOF
    exit 1
}

[[ $# -lt 1 ]] && usage

# ─── Args ────────────────────────────────────────────────
TARGET="${1}"
MODE="normal"
[[ $# -ge 2 ]] && MODE="${2#--}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="recon_${TARGET}_${TIMESTAMP}"
mkdir -p "${OUTDIR}"

ALL_SUBS="${OUTDIR}/all_subs.txt"
LIVE_SUBS="${OUTDIR}/live_subs.txt"
HTTPX_OUT="${OUTDIR}/httpx_results.txt"
PORT_SCAN="${OUTDIR}/port_scan.txt"
REPORT="${OUTDIR}/REPORT.md"

# ─── Step 1 – Passive Subdomain Enumeration ──────────────
banner "Step 1/5 – Passive Subdomain Enumeration"
> "${OUTDIR}/_subfinder.txt"
> "${OUTDIR}/_assetfinder.txt"
> "${OUTDIR}/_crtsh.txt"
> "${OUTDIR}/_alienvault.txt"

# subfinder
info "Running subfinder..."
if command -v subfinder &>/dev/null; then
    subfinder -d "${TARGET}" -silent -o "${OUTDIR}/_subfinder.txt" 2>/dev/null || true
    success "subfinder → $(wc -l < "${OUTDIR}/_subfinder.txt") found"
else
    warn "subfinder not installed – skipping"
fi

# assetfinder
info "Running assetfinder..."
if command -v assetfinder &>/dev/null; then
    assetfinder --subs-only "${TARGET}" > "${OUTDIR}/_assetfinder.txt" 2>/dev/null || true
    success "assetfinder → $(wc -l < "${OUTDIR}/_assetfinder.txt") found"
else
    warn "assetfinder not installed – skipping"
fi

# crt.sh (lightweight – no external dep needed)
info "Querying crt.sh..."
if command -v curl &>/dev/null; then
    curl -s "https://crt.sh/?q=%25.${TARGET}&output=json" \
        | grep -oP '"name_value":"\K[^"]+' \
        | sed 's/\\*.//g' \
        | sort -u > "${OUTDIR}/_crtsh.txt" 2>/dev/null || true
    success "crt.sh → $(wc -l < "${OUTDIR}/_crtsh.txt") found"
else
    warn "curl not installed – skipping crt.sh"
fi

# AlienVault OTX (lightweight – no external dep needed)
info "Querying AlienVault OTX..."
if command -v curl &>/dev/null; then
    curl -s "https://otx.alienvault.com/api/v1/indicators/domain/${TARGET}/passive_dns" \
        | grep -oP '"hostname":\s*"\K[^"]+' \
        | sort -u > "${OUTDIR}/_alienvault.txt" 2>/dev/null || true
    success "AlienVault → $(wc -l < "${OUTDIR}/_alienvault.txt") found"
else
    warn "curl not installed – skipping AlienVault"
fi

# ─── Step 2 – Brute Force & Permutation (deep mode only) ─
banner "Step 2/5 – Brute Force & Permutation"
if [[ "${MODE}" == "deep" ]]; then
    info "Deep mode active – running brute force..."

    # dnsx brute
    if command -v dnsx &>/dev/null && command -v shuffledns &>/dev/null; then
        info "Running shuffledns..."
        shuffledns -d "${TARGET}" -w "${HOME}/wordlists/subdomains-top1million-5000.txt" \
            -r /usr/share/wordlists/resolvers.txt -silent \
            > "${OUTDIR}/_brute.txt" 2>/dev/null || true
        success "brute-force → $(wc -l < "${OUTDIR}/_brute.txt") found"
    else
        warn "dnsx/shuffledns not installed – skipping brute force"
    fi

    # gotator permutation
    if command -v gotator &>/dev/null; then
        info "Running gotator (permutation)..."
        gotator -sub "${ALL_SUBS}" -perm /usr/share/wordlists/permutations.txt \
            -depth 1 -numbers 10 -silent > "${OUTDIR}/_perm.txt" 2>/dev/null || true
        success "permutation → $(wc -l < "${OUTDIR}/_perm.txt") generated"
    fi
else
    info "Normal mode – skipping brute force (use --deep to enable)"
fi

# ─── Step 3 – Merge & Dedup ─────────────────────────────
banner "Step 3/5 – Merge & Dedup"
cat "${OUTDIR}"/_*.txt 2>/dev/null \
    | sed 's/^\*\.//g' \
    | tr '[:upper:]' '[:lower:]' \
    | grep -iE "\.${TARGET}$" \
    | sort -u > "${ALL_SUBS}"

TOTAL_SUBS=$(wc -l < "${ALL_SUBS}")
success "Total unique subdomains: ${TOTAL_SUBS}"

[[ "${TOTAL_SUBS}" -eq 0 ]] && { error "No subdomains found. Exiting."; exit 0; }

# ─── Step 4 – DNS Resolution & Tech Detection ────────────
banner "Step 4/5 – DNS Resolution & Live Check"
> "${LIVE_SUBS}"
> "${HTTPX_OUT}"

if command -v httpx &>/dev/null; then
    info "Running httpx (DNS resolution, title, status, tech)..."
    httpx -l "${ALL_SUBS}" \
        -silent \
        -status-code \
        -title \
        -tech-detect \
        -follow-redirects \
        -t 100 \
        -o "${HTTPX_OUT}" 2>/dev/null || true

    # Extract live hosts only
    awk '{print $1}' "${HTTPX_OUT}" | sort -u > "${LIVE_SUBS}" 2>/dev/null || true
    LIVE_COUNT=$(wc -l < "${LIVE_SUBS}")
    success "Live hosts: ${LIVE_COUNT}/${TOTAL_SUBS}"
else
    warn "httpx not installed – skipping live check"
    cp "${ALL_SUBS}" "${LIVE_SUBS}"
fi

# ─── Step 5 – Port Scan (Top Ports) ──────────────────────
banner "Step 5/5 – Port Scan (Top 100 Ports)"
> "${PORT_SCAN}"

if [[ -s "${LIVE_SUBS}" ]]; then
    if command -v naabu &>/dev/null; then
        info "Running naabu on live hosts..."
        naabu -list "${LIVE_SUBS}" -top-ports 100 -silent -o "${PORT_SCAN}" 2>/dev/null || true
        success "Port scan → $(wc -l < "${PORT_SCAN}") open ports"
    elif command -v nmap &>/dev/null; then
        info "Running nmap (top 100 ports) on live hosts..."
        nmap -iL "${LIVE_SUBS}" --top-ports 100 -T4 --open -oN "${PORT_SCAN}" 2>/dev/null || true
        success "nmap scan complete"
    else
        warn "naabu/nmap not installed – skipping port scan"
    fi
else
    warn "No live hosts – skipping port scan"
fi

# ─── Report ──────────────────────────────────────────────
banner "Generating Report"
cat > "${REPORT}" <<REPORTEOF
# Recon Report — ${TARGET}

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Mode:** ${MODE}

## Summary

| Metric | Value |
|--------|-------|
| Unique Subdomains | ${TOTAL_SUBS} |
| Live Hosts | ${LIVE_COUNT:-0} |
| Mode | ${MODE} |

## Top Live Subdomains (first 30)

\`\`\`
$(head -30 "${LIVE_SUBS}" 2>/dev/null || echo "None")
\`\`\`

## httpx Results (sample)

\`\`\`
$(head -30 "${HTTPX_OUT}" 2>/dev/null || echo "httpx not run")
\`\`\`

## Port Scan (sample)

\`\`\`
$(head -30 "${PORT_SCAN}" 2>/dev/null || echo "No port scan data")
\`\`\`

---

*Generated by Malcu 🦅 | subrecon.sh*
REPORTEOF

success "Report saved → ${REPORT}"

# ─── Done ────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Recon Complete! 🦅                   ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  Target:     ${TARGET}"
echo -e "${GREEN}║${NC}  Subdomains: ${TOTAL_SUBS}"
echo -e "${GREEN}║${NC}  Live:       ${LIVE_COUNT:-0}"
echo -e "${GREEN}║${NC}  Output:     ${OUTDIR}/"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
