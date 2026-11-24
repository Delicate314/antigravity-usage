#!/bin/zsh
cd "${0:A:h}"
if curl -fsS --max-time 2 http://127.0.0.1:18742/ | grep -q 'Antigravity 用量'; then
  open http://127.0.0.1:18742/
else
  exec python3 -B app.py
fi
