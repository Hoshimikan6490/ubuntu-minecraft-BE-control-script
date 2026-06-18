#!/usr/bin/env bash
set -euo pipefail

# Load common settings
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/common.sh"

# Forward any args to stop.sh
"$SCRIPT_DIR/stop.sh" "$@ --reboot"

# Short pause to let the process stop
sleep 3

# Start server
"$SCRIPT_DIR/run.sh"
