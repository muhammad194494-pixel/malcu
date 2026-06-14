# Learned: Cloudflare Tunnel Setup
Tanggal: 2026-06-07
Cara ekspos service lokal ke internet tanpa buka port:
1. wget cloudflared .deb → dpkg -i
2. cloudflared tunnel login
3. cloudflared tunnel create [nama]
4. cloudflared tunnel route dns [id] [subdomain]
5. Buat config.yml dengan ingress rules
6. cloudflared tunnel run [id]
Satu tunnel ID bisa handle banyak subdomain sekaligus.
