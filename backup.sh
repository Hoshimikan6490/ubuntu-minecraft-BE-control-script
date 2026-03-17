#!/bin/bash

# ログファイル
LOG_FILE=/home/minecraft/bedrock/log.txt

# バックアップdir
BACKUP_DIR=/home/minecraft/bedrock/backups

# バックアップ元
TARGET_DIR="/home/minecraft/bedrock/server/worlds/survival_world"

# 毎日のバックアップ名
DAILY_DIR=${BACKUP_DIR}/daily/`date +%Y-%m-%d_%H:%M:%S`

# 毎月のバックアップ名
MONTHLY_DIR=${BACKUP_DIR}/monthly/`date +%Y-%m`

# 毎日バックアップの保管数
NUM_GENS=3


# コマンドライン引数からバックアップモードを指定
# 0 : 毎日バックアップ
# 1 : 毎月バックアップ
BACKUP_MODE=$1

# 引数チェック
if [ -z "$BACKUP_MODE" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: No backup mode specified. (0: daily,1: monthly)" | tee -a $LOG_FILE
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Backup script started (mode: $BACKUP_MODE)" | tee -a $LOG_FILE

# 古いバックアップを消去する関数
delete_file () {
    CNT=0
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Cleaning old backups (keeping $NUM_GENS generations)" | tee -a $LOG_FILE
    eval "cd $BACKUP_DIR/daily"
    if [ $? -ne 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to change directory to $BACKUP_DIR/daily" | tee -a $LOG_FILE
        return 1
    fi
    for file in `ls -1t *zip 2>/dev/null`
    do
        CNT=$((CNT+1))
        if [ $CNT -le $NUM_GENS ]; then
            continue
        fi
        eval "rm ${file}"
        if [ $? -eq 0 ]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Deleted old backup: ${file}" | tee -a $LOG_FILE
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to delete: ${file}" | tee -a $LOG_FILE
        fi
    done
}

# zipファイルを作成する関数
make_zip () {
    local backup_path="${1}.zip"
    local target_dir="${2}"
    
    # 対象ディレクトリの存在確認
    if [ ! -d "${target_dir}" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Target directory does not exist: ${target_dir}" | tee -a $LOG_FILE
        return 1
    fi
    
    # バックアップディレクトリの作成
    local backup_dir=$(dirname "${backup_path}")
    mkdir -p "${backup_dir}"
    if [ $? -ne 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to create backup directory: ${backup_dir}" | tee -a $LOG_FILE
        return 1
    fi
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Creating backup: ${backup_path}" | tee -a $LOG_FILE
    
    # 対象ディレクトリの親ディレクトリに移動してzipを作成
    local parent_dir=$(dirname "${target_dir}")
    local target_name=$(basename "${target_dir}")
    
    cd "${parent_dir}"
    if [ $? -ne 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to change directory to: ${parent_dir}" | tee -a $LOG_FILE
        return 1
    fi
    
    zip -r -q "${backup_path}" "${target_name}"
    if [ $? -eq 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Backup created successfully: ${backup_path}" | tee -a $LOG_FILE
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to create backup: ${backup_path}" | tee -a $LOG_FILE
        return 1
    fi
}


# BACKUP_MODEの判定
if [ $BACKUP_MODE -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Daily backup mode selected" | tee -a $LOG_FILE
    make_zip $DAILY_DIR $TARGET_DIR
    if [ $? -eq 0 ]; then
        delete_file
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Daily backup failed" | tee -a $LOG_FILE
        exit 1
    fi
elif [ $BACKUP_MODE -eq 1 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Monthly backup mode selected" | tee -a $LOG_FILE
    make_zip $MONTHLY_DIR $TARGET_DIR
    if [ $? -ne 0 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Monthly backup failed" | tee -a $LOG_FILE
        exit 1
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Invalid backup mode: $BACKUP_MODE (must be 0 or 1)" | tee -a $LOG_FILE
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: Backup script completed successfully" | tee -a $LOG_FILE
