#!/usr/bin/env bash
set -euo pipefail

# 手動設定部
## Minecraftサーバーのベースディレクトリを指定してください
BASE_DIR="/directory/to/your/minecraft/server"
## Minecraftサーバーのワールドディレクトリを指定してください
WORLD_NAME="world_name"
## Screenセッションの名前を指定してください
SCREEN_NAME="screen_session_name"
## 保存するバックアップの世代数を指定してください
NUM_GENS=3

# 共通設定 (Ubuntu 向けのパスを想定)
SERVER_DIR="${BASE_DIR}/server"
WORLD_DIR="${SERVER_DIR}/worlds/${WORLD_NAME}"
VERSION_FILE="${SERVER_DIR}/.version"
TEMP_DIR="${BASE_DIR}/serverUpdateTemp"
BACKUP_DIR="${BASE_DIR}/backups"
LOG_FILE="${BASE_DIR}/log.txt"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() { log "INFO: $1"; }
log_error() { log "ERROR: $1"; }

export BASE_DIR SERVER_DIR TEMP_DIR BACKUP_DIR LOG_FILE SCREEN_NAME
