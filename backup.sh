#!/usr/bin/env bash
set -euo pipefail

# Load common settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/common.sh"

# Parse mode: accept 0/1 or daily/monthly
MODE_RAW=${1:-}
if [ -z "$MODE_RAW" ]; then
    log_error "No backup mode specified. Usage: $0 <daily|monthly|0|1>"
    exit 1
fi

case "$MODE_RAW" in
    0|daily)
        BACKUP_PATH="${BACKUP_DIR}/daily/$(date +%Y-%m-%d_%H:%M:%S)"
        MODE="daily"
        ;;
    1|monthly)
        BACKUP_PATH="${BACKUP_DIR}/monthly/$(date +%Y-%m)"
        MODE="monthly"
        ;;
    *)
        log_error "Invalid backup mode: $MODE_RAW"
        exit 1
        ;;
esac

log_info "Backup script started (mode: $MODE)"

delete_old_backups() {
    local dir="$BACKUP_DIR/daily"
    log_info "Cleaning old backups in $dir (keeping $NUM_GENS generations)"
    if [ ! -d "$dir" ]; then
        return 0
    fi
    local i=0
    # iterate sorted by mtime newest first
    while IFS= read -r file; do
        i=$((i+1))
        if [ $i -le $NUM_GENS ]; then
            continue
        fi
        rm -f -- "$file" && log_info "Deleted old backup: $file" || log_error "Failed to delete: $file"
    done < <(ls -1t -- "$dir"/*.zip 2>/dev/null || true)
}

# zipファイルを作成する関数
make_zip() {
    local backup_path="${1}.zip"

    # 対象ディレクトリの存在確認
    if [ ! -d "$WORLD_DIR" ]; then
        log_error "Target directory does not exist: $WORLD_DIR"
        return 1
    fi

    # バックアップディレクトリの作成
    local backup_dir
    backup_dir=$(dirname "$backup_path")
    mkdir -p "$backup_dir"

    # 対象のディレクトリの親ディレクトリに移動してzipを作成
    log_info "Creating backup: $backup_path"
    local parent_dir target_name
    parent_dir=$(dirname "$WORLD_DIR")
    target_name=$(basename "$WORLD_DIR")

    (cd "$parent_dir" && zip -r -q "$backup_path" "$target_name") && log_info "Backup created: $backup_path" || { log_error "Failed to create backup: $backup_path"; return 1; }
}

if [ "$MODE" = "daily" ]; then
    log_info "Daily backup mode selected"
    make_zip "$BACKUP_PATH" "$WORLD_DIR"
    delete_old_backups
else
    log_info "Monthly backup mode selected"
    make_zip "$BACKUP_PATH" "$WORLD_DIR"
fi

log_info "Backup script completed successfully"
