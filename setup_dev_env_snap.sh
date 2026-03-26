#!/bin/bash

set -eo pipefail

GIT_URL="${1:-}"
SCRIPTS_DIR="/workspace/runpod_startup_scripts"

source "${SCRIPTS_DIR}/setup_env_common.sh"

setup_dev_environment "$GIT_URL" "true"

echo "sleep infinity"
sleep infinity
