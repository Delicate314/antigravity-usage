#!/bin/bash
# Runs on a fresh macOS runner. Launch the app directly from its released ZIP.
set -euo pipefail
stage=$(mktemp -d)
ditto -x -k dist/Antigravity-Usage-macOS-"$(uname -m)".zip "$stage"
app="$stage/Antigravity Usage.app"
codesign --verify --deep --strict "$app"
for binary in UsageOrb UsageBackend; do
  lipo -verify_arch "$(uname -m)" "$app/Contents/MacOS/$binary"
done
open "$app"
curl -fsS --retry 12 --retry-connrefused --retry-delay 1 http://127.0.0.1:18742/usage.json | python3 -c 'import json,sys; assert json.load(sys.stdin)["rows"] == []'
mkdir -p ~/.gemini/antigravity/conversations
python3 - <<'PY'
import sqlite3
from pathlib import Path
root = Path.home() / ".gemini/antigravity"
with sqlite3.connect(root/"conversations/ci.db") as db:
    db.execute("CREATE TABLE gen_metadata (idx INTEGER, data BLOB)")
    db.execute("CREATE TABLE steps (idx INTEGER, metadata BLOB)")
    name = b"gemini-4-neon"
    model = bytes([154,1,len(name)])+name
    db.execute("INSERT INTO gen_metadata VALUES(0,?)",(bytes([10,len(model)])+model,))
    db.execute("INSERT INTO steps VALUES(0,?)",(bytes.fromhex("0a0208014a0410071803"),))
with sqlite3.connect(root/"conversation_summaries.db") as db:
    db.execute("CREATE TABLE conversation_summaries (conversation_id TEXT,title TEXT)")
    db.execute("INSERT INTO conversation_summaries VALUES('ci','Release test')")
PY
curl -fsS http://127.0.0.1:18742/usage.json | python3 -c 'import sys,json; d=json.load(sys.stdin); assert d["rows"]==[[1,"gemini-4-neon",7,3,0,0,"ci"]] and d["titles"]["ci"]=="Release test" and not d["issues"],d'
curl -fsS http://127.0.0.1:18742/ > "$stage/page"
grep -q 'id="rankPanel"' "$stage/page"
pgrep -x UsageOrb
