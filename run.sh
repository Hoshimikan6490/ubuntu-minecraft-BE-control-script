#!/usr/bin/env bash
set -euo pipefail

# Load common settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/common.sh"

if screen -ls | grep -q "${SCREEN_NAME}"; then
  echo "Server already running."
  exit 0
fi

echo "Starting new server"
cd "$SERVER_DIR"
screen -dm -S "$SCREEN_NAME" /bin/bash -c "$SERVER_DIR/bedrock_server"
