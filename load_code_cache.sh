SNAP_DIR="/workspace/snapshots"
RAW_TUNNEL_NAME="${TUNNEL_NAME:-default}"
SAFE_TUNNEL_NAME="$(echo "$RAW_TUNNEL_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g')"
CODE_SNAP_FILE="$SNAP_DIR/vscode-server-cache-$SAFE_TUNNEL_NAME.tar.zst"

echo "Using tunnel snapshot key: $SAFE_TUNNEL_NAME"

echo "🔍 Checking for VS Code Server snapshots..."
if [ -f "$CODE_SNAP_FILE" ]; then
    echo "📦 Found snapshot. Extracting to fast local NVMe..."
    
    if ! command -v zstd &> /dev/null; then
        echo "🔧 zstd not found. Installing..."
        sudo apt-get update && sudo apt-get install -y zstd
    fi
    
    # Extract directly into the home directory
    tar --use-compress-program="zstd -T0" -xf "$CODE_SNAP_FILE" -C "$HOME"
    echo "✅ Extraction complete. Caches restored."
else
    echo "ℹ️ No snapshot found at $CODE_SNAP_FILE. Starting fresh."
fi
