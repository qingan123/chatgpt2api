#!/usr/bin/env bash
set -Eeuo pipefail
read -r -p '目录 [/opt/chatgpt2api]: ' d </dev/tty; d=${d:-/opt/chatgpt2api}; read -r -p '端口 [4000]: ' p </dev/tty; p=${p:-4000}; git clone https://github.com/qingan123/chatgpt2api.git "$d"; cd "$d"; cp -n .env.example .env 2>/dev/null || true; sed -i "s/^HOST_PORT=.*/HOST_PORT=$p/" .env 2>/dev/null || true; docker compose --env-file .env up -d
