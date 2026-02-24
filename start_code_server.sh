# Configuration
TUNNEL_NAME="cloud-dev-machine"
DATA_DIR="/workspace/.cache/code_cli"
BIN_DIR="$HOME/.local/bin"
CODE_BIN="$BIN_DIR/code"
SNAP_FILE="/workspace/snapshots/vscode-server-cache.tar.zst"

echo "🔍 Checking for VS Code Server snapshots..."
if [ -f "$SNAP_FILE" ]; then
    echo "📦 Found snapshot. Extracting to fast local NVMe..."
    
    if ! command -v zstd &> /dev/null; then
        echo "🔧 zstd not found. Installing..."
        sudo apt-get update && sudo apt-get install -y zstd
    fi
    
    # Extract directly into the home directory
    tar --use-compress-program="zstd -T0" -xf "$SNAP_FILE" -C "$HOME"
    echo "✅ Extraction complete. Caches restored."
else
    echo "ℹ️ No snapshot found at $SNAP_FILE. Starting fresh."
fi

echo "Preparing VS Code environment..."
mkdir -p "$DATA_DIR"

# 1. Download the standalone CLI if it isn't already installed
if [ ! -f "$CODE_BIN" ]; then
    echo "Downloading standalone VS Code CLI (Alpine build)..."
    curl -sLk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output /tmp/vscode_cli.tar.gz
    mkdir -p "$BIN_DIR"
    tar -xf /tmp/vscode_cli.tar.gz -C "$BIN_DIR"
    rm /tmp/vscode_cli.tar.gz
fi

# 2. Export environment variables for the zero-touch auth and persistent data directory
export VSCODE_CLI_USE_FILE_KEYCHAIN=1
export VSCODE_CLI_DISABLE_KEYCHAIN_ENCRYPT=1
export VSCODE_CLI_DATA_DIR="$DATA_DIR"

# 3. Start the tunnel in the background
# The --install-extension flags execute silently if the extensions are already cached
echo "Starting VS Code Tunnel..."
nohup $CODE_BIN tunnel \
    --accept-server-license-terms \
    --name $TUNNEL_NAME \
    --install-extension ms-python.python \
    --install-extension ms-toolsai.jupyter \
    --install-extension ms-python.black-formatter \
    > "$DATA_DIR/tunnel.log" 2>&1 &

echo "======================================================"
echo "Tunnel started efficiently in the background!"
echo "Server Binaries (Persistent): $DATA_DIR"
echo "I/O Caches (Fast NVMe):       ~/.vscode-server & ~/.vscode-remote-containers"
echo "To view the live output, run: tail -f $DATA_DIR/tunnel.log"
echo "======================================================"
# # Configuration
# TUNNEL_NAME="cloud-dev-machine"
# DATA_DIR="/workspace/.cache/code_cli"
# BIN_DIR="$HOME/.local/bin"
# CODE_BIN="$BIN_DIR/code"
# SNAP_FILE="/workspace/snapshots/vscode-server.tar.zst"

# echo "🔍 Checking for VS Code Server snapshot..."
# if [ -f "$SNAP_FILE" ]; then
#     echo "📦 Found snapshot. Extracting to fast local NVMe..."
    
#     if ! command -v zstd &> /dev/null; then
#         echo "🔧 zstd not found. Installing..."
#         sudo apt-get update && sudo apt-get install -y zstd
#     fi
    
#     # Extract directly into the home directory
#     tar --use-compress-program="zstd -T0" -xf "$SNAP_FILE" -C "$HOME"
#     echo "✅ Extraction complete. Cache restored."
# else
#     echo "ℹ️ No snapshot found at $SNAP_FILE. Starting fresh."
# fi

# echo "Preparing VS Code environment..."
# mkdir -p "$DATA_DIR"

# # 1. Download the standalone CLI if it isn't already installed
# if [ ! -f "$CODE_BIN" ]; then
#     echo "Downloading standalone VS Code CLI (Alpine build)..."
#     curl -sLk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output /tmp/vscode_cli.tar.gz
#     mkdir -p "$BIN_DIR"
#     tar -xf /tmp/vscode_cli.tar.gz -C "$BIN_DIR"
#     rm /tmp/vscode_cli.tar.gz
# fi

# # 2. Export environment variables for the zero-touch auth and persistent data directory
# export VSCODE_CLI_USE_FILE_KEYCHAIN=1
# export VSCODE_CLI_DISABLE_KEYCHAIN_ENCRYPT=1
# export VSCODE_CLI_DATA_DIR="$DATA_DIR"

# # 3. Start the tunnel in the background
# # The --install-extension flags execute silently if the extensions are already cached
# echo "Starting VS Code Tunnel..."
# nohup $CODE_BIN tunnel \
#     --accept-server-license-terms \
#     --name $TUNNEL_NAME \
#     --install-extension ms-python.python \
#     --install-extension ms-toolsai.jupyter \
#     --install-extension ms-python.black-formatter \
#     > "$DATA_DIR/tunnel.log" 2>&1 &

# echo "======================================================"
# echo "Tunnel started efficiently in the background!"
# echo "Server Binaries (Persistent): $DATA_DIR"
# echo "I/O Cache (Fast NVMe):        ~/.vscode-server/data"
# echo "To view the live output, run: tail -f $DATA_DIR/tunnel.log"
# echo "======================================================"