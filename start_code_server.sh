# Configuration
BIN_DIR="$HOME/.local/bin"
CODE_BIN="$BIN_DIR/code"
CODE_CLI_ROOT_DIR="/workspace/.cache/code_cli"
TUNNELS_DIR="$CODE_CLI_ROOT_DIR/tunnels"

if [ -z "${TUNNEL_NAME:-}" ]; then
    echo "ERROR: TUNNEL_NAME is required for multi-machine usage."
    echo "Set a unique name per machine, for example:"
    echo "  export TUNNEL_NAME=cloud-dev-a100-1"
    return 1
fi

SAFE_TUNNEL_NAME="$(echo "$TUNNEL_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g')"
if [ -z "$SAFE_TUNNEL_NAME" ]; then
    echo "ERROR: Invalid TUNNEL_NAME after normalization: $TUNNEL_NAME"
    return 1
fi

DATA_DIR="$TUNNELS_DIR/$SAFE_TUNNEL_NAME"
LOG_FILE="$DATA_DIR/tunnel.log"
SHARED_TOKEN_FILE="$CODE_CLI_ROOT_DIR/token.json"
TUNNEL_TOKEN_FILE="$DATA_DIR/token.json"

mkdir -p "$CODE_CLI_ROOT_DIR"
mkdir -p "$TUNNELS_DIR"
mkdir -p "$DATA_DIR"

sync_shared_token() {
    if [ -f "$TUNNEL_TOKEN_FILE" ] && { [ ! -f "$SHARED_TOKEN_FILE" ] || [ "$TUNNEL_TOKEN_FILE" -nt "$SHARED_TOKEN_FILE" ]; }; then
        cp -a "$TUNNEL_TOKEN_FILE" "$SHARED_TOKEN_FILE"
        echo "Updated shared token store: $SHARED_TOKEN_FILE"
    fi

    if [ -f "$SHARED_TOKEN_FILE" ] && [ ! -f "$TUNNEL_TOKEN_FILE" ]; then
        cp -a "$SHARED_TOKEN_FILE" "$TUNNEL_TOKEN_FILE"
        echo "Bootstrapped tunnel auth token from shared store."
    fi
}

sync_shared_token

echo "Using tunnel: $TUNNEL_NAME"
echo "Tunnel data dir: $DATA_DIR"
echo "Shared token file: $SHARED_TOKEN_FILE"

# Export again in case this script is run independently.
# Use a per-tunnel keychain dir so multiple machines can share one account token safely.
export VSCODE_CLI_USE_FILE_KEYCHAIN=1
export VSCODE_CLI_DISABLE_KEYCHAIN_ENCRYPT=1
export VSCODE_CLI_DATA_DIR="$DATA_DIR"

if ! [ -x "$CODE_BIN" ]; then
    echo "ERROR: VS Code CLI not found at $CODE_BIN"
    echo "Run: source install_code_cli.sh"
    return 1
fi

# Start the tunnel in the background.
# The --install-extension flags execute silently if the extensions are already cached.
echo "Starting VS Code Tunnel..."
nohup "$CODE_BIN" tunnel \
    --accept-server-license-terms \
    --name "$TUNNEL_NAME" \
    --install-extension ms-python.python \
    --install-extension ms-toolsai.jupyter \
    --install-extension ms-python.black-formatter \
    > "$LOG_FILE" 2>&1 &

echo "======================================================"
echo "Tunnel started efficiently in the background!"
echo "Shared CLI Cache Root:         $CODE_CLI_ROOT_DIR"
echo "Tunnel State (per machine):    $DATA_DIR"
echo "I/O Caches (Fast NVMe):        ~/.vscode-server & ~/.vscode-remote-containers"
echo "To view the live output, run:  tail -f $LOG_FILE"
echo "======================================================"