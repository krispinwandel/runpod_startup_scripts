#!/bin/bash

# 1. Get the target directory from input arg (default to "." if empty)
INPUT_PATH="${1:-.}"

# 2. Resolve absolute paths (handles relative paths like . or ..)
# 'realpath' gives us the full path (e.g., /root/my_project)
SOURCE_PATH=$(realpath "$INPUT_PATH")

# 3. Extract folder name and parent directory
# PROJECT_NAME will be "my_project"
PROJECT_NAME=$(basename "$SOURCE_PATH")

# PARENT_DIR will be "/root" (or wherever the project lives)
PARENT_DIR=$(dirname "$SOURCE_PATH")

# Configuration
SNAP_DIR="/workspace/snapshots"
SNAP_FILE="$SNAP_DIR/${PROJECT_NAME}.tar.zst"

# 4. Safety Checks
if [ ! -d "$SOURCE_PATH" ]; then
    echo "❌ Error: Directory '$SOURCE_PATH' does not exist."
    exit 1
fi

# Ensure zstd is installed
if ! command -v zstd &> /dev/null; then
    echo "🔧 zstd not found. Installing..."
    apt-get update && apt-get install -y zstd
fi

mkdir -p "$SNAP_DIR"
echo "🚀 Snapshotting project: $PROJECT_NAME"
echo "📂 Source: $SOURCE_PATH"
echo "💾 Destination: $SNAP_FILE"

# 5. Create Archive
# We -C to the PARENT_DIR so the tarball contains the folder "my_project/"
# rather than just the files inside it. This is crucial for clean extraction.

tar --use-compress-program="zstd -T0" -cf "$SNAP_FILE" -C "$PARENT_DIR" "$PROJECT_NAME"

echo "✅ Snapshot saved."