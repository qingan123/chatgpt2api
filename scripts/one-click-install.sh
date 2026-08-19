#!/usr/bin/env bash
set -Eeuo pipefail
read -r -p '目录 [/opt/chatgpt2api-official]: ' d </dev/tty; d=${d:-/opt/chatgpt2api-official}; git clone https://github.com/basketikun/chatgpt2api.git "$d"; cd "$d"; docker compose up -d
