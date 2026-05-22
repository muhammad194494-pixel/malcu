#!/usr/bin/env bash
#
#  ██████╗  ██████╗ ██████╗ ████████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗
#  ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║
#  ██████╔╝██║   ██║██████╔╝   ██║   ██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║
#  ██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║
#  ██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║
#  ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝
#
#  PortRecon — Fast Port Scanner Wrapper (masscan + nmap)
#  Author: Malcu 🦅 | Repo: github.com/muhammad194494-pixel/malcu
#
#  Usage:
#    ./portrecon.sh <target>              # Scan single IP/domain
#    ./portrecon.sh -l targets.txt        # Scan dari list
#    ./portrecon.sh -l subs.txt -o out/   # Output custom
#    ./portrecon.sh 192.168.1.1 -p 1-1000 # Port range custom
#
#  Dependencies: masscan, nmap, httpx (optional: tee)

set -euo pipefail

# ═══════════════════════════════════════════════════════════════
#  Color Output
# ═══════════════════════════════════════════════════════════════
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════════
#  Banner
# ═══════════════════════════════════════════════════════════════
banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  🦅  PortRecon — Fast Port Scanner Wrapper           ║"
    echo "║       masscan (speed) + nmap (depth) + httpx (web)   ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ═══════════════════════════════════════════════════════════════
#  Usage
# ═══════════════════════════════════════════════════════════════
usage() {
    echo -e "${BOLD}Usage:${NC}"
    echo "  $0 <target>                   Single target scan"
    echo "  $0 -l <targets.txt>            List scan"
    echo "  $0 -l <targets.txt> -o <dir>   Custom output dir"
    echo "  $0 <target> -p 1-65535         Full port scan"
    echo "  $0 <target> --top-ports 1000   Top 1000 ports only"
    echo "  $0 <target> --no-masscan       Skip masscan, nmap only"
    echo "  $0 <target> --stealth          Slow & stealthy"
    echo ""
    echo -e "${BOLD}Modes:${NC}"
    echo "  default     masscan top 1000 → nmap detected ports → httpx web"
    echo "  --full      masscan all 65535 → nmap detected ports → service scan"
    echo "  --stealth   nmap SYN stealth top 1000 only (no masscan)"
}

# ═══════════════════════════════════════════════════════════════
#  Dependency Check
# ═══════════════════════════════════════════════════════════════
check_deps() {
    local missing=()
    
    for tool in nmap; do
        command -v "$tool" &>/dev/null || missing+=("$tool")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[!] Missing dependencies: ${missing[*]}${NC}"
        echo -e "${YELLOW}[*] Install: apt install ${missing[*]}${NC}"
        exit 1
    fi
    
    # Optional tools — warn but continue
    local optional=()
    command -v masscan &>/dev/null || optional+=("masscan")
    command -v httpx &>/dev/null   || optional+=("httpx")
    
    if [[ ${#optional[@]} -gt 0 ]]; then
        echo -e "${YELLOW}[!] Optional tools missing: ${optional[*]}${NC}"
        echo -e "${YELLOW}[*] masscan → faster scanning | httpx → web detection${NC}"
    fi
}

# ═══════════════════════════════════════════════════════════════
#  Parse Args
# ═══════════════════════════════════════════════════════════════
TARGETS=()
LIST_FILE=""
OUTDIR=""
PORT_RANGE=""
TOP_PORTS=1000
MODE="default"
USE_MASSCAN=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--list)
            LIST_FILE="$2"; shift 2 ;;
        -o|--output)
            OUTDIR="$2"; shift 2 ;;
        -p|--ports)
            PORT_RANGE="$2"; shift 2 ;;
        --top-ports)
            TOP_PORTS="$2"; shift 2 ;;
        --full)
            MODE="full"; PORT_RANGE="1-65535"; shift ;;
        --stealth)
            MODE="stealth"; USE_MASSCAN=false; shift ;;
        --no-masscan)
            USE_MASSCAN=false; shift ;;
        -h|--help)
            banner; usage; exit 0 ;;
        -*)
            echo -e "${RED}[!] Unknown flag: $1${NC}"; usage; exit 1 ;;
        *)
            TARGETS+=("$1"); shift ;;
    esac
done

# ═══════════════════════════════════════════════════════════════
#  Setup
# ═══════════════════════════════════════════════════════════════
banner
check_deps

# Default port range
if [[ -z "$PORT_RANGE" ]]; then
    PORT_RANGE="1-65535"
    if [[ "$MODE" == "default" ]]; then
        PORT_RANGE="1-1000"
    fi
fi

# Collect targets
ALL_TARGETS=()
if [[ -n "$LIST_FILE" ]]; then
    if [[ ! -f "$LIST_FILE" ]]; then
        echo -e "${RED}[!] File not found: $LIST_FILE${NC}"
        exit 1
    fi
    mapfile -t ALL_TARGETS < "$LIST_FILE"
else
    ALL_TARGETS=("${TARGETS[@]}")
fi

if [[ ${#ALL_TARGETS[@]} -eq 0 ]]; then
    echo -e "${RED}[!] No target specified${NC}"
    usage
    exit 1
fi

# Timestamp & output dir
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
if [[ -z "$OUTDIR" ]]; then
    OUTDIR="./portrecon_${TIMESTAMP}"
fi
mkdir -p "$OUTDIR"

# Clean targets (strip http://, https://, paths)
clean_target() {
    local t="$1"
    t="${t#https://}"
    t="${t#http://}"
    t="${t%%/*}"
    t="${t%%:*}"  # remove port if present
    echo "$t"
}

# ═══════════════════════════════════════════════════════════════
#  Phase 1: masscan (Fast Discovery)
# ═══════════════════════════════════════════════════════════════
run_masscan() {
    local target="$1"
    local outfile="$2"
    
    if ! $USE_MASSCAN; then
        echo -e "${YELLOW}[*] Skipping masscan (--no-masscan)${NC}"
        return 0
    fi
    
    if ! command -v masscan &>/dev/null; then
        echo -e "${YELLOW}[*] masscan not installed, skipping${NC}"
        return 0
    fi
    
    echo -e "${BLUE}[*] Phase 1/3: masscan (${PORT_RANGE}) on ${target}${NC}"
    
    sudo masscan "$target" \
        -p"$PORT_RANGE" \
        --rate=10000 \
        --wait=5 \
        -oG "${outfile}.masscan" 2>/dev/null || {
        echo -e "${YELLOW}[!] masscan failed, will use nmap fallback${NC}"
        return 1
    }
    
    # Extract open ports from grepable output
    grep -oP '\d+/open' "${outfile}.masscan" 2>/dev/null | cut -d'/' -f1 | sort -n | uniq > "${outfile}.ports" || true
    
    local port_count
    port_count=$(wc -l < "${outfile}.ports" 2>/dev/null || echo "0")
    echo -e "${GREEN}[+] masscan done: ${port_count} open ports found${NC}"
}

# ═══════════════════════════════════════════════════════════════
#  Phase 2: nmap (Deep Scan)
# ═══════════════════════════════════════════════════════════════
run_nmap() {
    local target="$1"
    local outfile="$2"
    local ports_file="${outfile}.ports"
    
    echo -e "${BLUE}[*] Phase 2/3: nmap service scan on ${target}${NC}"
    
    local nmap_cmd=(nmap -sV -sC -T4 --open -oN "${outfile}.nmap" -oX "${outfile}.xml")
    
    # If we have masscan ports, use them; otherwise scan top ports
    if [[ -f "$ports_file" && -s "$ports_file" ]]; then
        local ports
        ports=$(tr '\n' ',' < "$ports_file" | sed 's/,$//')
        nmap_cmd+=(-p "$ports")
        echo -e "${CYAN}[*] Targeting masscan-discovered ports: ${ports}${NC}"
    else
        # No masscan results — scan top ports directly
        local top_flag="--top-ports"
        if [[ "$MODE" == "full" ]]; then
            nmap_cmd+=(-p "$PORT_RANGE")
        else
            nmap_cmd+=($top_flag "$TOP_PORTS")
        fi
        echo -e "${CYAN}[*] Scanning top ${TOP_PORTS} ports${NC}"
    fi
    
    # Stealth mode
    if [[ "$MODE" == "stealth" ]]; then
        nmap_cmd+=(-T2 -f --data-length 24)
        echo -e "${YELLOW}[*] Stealth mode: slow & fragmented${NC}"
    fi
    
    nmap_cmd+=("$target")
    
    "${nmap_cmd[@]}" 2>/dev/null || {
        echo -e "${RED}[!] nmap failed on ${target}${NC}"
        return 1
    }
    
    echo -e "${GREEN}[+] nmap done → ${outfile}.nmap${NC}"
}

# ═══════════════════════════════════════════════════════════════
#  Phase 3: httpx (Web Detection)
# ═══════════════════════════════════════════════════════════════
run_httpx() {
    local target="$1"
    local outfile="$2"
    local nmap_xml="${outfile}.xml"
    
    if ! command -v httpx &>/dev/null; then
        echo -e "${YELLOW}[*] httpx not installed, skipping web detection${NC}"
        return 0
    fi
    
    echo -e "${BLUE}[*] Phase 3/3: httpx web detection${NC}"
    
    # Extract web ports from nmap XML
    local web_targets=()
    if [[ -f "$nmap_xml" ]]; then
        # Get ports with http/https service
        while IFS= read -r line; do
            local port service
            port=$(echo "$line" | cut -d'|' -f1)
            service=$(echo "$line" | cut -d'|' -f2)
            if [[ "$service" =~ ^https?$ || "$service" =~ ^ssl/https?$ ]]; then
                web_targets+=("${target}:${port}")
            fi
        done < <(grep -oP 'portid="\K\d+(?=")|<service name="\K[^"]+' "$nmap_xml" 2>/dev/null | paste -d'|' - -)
    fi
    
    # Fallback: probe common web ports
    if [[ ${#web_targets[@]} -eq 0 ]]; then
        web_targets=("${target}:80" "${target}:443" "${target}:8080" "${target}:8443")
    fi
    
    # Run httpx
    printf '%s\n' "${web_targets[@]}" | httpx \
        -silent \
        -title \
        -status-code \
        -tech-detect \
        -follow-redirects \
        -o "${outfile}.httpx" 2>/dev/null || true
    
    local web_count
    web_count=$(wc -l < "${outfile}.httpx" 2>/dev/null || echo "0")
    echo -e "${GREEN}[+] httpx done: ${web_count} web services detected${NC}"
}

# ═══════════════════════════════════════════════════════════════
#  Main Loop
# ═══════════════════════════════════════════════════════════════
echo -e "${BOLD}${CYAN}"
echo "═══════════════════════════════════════════════"
echo "  Targets : ${#ALL_TARGETS[@]}"
echo "  Mode    : ${MODE}"
echo "  Ports   : ${PORT_RANGE}"
echo "  Output  : ${OUTDIR}/"
echo "  Masscan : $($USE_MASSCAN && echo 'ON' || echo 'OFF')"
echo "═══════════════════════════════════════════════"
echo -e "${NC}"

TOTAL=${#ALL_TARGETS[@]}
CURRENT=0

for raw_target in "${ALL_TARGETS[@]}"; do
    ((CURRENT++))
    
    # Skip empty lines
    [[ -z "${raw_target// }" ]] && continue
    
    TARGET=$(clean_target "$raw_target")
    TARGET_SAFE="${TARGET//[^a-zA-Z0-9._-]/_}"
    OUTBASE="${OUTDIR}/${TARGET_SAFE}"
    
    echo -e "\n${BOLD}${CYAN}[${CURRENT}/${TOTAL}] Scanning: ${TARGET}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Run phases
    run_masscan "$TARGET" "$OUTBASE"
    run_nmap "$TARGET" "$OUTBASE"
    run_httpx "$TARGET" "$OUTBASE"
    
    echo -e "${GREEN}[✓] ${TARGET} complete${NC}"
done

# ═══════════════════════════════════════════════════════════════
#  Generate Report
# ═══════════════════════════════════════════════════════════════
REPORT="${OUTDIR}/REPORT.md"

echo -e "\n${BLUE}[*] Generating report → ${REPORT}${NC}"

cat > "$REPORT" << 'REPORT_HEADER'
# 🦅 PortRecon Scan Report

| # | Target | Open Ports | Web Services | Key Services |
|---|--------|------------|--------------|--------------|

REPORT_HEADER

for raw_target in "${ALL_TARGETS[@]}"; do
    [[ -z "${raw_target// }" ]] && continue
    TARGET=$(clean_target "$raw_target")
    TARGET_SAFE="${TARGET//[^a-zA-Z0-9._-]/_}"
    OUTBASE="${OUTDIR}/${TARGET_SAFE}"
    
    # Count open ports
    PORT_COUNT=0
    KEY_SERVICES=""
    
    if [[ -f "${OUTBASE}.nmap" ]]; then
        PORT_COUNT=$(grep -c '/open/' "${OUTBASE}.nmap" 2>/dev/null || echo "0")
        # Extract key service names
        KEY_SERVICES=$(grep -oP '\d+/\w+/\w+//\w+//[^/]+' "${OUTBASE}.nmap" 2>/dev/null | \
            awk -F'//' '{print $3}' | sort -u | head -5 | tr '\n' ', ' | sed 's/,$//')
    fi
    
    # Count web services
    WEB_COUNT=0
    [[ -f "${OUTBASE}.httpx" ]] && WEB_COUNT=$(wc -l < "${OUTBASE}.httpx" 2>/dev/null || echo "0")
    
    echo "| $TARGET | $PORT_COUNT | $WEB_COUNT | ${KEY_SERVICES:-n/a} |" >> "$REPORT"
done

cat >> "$REPORT" << EOF

---
**Scan Info:**
- Mode: \`${MODE}\`
- Port Range: \`${PORT_RANGE}\`
- Timestamp: \`${TIMESTAMP}\`
- Output Dir: \`${OUTDIR}/\`

**Generated by [PortRecon](https://github.com/muhammad194494-pixel/malcu) 🦅**
EOF

# ═══════════════════════════════════════════════════════════════
#  Summary
# ═══════════════════════════════════════════════════════════════
echo -e "\n${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║  🦅  PortRecon Complete!                            ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${BOLD}Output:${NC}  ${OUTDIR}/"
echo -e "${BOLD}Report:${NC}  ${REPORT}"
echo ""
echo -e "${CYAN}Files per target:${NC}"
echo "  *.nmap    — nmap service scan (human-readable)"
echo "  *.xml     — nmap XML output (machine-parseable)"
echo "  *.masscan — masscan grepable output (if used)"
echo "  *.ports   — extracted open port list"
echo "  *.httpx   — web service detection (if httpx installed)"
echo ""
echo -e "${YELLOW}${BOLD}Next:${NC} Take interesting ports → dig deeper with vuln scanners 🦅"
