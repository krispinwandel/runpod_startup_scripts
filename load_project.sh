#!/bin/bash

# 1. Get the Git URL from input arg
GIT_URL="${1}"

if [ -z "$GIT_URL" ]; then
    echo "❌ Error: Please provide a Git URL."
    echo "Usage: ./load_snap.sh <git-repo-url>"
    exit 1
fi

# 2. Extract project name from Git URL
# Extracts "my_project.git" from the URL, then strips the ".git" extension
BASENAME=$(basename "$GIT_URL")
PROJECT_NAME="${BASENAME%.git}"

# Configuration
SNAP_DIR="/workspace/snapshots"
SNAP_FILE="$SNAP_DIR/${PROJECT_NAME}.tar.zst"
DEST_DIR="/root"

# 3. Safety Checks
# Ensure zstd is installed for decompression
if ! command -v zstd &> /dev/null; then
    echo "🔧 zstd not found. Installing..."
    apt-get update && apt-get install -y zstd
fi

# Ensure git is installed
if ! command -v git &> /dev/null; then
    echo "🔧 git not found. Installing..."
    apt-get update && apt-get install -y git
fi

echo "🚀 Loading project: $PROJECT_NAME"

# 4. Load Snapshot and Update OR Clone from scratch
if [ -f "$SNAP_FILE" ]; then
    echo "📦 Found snapshot: $SNAP_FILE"
    echo "📂 Extracting to $DEST_DIR/$PROJECT_NAME..."

    # Extract the archive. Since save_snap.sh packed the folder itself,
    # extracting in '.' will perfectly recreate the 'my_project' directory.
    tar --use-compress-program="zstd -d" -xf "$SNAP_FILE" -C "$DEST_DIR"

    echo "🔄 Pulling latest changes from Git..."
    cd "$DEST_DIR/$PROJECT_NAME" || exit 1

    # Ensure it's actually a git repository before attempting to pull
    if [ -d ".git" ]; then
        # Stash any potential local changes from the snapshot just in case, 
        # to ensure the pull doesn't fail due to merge conflicts.
        # git stash &> /dev/null
        git pull
        echo "✅ Snapshot loaded and synced with latest Git changes."
    else
        echo "⚠️ Warning: Snapshot extracted, but it is not a Git repository. Cannot run 'git pull'."
    fi
else
    echo "⚠️ No snapshot found for $PROJECT_NAME at $SNAP_FILE."
    echo "📥 Cloning directly from Git instead..."
    
    cd "$DEST_DIR" || exit 1
    git clone "$GIT_URL"
    
    echo "✅ Repository cloned from scratch."
fi