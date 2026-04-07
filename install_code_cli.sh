# Configuration
BIN_DIR="$HOME/.local/bin"
CODE_BIN="$BIN_DIR/code"
CODE_CLI_ROOT_DIR="/workspace/.cache/code_cli"
TUNNELS_DIR="$CODE_CLI_ROOT_DIR/tunnels"

echo "Preparing VS Code environment..."
mkdir -p "$CODE_CLI_ROOT_DIR"
mkdir -p "$TUNNELS_DIR"

# 1. Download the standalone CLI if it isn't already installed
if [ ! -f "$CODE_BIN" ]; then
    echo "Downloading standalone VS Code CLI (Alpine build)..."
    curl -sLk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output /tmp/vscode_cli.tar.gz
    mkdir -p "$BIN_DIR"
    tar -xf /tmp/vscode_cli.tar.gz -C "$BIN_DIR"
    rm /tmp/vscode_cli.tar.gz
fi

# 2. Export environment variables for the zero-touch auth mode.
# Use shared root by default so `code tunnel user login` stores token.json in one reusable location.
# start_code_server.sh overrides VSCODE_CLI_DATA_DIR to tunnel-specific runtime directories.
export VSCODE_CLI_USE_FILE_KEYCHAIN=1
export VSCODE_CLI_DISABLE_KEYCHAIN_ENCRYPT=1
export VSCODE_CLI_DATA_DIR="$CODE_CLI_ROOT_DIR"
export PATH="$BIN_DIR:$PATH"

echo "VS Code CLI installed at: $CODE_BIN"
echo "Shared cache root: $CODE_CLI_ROOT_DIR"
echo "Per-tunnel state root: $TUNNELS_DIR"

