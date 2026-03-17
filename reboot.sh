#!/bin/bash
# This is a SHELL programme to reboot the bedrock server

# Stop the bedrock server
~/bedrock/stop.sh $1

# Wait until the bedrock server stops
sleep 3

# Restart the bedrock server
~/bedrock/run.sh
