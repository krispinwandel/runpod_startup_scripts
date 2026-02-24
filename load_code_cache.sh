CODE_SNAP_FILE="/workspace/snapshots/vscode-server-cache.tar.zst"

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
