#!/bin/bash

RUN_STATUS_MC=`screen -ls | grep minecraftBe | grep -v S-minecraft | wc -w`

if [ $RUN_STATUS_MC -eq 0 ]; then    # minecraftという名前のscreenがなければ新しく作る
        # Start the bedrock server
        echo starting new server
        cd ~/bedrock/server/
        screen -dm -S minecraftBe /bin/bash -c ~/bedrock/server/bedrock_server
else
        echo "Server already running.\n"    # minecraftというscreenがあるならばホストは実行中
fi
