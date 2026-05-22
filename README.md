# 🦅 Malcu — Cyber Guardian Spirit

> *"Know your enemy. Hack the system. Fix the gap."*

**Malcu** adalah AI spesialis keamanan siber — mencakup offensive security (red team) dan defensive security (blue team). Dirancang dengan *attacker mindset, ethical core*: berpikir seperti hacker profesional untuk memahami, menguji, dan mengamankan sistem.

---

## 🎯 Spesialisasi

| Area | Deskripsi |
|------|-----------|
| 🐛 **Bug Bounty** | Recon → Exploit → Report. Web, API, mobile, cloud. |
| ⚔️ **Penetration Testing** | Network, web app, API, wireless, physical. Full kill chain. |
| 🔬 **Reverse Engineering** | Binary analysis, malware reversing, firmware extraction. |
| 🚩 **CTF** | Binary exploitation, web, crypto, forensics, reversing, pwn. |
| 🛡 **Defensive** | Hardening, detection engineering, incident response, threat hunting. |
| 🔧 **Tool Development** | Automation scripts, custom exploits, fuzzing harness, wordlist generator. |

---

## 📂 Struktur Repo

```
malcu/
├── README.md                  # Lo ada disini
├── SOUL.md                    # Identitas & prinsip inti
├── LICENSE                    # MIT
├── .gitignore
├── tools/                     # Toolkit custom
│   ├── recon/                 # Subdomain enum, port scan, screenshot
│   ├── exploit/               # PoC exploit scripts
│   ├── wordlist/              # Custom wordlist generator
│   └── utils/                 # Helper scripts
├── labs/                      # Lab simulasi (Docker Compose)
│   ├── web-vuln/              # OWASP Top 10 lab
│   ├── active-directory/      # AD lab
│   └── api-lab/              # API security testing lab
├── ctf/                       # CTF writeups & solve scripts
│   ├── web/
│   ├── pwn/
│   ├── crypto/
│   ├── forensics/
│   └── rev/
├── research/                  # Research notes & findings
├── methodology/               # Pentest & bug bounty methodology
└── cheatsheets/               # Quick reference cheatsheets
```

---

## 🛠 Tools

### 🦅 SubRecon — Subdomain Enumeration Pipeline

Passive recon multi-source + DNS resolution + port scan + auto report.

**Sumber data:** subfinder, assetfinder, crt.sh, AlienVault OTX

```bash
# Basic scan
./tools/recon/subrecon.sh target.com

# Deep scan (tambah brute-force + permutasi)
./tools/recon/subrecon.sh target.com --deep

# Fast scan (hanya passive, skip brute)
./tools/recon/subrecon.sh target.com --fast
```

**Dependensi:** subfinder, assetfinder, jq, httpx, naabu/nmap

**Output:** `recon/<target>/` berisi:
- `subdomains.txt` — semua subdomain hasil enum
- `alive.txt` — subdomain live (HTTP/HTTPS)
- `alive_full.txt` — subdomain live + status code + title + tech
- `ports.txt` — open ports summary
- `REPORT.md` — laporan ringkasan

---

### 🔥 PortRecon — Fast Port Scanner Wrapper

3-phase pipeline: masscan (speed) → nmap (depth) → httpx (web detection)

```bash
# Default: top 1000 ports
./tools/recon/portrecon.sh target.com

# Full 65535 ports
./tools/recon/portrecon.sh target.com --full

# Stealth mode (slow, fragmented, harder to detect)
./tools/recon/portrecon.sh target.com --stealth

# Mass scan dari list target
./tools/recon/portrecon.sh -l subs.txt
```

**Dependensi:** masscan, nmap, httpx

**Output:** `recon/<target>/ports/` berisi:
- `masscan.txt` — raw masscan output
- `nmap.txt` — nmap service version detection
- `web.txt` — HTTP services detected
- `REPORT.md` — laporan ringkasan

---

## 🚀 Quick Start

```bash
# Clone
git clone git@github.com:muhammad194494-pixel/malcu.git
cd malcu

# Install Go tools (subfinder, assetfinder, httpx, naabu)
./tools/recon/subrecon.sh --install-tools

# Run subdomain enumeration
./tools/recon/subrecon.sh example.com --deep

# Run port scan on discovered subdomains
./tools/recon/portrecon.sh -l recon/example.com/alive.txt

# Setup lab environment
cd labs/web-vuln
docker-compose up -d
```

---

## 🔧 Tech Stack

![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=flat&logo=go&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Burp Suite](https://img.shields.io/badge/Burp_Suite-FF6633?style=flat&logo=burp-suite&logoColor=white)
![Nmap](https://img.shields.io/badge/Nmap-4682B4?style=flat&logo=nmap&logoColor=white)
![Ghidra](https://img.shields.io/badge/Ghidra-FF0000?style=flat&logo=ghidra&logoColor=white)
![Metasploit](https://img.shields.io/badge/Metasploit-2596BE?style=flat&logo=metasploit&logoColor=white)
![Wireshark](https://img.shields.io/badge/Wireshark-1679A7?style=flat&logo=wireshark&logoColor=white)

---

## ⚠️ Legal

Semua konten dalam repo ini ditujukan untuk:
- Pembelajaran dan penelitian keamanan siber
- Pengujian pada sistem sendiri (lab pribadi)
- Program bug bounty resmi
- Kompetisi CTF

**Dilarang keras** menggunakan tools atau teknik apapun untuk aktivitas ilegal. Selalu dapatkan izin tertulis sebelum menguji sistem pihak ketiga.

---

## 🤝 Kontributor

- **Malcu** 🦅 — AI Cyber Guardian
- **Mael** — Human handler & security practitioner

---

*"The best defense is understanding the offense."*
