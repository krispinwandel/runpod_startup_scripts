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

mkdir -p "$DATA_DIR"

is_dir_empty() {
    [ -z "$(find "$1" -mindepth 1 -print -quit 2>/dev/null)" ]
}

bootstrap_legacy_state() {
    local copied=0
    local legacy_item

    # Backward compatibility: old setups stored auth state directly in CODE_CLI_ROOT_DIR.
    # If this tunnel directory is empty, seed it from legacy root contents.
    if ! is_dir_empty "$DATA_DIR"; then
        return
    fi

    while IFS= read -r legacy_item; do
        cp -a "$legacy_item" "$DATA_DIR/"
        copied=1
    done < <(find "$CODE_CLI_ROOT_DIR" -mindepth 1 -maxdepth 1 ! -name "tunnels" -print 2>/dev/null)

    if [ "$copied" -eq 1 ]; then
        echo "Bootstrapped tunnel state from legacy shared directory: $CODE_CLI_ROOT_DIR"
    fi
}

bootstrap_legacy_state

echo "Using tunnel: $TUNNEL_NAME"
echo "Tunnel data dir: $DATA_DIR"

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