MNT_DIR="/workspace"
SCRIPTS_DIR="${MNT_DIR}/runpod_startup_scripts"

INPUT_PATH="${1:-.}"

source "${SCRIPTS_DIR}/save_project_snap.sh" $INPUT_PATH
mkdir -p "${SCRIPTS_DIR}/logs"
nohup bash "${SCRIPTS_DIR}/save_vscode_snap.sh" > "${SCRIPTS_DIR}/logs/vscode_snapshot.log" 2>&1 &