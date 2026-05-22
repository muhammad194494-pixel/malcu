# 🦅 Malcu — Cyber Guardian Spirit

> *"Know your enemy. Hack the system. Fix the gap."*

<p align="center">
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Made%20with-%F0%9F%A6%85%20Spirit-red?style=for-the-badge" alt="Made with Spirit">
</p>

---

## 🧬 About

**Malcu** adalah arsenal keamanan siber — mencakup **offensive security** (red team) dan **defensive security** (blue team). Dirancang dengan *attacker mindset, ethical core*: berpikir seperti hacker profesional untuk memahami, menguji, dan mengamankan sistem.

Repositori ini adalah pusat dokumentasi, tools, lab, dan riset untuk perjalanan security research.

---

## 📂 Repository Structure

```
malcu/
├── README.md                  ← Dokumentasi utama
├── SOUL.md                    ← Jiwa & prinsip inti
├── LICENSE                    ← MIT License
├── .gitignore                 ← No secrets, no junk
│
├── tools/                     # 🛠 Custom security toolkit
│   └── recon/
│       ├── subrecon.sh        # Subdomain enumeration pipeline
│       └── portrecon.sh       # Port scanner wrapper (masscan+nmap+httpx)
│
├── labs/                      # 🧪 Vulnerable lab environments
├── ctf/                       # 🚩 CTF writeups & solve scripts
├── research/                  # 🔬 Research notes & findings
├── methodology/               # 📋 Pentest & bug bounty methodology
└── cheatsheets/               # 📝 Quick reference guides
```

---

## 🎯 Specializations

| Domain | Description |
|--------|-------------|
| 🐛 **Bug Bounty** | Recon → Exploit → Report. Web, API, mobile, cloud. |
| ⚔️ **Penetration Testing** | Network, web app, API, wireless. Full kill chain. |
| 🔬 **Reverse Engineering** | Binary analysis, malware reversing, firmware extraction. |
| 🚩 **CTF** | Binary exploitation, web, crypto, forensics, reversing. |
| 🛡 **Blue Team** | Hardening, detection engineering, incident response. |
| 🔧 **Tool Development** | Automation scripts, custom exploits, fuzzing harness. |

---

## 🛠 Arsenal

### 🦅 SubRecon — Subdomain Enumeration Pipeline

Multi-source passive recon + DNS resolution + port scan + auto report generation.

**Sources:** `subfinder` · `assetfinder` · `crt.sh` · `AlienVault OTX`

```bash
# Basic scan
./tools/recon/subrecon.sh target.com

# Deep scan (brute-force + permutation)
./tools/recon/subrecon.sh target.com --deep

# Fast scan (passive only)
./tools/recon/subrecon.sh target.com --fast
```

**Dependencies:** `subfinder` `assetfinder` `jq` `httpx` `naabu` / `nmap`

**Output Structure:** `recon/<target>/`
```
recon/<target>/
├── subdomains.txt       # All discovered subdomains
├── alive.txt            # Live hosts (HTTP/HTTPS)
├── alive_full.txt       # Live + status code + title + tech stack
├── ports.txt            # Open ports summary
└── REPORT.md            # Executive summary report
```

---

### 🔥 PortRecon — Fast Port Scanner Wrapper

3-phase pipeline: `masscan` (speed) → `nmap` (depth) → `httpx` (web detection)

```bash
# Default: top 1000 ports
./tools/recon/portrecon.sh target.com

# Full 65535 ports
./tools/recon/portrecon.sh target.com --full

# Stealth mode (slow, fragmented)
./tools/recon/portrecon.sh target.com --stealth

# Mass scan from target list
./tools/recon/portrecon.sh -l subs.txt
```

**Dependencies:** `masscan` `nmap` `httpx`

**Output Structure:** `recon/<target>/ports/`
```
recon/<target>/ports/
├── masscan.txt          # Raw masscan output
├── nmap.txt             # Nmap service version detection
├── web.txt              # HTTP services detected
└── REPORT.md            # Executive summary report
```

---

## 🚀 Quick Start

```bash
# 1. Clone the arsenal
git clone git@github.com:muhammad194494-pixel/malcu.git
cd malcu

# 2. Install dependencies (Debian/Ubuntu)
sudo apt install -y subfinder httpx naabu nmap masscan jq

# 3. Run subdomain recon
./tools/recon/subrecon.sh example.com --deep

# 4. Port scan discovered hosts
./tools/recon/portrecon.sh -l recon/example.com/alive.txt
```

### 📋 Recommended Workflow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  SubRecon    │────▶│  PortRecon   │────▶│   DirFuzz    │
│  (--deep)    │     │  (--full)    │     │              │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       ▼                    ▼                    ▼
   alive.txt           open ports          hidden dirs
       └────────────────────┼────────────────────┘
                            ▼
                  Manual Deep Testing
```

---

## 🔧 Tech Stack

<p align="center">
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white" alt="Go">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/Nmap-4682B4?style=for-the-badge&logo=nmap&logoColor=white" alt="Nmap">
  <img src="https://img.shields.io/badge/Burp_Suite-FF6633?style=for-the-badge&logo=burp-suite&logoColor=white" alt="Burp Suite">
  <img src="https://img.shields.io/badge/Ghidra-FF0000?style=for-the-badge&logo=ghidra&logoColor=white" alt="Ghidra">
</p>

---

## ⚠️ Legal & Ethics

> **Legal scope is sacred.**

Seluruh konten repositori ini ditujukan **eksklusif** untuk:

- ✅ Pembelajaran dan penelitian keamanan siber
- ✅ Pengujian pada sistem milik sendiri (private lab)
- ✅ Program bug bounty resmi (dengan izin tertulis)
- ✅ Kompetisi Capture The Flag (CTF)

**Dilarang keras** menggunakan tools atau teknik apapun untuk aktivitas ilegal atau tanpa izin eksplisit.

---

## 📜 Principles

| Principle | Description |
|-----------|-------------|
| 🔪 **Attacker Mindset** | Pahami cara berpikir penyerang untuk membangun pertahanan efektif |
| 🛡 **Ethical Core** | Keahlian digunakan untuk melindungi, bukan merusak |
| 📖 **Transparent & Educational** | Dokumentasi jelas, metode terstruktur, hasil reproducible |
| 🤝 **Collaborative** | Terbuka untuk kontribusi dan diskusi teknis |

Baca selengkapnya di [`SOUL.md`](SOUL.md).

---

## 👥 Contributors

- **Malcu** 🦅 — AI Cyber Guardian
- **Mael** — Human handler & security practitioner

---

<p align="center">
  <i>"The best defense is understanding the offense."</i> 🦅
</p>
