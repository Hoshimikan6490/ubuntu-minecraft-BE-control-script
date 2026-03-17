#!/bin/bash

# ディレクトリ定義
BASE=/home/minecraft/bedrock
SERVER=$BASE/server
TEMP=$BASE/serverUpdateTemp

# ログ関数
log_info() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" | tee -a "$LOG"
}

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG"
}

# baseディレクトリへの移動
cd $BASE || exit 1

# 最新バージョンURLの取得
RandNum=$((1 + RANDOM % 5000))
API="https://net-secondary.web.minecraft-services.net/api/v1.0/download/links"
JSON=$(curl -s "$API")
URL=$(echo "$JSON" | grep -oE '"downloadType":"serverBedrockLinux","downloadUrl":"[^"]+"' \
 | sed -E 's/.*"downloadUrl":"([^"]+)".*/\1/')

# バージョン抽出
FILE=$(basename "$URL")
VERSION=${FILE#bedrock-server-}
VERSION=${VERSION%.zip}

# 現在のバージョンを取得
CUR_VERSION=$(cat $BASE/version.txt)

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

echo $VERSION > $BASE/version.txt

log_info "stopping server"
screen -S minecraftBe -p 0 -X stuff 'stop\015'

sleep 10

mkdir -p $TEMP
rm -rf $TEMP/*

log_info "replicating world data"
cp -r $SERVER/worlds $TEMP/

log_info "replicating server.properties"
cp $SERVER/server.properties $TEMP/

log_info "replicating permissions.json"
cp $SERVER/permissions.json $TEMP/

log_info "replicating allowlist.json"
cp $SERVER/allowlist.json $TEMP/

log_info "replicating structures"
cp -r $SERVER/structures $TEMP/

log_info "all replication done"

cd $SERVER || exit 1

log_info "obtaining server zip"
wget "$URL" --user-agent=safari

log_info "unzipping"
unzip -o ${URL##*/} >/dev/null

log_info "removing zip"
rm bedrock-server*.zip

log_info "new server deployment done"

log_info "recovering server.properties"
cp $TEMP/server.properties $SERVER/

log_info "recovering permissions.json"
cp $TEMP/permissions.json $SERVER/

log_info "recovering allowlist.json"
cp $TEMP/allowlist.json $SERVER/

log_info "recovering structures"
cp -r $TEMP/structures $SERVER/

log_info "recovering worlds"
cp -r $TEMP/worlds $SERVER/

log_info "all recovery done"

log_info "rebooting in 5 seconds"
sleep 5

log_info "restarting server"
sudo reboot
