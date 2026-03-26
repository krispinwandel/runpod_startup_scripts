#!/bin/bash

set -eo pipefail

if [ "$#" -lt 2 ]; then
    echo "Usage: ./run_job.sh <git-repo-url> <job command>"
    echo "Example: ./run_job.sh https://github.com/org/repo.git python train.py --epochs 3"
    exit 1
fi

GIT_URL="$1"
shift
JOB_CMD="$*"

SCRIPTS_DIR="/workspace/runpod_startup_scripts"
source "${SCRIPTS_DIR}/setup_env_common.sh"

# Reuse the shared setup but skip starting the code server tunnel
setup_dev_environment "$GIT_URL" "false"

BASENAME=$(basename "$GIT_URL")
PROJECT_NAME="${BASENAME%.git}"
PROJECT_DIR="/root/${PROJECT_NAME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Project directory $PROJECT_DIR not found after setup."
    exit 1
fi

cd "$PROJECT_DIR"

if [ ! -d ".venv" ]; then
    echo "Creating uv virtual environment..."
    uv venv
fi

# shellcheck disable=SC1091
source ".venv/bin/activate"

echo "Running job command: $JOB_CMD"
set +e
eval "$JOB_CMD"
JOB_STATUS=$?
set -e

if [ $JOB_STATUS -eq 0 ]; then
    echo "✅ Job finished successfully."
else
    echo "❌ Job failed with status $JOB_STATUS."
fi

echo "Requesting pod shutdown..."

if command -v runpodctl >/dev/null 2>&1 && [ -n "${RUNPOD_POD_ID:-}" ]; then
    echo "Removing pod via runpodctl..."
    set +e
    runpodctl remove pod "$RUNPOD_POD_ID"
    RPCTL_STATUS=$?
    set -e
    if [ $RPCTL_STATUS -eq 0 ]; then
        exit $JOB_STATUS
    fi
    echo "runpodctl remove failed; falling back to shutdown methods."
fi

if command -v poweroff >/dev/null 2>&1; then
    poweroff
elif command -v shutdown >/dev/null 2>&1; then
    shutdown -h now
else
    echo "No shutdown command available; exiting process."
fi

exit $JOB_STATUS
