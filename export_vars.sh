#!/bin/bash

# Path to the bashrc file
BASHRC_FILE="$HOME/.bashrc"

# Check if arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 VAR_NAME1 VAR_NAME2 ..."
    exit 1
fi

echo "Updating $BASHRC_FILE..."

# Iterate through all arguments passed to the script
for VAR in "$@"; do
    # Check if the variable is already exported in .bashrc
    if grep -q "^export $VAR=" "$BASHRC_FILE"; then
        echo "[-] $VAR is already present in $BASHRC_FILE, skipping."
    else
        # Append the export statement with the actual value using indirect expansion
        echo "export $VAR=\"${!VAR}\"" >> "$BASHRC_FILE"
        echo "[+] Added $VAR to $BASHRC_FILE."
    fi
done

echo "-------------------------------------------------------"
echo "Done! Please run 'source ~/.bashrc' to apply changes."