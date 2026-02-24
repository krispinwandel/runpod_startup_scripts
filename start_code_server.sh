# Configuration
TUNNEL_NAME="cloud-dev-machine"
DATA_DIR="/workspace/.cache/code_cli"
BIN_DIR="$HOME/.local/bin"
CODE_BIN="$BIN_DIR/code"

# Start the tunnel in the background
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