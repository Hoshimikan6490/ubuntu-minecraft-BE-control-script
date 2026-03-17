#!/bin/bash

# Parse arguments
IMMEDIATE=false
if [[ "$1" == "--now" ]] || [[ "$1" == "--immediate" ]]; then
    IMMEDIATE=true
fi

# Check if minecraft screen session is running
if screen -S minecraftBe -p 0 -X stuff ''; then
    echo "Minecraft server is running, proceeding with shutdown."
else
    echo "Minecraft server is not running. Exiting."
    exit 1
fi

# Display presets
STR_1="tellraw @a {\"rawtext\":[{\"text\":\"[SERVER] シャットダウン "
STR_2=" 秒前\"}]}\\015"
STR_3=" 分前\"}]}\\015"

# 3分以上をカウントする場合に備えてやや冗長な記述になってます
count_down () {
    # 残り2分までのメッセージ
    for i in 4 3 2; do
        sleep 1m
        screen -S minecraftBe -p 0 -X stuff "$STR_1$i$STR_3"
    done

    # 残り60秒から20秒までのメッセージ
    for i in 60 50 40 30 20; do
        sleep 10s
        screen -S minecraftBe -p 0 -X stuff "$STR_1$i$STR_2"
    done

    # 残り10秒から0秒までのメッセージ
    for i in {10..0}; do
        sleep 1s
        screen -S minecraftBe -p 0 -X stuff "$STR_1$i$STR_2"
    done
}


# Check if immediate shutdown is requested
if [ "$IMMEDIATE" = true ]; then
    # Immediate shutdown
    screen -S minecraftBe -p 0 -X stuff 'tellraw @a {"rawtext":[{"text":"[SERVER] サーバーを直ちにシャットダウンします。"}]}\015'
    sleep 1s
else
    # Display the announcement of shutting down
    screen -S minecraftBe -p 0 -X stuff 'tellraw @a {"rawtext":[{"text":"[SERVER] このサーバーは５分後にシャットダウンします。"}]}\015'

    # count down to stop the bedrock server
    count_down
fi

# Ending message
screen -S minecraftBe -p 0 -X stuff 'tellraw @a {"rawtext":[{"text":"サーバーをシャットダウンしています..."}]}\015'

# Shutting down the host
screen -S minecraftBe -p 0 -X stuff 'stop\015'

echo ended
