#!/usr/bin/env bash
set -euo pipefail

# Load common settings and logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/common.sh"

cd "$BASE_DIR" || exit 1

# 最新バージョンURLの取得
API="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
JSON=$(curl -s "$API")
URL=$(echo "$JSON" | grep -oE '"downloadType":"serverBedrockLinux","downloadUrl":"[^"]+"' | sed -E 's/.*"downloadUrl":"([^"]+)".*/\1/')
# バージョン抽出
FILE=$(basename "$URL")
VERSION=${FILE#bedrock-server-}
VERSION=${VERSION%.zip}

# 現在のバージョンの取得
CUR_VERSION=""
if [ -f "$VERSION_FILE" ]; then
  CUR_VERSION=$(cat "$VERSION_FILE") || true
fi

log_info "URL shown: $URL"

if [ -z "$URL" ]; then
  log_error "invalid update link"
  log_info "rebooting in 5 seconds"
  sleep 5
  sudo reboot
  exit 1
elif [ "$CUR_VERSION" = "$VERSION" ]; then
  log_info "the server is the latest"
  log_info "rebooting in 5 seconds"
  sleep 5
  sudo reboot
  exit 0
fi

echo "$VERSION" > "$BASE_DIR/version.txt"

log_info "stopping server"
screen -S "$SCREEN_NAME" -p 0 -X stuff 'stop\015'

sleep 10

mkdir -p "$TEMP_DIR"
rm -rf "$TEMP_DIR"/* || true

log_info "replicating world data"
cp -r "$SERVER_DIR/worlds" "$TEMP_DIR/"

log_info "replicating server.properties"
cp "$SERVER_DIR/server.properties" "$TEMP_DIR/"

log_info "replicating permissions.json"
cp "$SERVER_DIR/permissions.json" "$TEMP_DIR/"

log_info "replicating allowlist.json"
cp "$SERVER_DIR/allowlist.json" "$TEMP_DIR/"

log_info "all replication done"

cd "$SERVER_DIR" || exit 1

log_info "obtaining server zip"
ZIP_NAME="$FILE"
wget -q -O "$ZIP_NAME" "$URL"

log_info "unzipping"
unzip -o "$ZIP_NAME" >/dev/null

log_info "removing zip"
rm -f "$ZIP_NAME"

log_info "new server deployment done"

log_info "recovering server.properties"
cp "$TEMP_DIR/server.properties" "$SERVER_DIR/"

log_info "recovering permissions.json"
cp "$TEMP_DIR/permissions.json" "$SERVER_DIR/"

log_info "recovering allowlist.json"
cp "$TEMP_DIR/allowlist.json" "$SERVER_DIR/"

log_info "recovering worlds"
cp -r "$TEMP_DIR/worlds" "$SERVER_DIR/"

log_info "all recovery done"

log_info "rebooting in 5 seconds"
sleep 5

log_info "restarting server"
sudo reboot
