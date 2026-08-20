#!/usr/bin/env bash
set -Eeuo pipefail
APP_DIR_BASE=${APP_DIR_BASE:-${APP_DIR:-/opt/chatgpt2api}}; PORT=${PORT:-4000}; REPO_URL=${REPO_URL:-https://github.com/qingan123/chatgpt2api.git}
fail(){ echo "ERROR: $*" >&2; exit 1; }; read_tty(){ local v; IFS= read -r -p "$1" v </dev/tty || fail '需要交互终端'; printf '%s' "$v"; }
[[ $EUID -eq 0 ]] || fail '请使用 root/sudo'; command -v git >/dev/null || fail '缺少 git'; command -v docker >/dev/null || fail '缺少 docker'; docker compose version >/dev/null || fail '需要 Docker Compose v2'
PORT=$(read_tty "端口 [$PORT]: "); PORT=${PORT:-4000}; [[ $PORT =~ ^[0-9]+$ ]] || fail '端口无效'
APP_DIR="$APP_DIR_BASE"; [[ "$PORT" == 4000 ]] || APP_DIR="${APP_DIR_BASE}-${PORT}"
printf '安装目录自动设置为: %s\n' "$APP_DIR"
ss -ltn "sport = :$PORT" 2>/dev/null | grep -q LISTEN && fail "端口 $PORT 已被占用"
mkdir -p "$APP_DIR"; [[ -z "$(find "$APP_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]] || fail '目标目录非空'; git clone --depth 1 "$REPO_URL" "$APP_DIR"; cd "$APP_DIR"; cp -n .env.example .env 2>/dev/null || true; chmod 600 .env
sed -i -E "s/\"[0-9]+:80\"/\"$PORT:80\"/" docker-compose.yml
docker compose --env-file .env up -d --build
for _ in {1..60}; do curl -fsS --max-time 2 "http://127.0.0.1:$PORT/health?format=json" >/dev/null && break; sleep 1; done
curl -fsS --max-time 2 "http://127.0.0.1:$PORT/health?format=json" >/dev/null || { docker compose logs --tail=100; exit 1; }
ip="${PUBLIC_HOST:-$(curl -4fsS --max-time 5 https://api.ipify.org || true)}"; url=${ip:+http://$ip:$PORT/}; [[ -n "$url" ]] || url='公网IP探测失败，请检查安全组/UFW'; printf '部署完成。\n公网地址: %s\n本机地址: http://127.0.0.1:%s/\n端口: %s（由HOST_PORT发布）\n目录: %s\n' "$url" "$PORT" "$PORT" "$APP_DIR"
