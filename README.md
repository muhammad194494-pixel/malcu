# 🦅 Malcu — Cyber Guardian Spirit

> *"Know your enemy. Hack the system. Fix the gap."*

**Malcu** adalah AI spesialis keamanan siber — mencakup offensive security (red team) dan defensive security (blue team). Dirancang dengan *attacker mindset, ethical core*: berpikir seperti hacker profesional untuk memahami, menguji, dan mengamankan sistem.

---

## 📂 Repo Structure

```text
malcu/
├── README.md                  # Dokumentasi utama (kamu di sini)
├── SOUL.md                    # Jiwa & prinsip inti Malcu
├── LICENSE                    # MIT License
├── .gitignore                 # Git ignore rules (no secrets!)
├── tools/                     # Custom security toolkit
│   └── recon/                 # Reconnaissance tools
│       ├── subrecon.sh        # Subdomain enumeration pipeline
│       └── portrecon.sh       # Port scanner wrapper (masscan+nmap+httpx)
├── labs/                      # Vulnerable lab environments (empty)
├── ctf/                       # CTF writeups & solve scripts (empty)
├── research/                  # Research notes & findings (empty)
├── methodology/               # Pentest & bug bounty methodology (empty)
└── cheatsheets/               # Quick reference guides (empty)
```

---

## 🎯 Spesialisasi

| Area | Deskripsi |
|------|-----------|
| 🐛 **Bug Bounty** | Recon → Exploit → Report. Web, API, mobile, cloud. |
| ⚔️ **Penetration Testing** | Network, web app, API, wireless. Full kill chain. |
| 🔬 **Reverse Engineering** | Binary analysis, malware reversing, firmware extraction. |
| 🚩 **CTF** | Binary exploitation, web, crypto, forensics, reversing. |
| 🛡 **Defensive** | Hardening, detection engineering, incident response. |
| 🔧 **Tool Development** | Automation scripts, custom exploits, fuzzing harness. |

---

## 🛠 Tools

### 🦅 SubRecon — Subdomain Enumeration Pipeline

Multi-source passive recon + DNS resolution + port scan + auto report generation.

**Sources:** `subfinder`, `assetfinder`, `crt.sh`, `AlienVault OTX`

```bash
# Basic scan
./tools/recon/subrecon.sh target.com

# Deep scan (tambah brute-force + permutasi)
./tools/recon/subrecon.sh target.com --deep

# Fast scan (hanya passive, skip brute)
./tools/recon/subrecon.sh target.com --fast
```

**Dependensi:** `subfinder`, `assetfinder`, `jq`, `httpx`, `naabu` / `nmap`

**Output:** `recon/<target>/` berisi:
- `subdomains.txt` — semua subdomain hasil enum
- `alive.txt` — subdomain live (HTTP/HTTPS)
- `alive_full.txt` — subdomain live + status code + title + tech
- `ports.txt` — open ports summary
- `REPORT.md` — laporan ringkasan

---

### 🔥 PortRecon — Fast Port Scanner Wrapper

3-phase pipeline: `masscan` (speed) → `nmap` (depth) → `httpx` (web detection)

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

**Dependensi:** `masscan`, `nmap`, `httpx`

**Output:** `recon/<target>/ports/` berisi:
- `masscan.txt` — raw masscan output
- `nmap.txt` — nmap service version detection
- `web.txt` — HTTP services detected
- `REPORT.md` — laporan ringkasan

---

## 🚀 Quick Start

```bash
# 1. Clone repo
git clone git@github.com:muhammad194494-pixel/malcu.git
cd malcu

# 2. Install dependensi tools (Debian/Ubuntu)
sudo apt install -y subfinder httpx naabu nmap masscan jq

# 3. Jalankan subdomain recon
./tools/recon/subrecon.sh example.com --deep

# 4. Jalankan port scan pada subdomains yang ditemukan
./tools/recon/portrecon.sh -l recon/example.com/alive.txt
```

### 📋 Recommended Workflow

```
SubRecon (--deep)  →  PortRecon (--full)  →  DirFuzz  →  Manual Testing
     ↓                      ↓                    ↓
  alive.txt            open ports            hidden dirs
     ↓                      ↓                    ↓
        └─────►  Cross-reference results  ◄─────┘
```

---

## 🔧 Tech Stack

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnu-bash&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=flat&logo=go&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Nmap](https://img.shields.io/badge/Nmap-4682B4?style=flat&logo=nmap&logoColor=white)
![Burp Suite](https://img.shields.io/badge/Burp_Suite-FF6633?style=flat&logo=burp-suite&logoColor=white)
![Ghidra](https://img.shields.io/badge/Ghidra-FF0000?style=flat&logo=ghidra&logoColor=white)

---

## ⚠️ Legal & Ethics

Semua konten dalam repo ini ditujukan untuk:
- Pembelajaran dan penelitian keamanan siber
- Pengujian pada sistem sendiri (lab pribadi)
- Program bug bounty resmi
- Kompetisi CTF

**Dilarang keras** menggunakan tools atau teknik apapun untuk aktivitas ilegal. Selalu dapatkan izin tertulis sebelum menguji sistem pihak ketiga.

---

## 📜 Prinsip (SOUL.md)

- 🔪 **Attacker Mindset** — Pahami cara berpikir penyerang untuk membangun pertahanan yang efektif.
- 🛡 **Ethical Core** — Keahlian digunakan untuk melindungi, bukan merusak.
- 📖 **Transparan & Edukatif** — Dokumentasi jelas, metode terstruktur, hasil reproducible.
- 🤝 **Kolaborasi** — Terbuka untuk kontribusi dan diskusi teknis.

Baca selengkapnya di [`SOUL.md`](SOUL.md).

---

## 🤝 Kontributor

- **Malcu** 🦅 — AI Cyber Guardian
- **Mael** — Human handler & security practitioner

---

*"The best defense is understanding the offense."*
