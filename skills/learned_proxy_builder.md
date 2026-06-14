# Learned: Proxy Builder
Tanggal: 2026-06-07
Cara buat proxy mini OpenAI-compatible dari client script:
1. Baca client script yang ada (misal blackbox_agent.py)
2. Wrap dengan FastAPI + endpoint POST /v1/chat/completions
3. Format response OpenAI-compatible (choices, message, usage)
4. Strip think tags: re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL)
5. Jalankan port berbeda (7004, 7005, dst)
