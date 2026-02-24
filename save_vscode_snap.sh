#!/bin/bash
set -e

SERVER_DIR="$HOME/.vscode-server"
REMOTE_DIR="$HOME/.vscode-remote-containers"
SNAP_DIR="/workspace/snapshots"
SNAP_FILE="$SNAP_DIR/vscode-server-cache.tar.zst"

echo "🛑 Stopping VS Code Tunnel to prevent database corruption..."
# Kill the process to ensure SQLite databases are closed safely
pkill -f "code tunnel" || true
sleep 2 

# Collect directories that actually exist to avoid tar errors
DIRS_TO_BACKUP=""

if [ -d "$SERVER_DIR" ]; then
    DIRS_TO_BACKUP=".vscode-server "
fi

if [ -d "$REMOTE_DIR" ]; then
    DIRS_TO_BACKUP+=".vscode-remote-containers "
fi

if [ -z "$DIRS_TO_BACKUP" ]; then
    echo "❌ Error: Neither VS Code directory exists in $HOME. Nothing to save."
    exit 1
fi

if ! command -v zstd &> /dev/null; then
    echo "🔧 zstd not found. Installing..."
    sudo apt-get update && sudo apt-get install -y zstd
fi

mkdir -p "$SNAP_DIR"

echo "🚀 Snapshotting VS Code Server caches..."
echo "📂 Sources found: $DIRS_TO_BACKUP"
echo "💾 Destination: $SNAP_FILE"

# -C "$HOME" so it extracts cleanly back into the home directory later
# We pass $DIRS_TO_BACKUP without quotes so tar treats them as separate arguments
tar --use-compress-program="zstd -T0" -cf "$SNAP_FILE" -C "$HOME" $DIRS_TO_BACKUP

echo "✅ VS Code cache snapshot saved."
echo "Restarting VS Code Server..."
MNT_DIR="/workspace"
SCRIPTS_DIR="${MNT_DIR}/runpod_startup_scripts"
source "${SCRIPTS_DIR}/start_code_server.sh"

# #!/bin/bash
# set -e

# SOURCE_DIR="$HOME/.vscode-server"
# SNAP_DIR="/workspace/snapshots"
# SNAP_FILE="$SNAP_DIR/vscode-server.tar.zst"

# echo "🛑 Stopping VS Code Tunnel to prevent database corruption..."
# # Kill the process to ensure SQLite databases are closed safely
# pkill -f "code tunnel" || true
# sleep 2 

# if [ ! -d "$SOURCE_DIR" ]; then
#     echo "❌ Error: Directory '$SOURCE_DIR' does not exist. Nothing to save."
#     exit 1
# fi

# if ! command -v zstd &> /dev/null; then
#     echo "🔧 zstd not found. Installing..."
#     sudo apt-get update && sudo apt-get install -y zstd
# fi

# mkdir -p "$SNAP_DIR"

# echo "🚀 Snapshotting VS Code Server cache..."
# echo "📂 Source: $SOURCE_DIR"
# echo "💾 Destination: $SNAP_FILE"

# # -C "$HOME" so it extracts cleanly back into the home directory later
# tar --use-compress-program="zstd -T0" -cf "$SNAP_FILE" -C "$HOME" ".vscode-server"

# echo "✅ VS Code Server snapshot saved."
# echo "Restarting VS Code Server"
# MNT_DIR="/workspace"
# SCRIPTS_DIR="${MNT_DIR}/runpod_startup_scripts"
# source "${SCRIPTS_DIR}/start_code_server.sh"
