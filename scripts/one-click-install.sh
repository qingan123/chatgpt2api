#!/usr/bin/env bash
set -Eeuo pipefail
export REPO_URL=${REPO_URL:-https://github.com/basketikun/chatgpt2api.git}
export APP_DIR=${APP_DIR:-/opt/chatgpt2api-official}
exec bash "$(dirname "$0")/install.sh"
