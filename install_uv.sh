#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Starting uv installation for RunPod ---"

# 1. Download and run the astral-sh installation script
# -sSf: Silent, show errors, fail on server errors
# We pipe to sh to execute the installer
curl -lsSf https://astral.sh/uv/install.sh | sh

# 2. Configure the shell environment
# In RunPod, HOME=/root. The installer usually places the binary in $HOME/.local/bin
# We ensure this is added to the PATH in the current session and .bashrc
UV_BIN_DIR="$HOME/.local/bin"

if [[ ":$PATH:" != *":$UV_BIN_DIR:"* ]]; then
    echo "Adding $UV_BIN_DIR to PATH..."
    echo "export PATH=\"\$PATH:$UV_BIN_DIR\"" >> "$HOME/.bashrc"
    export PATH="$PATH:$UV_BIN_DIR"
fi

# 3. Verify installation
echo "--- Verifying uv installation ---"
uv --version

echo "uv has been installed successfully!"