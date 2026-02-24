GIT_URL="${1}"

if [ -z "$GIT_URL" ]; then
    echo "❌ Error: Please provide a Git URL."
    echo "Usage: ./setup_dev_env.sh <git-repo-url>"
    exit 1
fi

MNT_DIR="/workspace"
CACHE_DIR="${MNT_DIR}/.cache"
SCRIPTS_DIR="${MNT_DIR}/runpod_startup_scripts"
EXPORT_VAR_NAMES=(
    "UV_CACHE_DIR"
    "HF_HOME"
    "HF_TOKEN"
    "WANDB_API_KEY"
    "PUBLIC_KEY"
    "JUPYTER_PASSWORD"
    "GITHUB_TOKEN"
    "RUNPOD_API_KEY"
    "TRITON_CACHE_DIR"
    "TORCHINDUCTOR_CACHE_DIR"
    "TORCHINDUCTOR_FX_GRAPH_CACHE"
    "TORCHINDUCTOR_AUTOGRAD_CACHE"
)
# env vars
export UV_CACHE_DIR="${CACHE_DIR}/uv"
export HF_HOME="${CACHE_DIR}/hf"
# Tell Triton and PyTorch where to save and load compiled kernels
export TRITON_CACHE_DIR="${CACHE_DIR}/triton"
export TORCHINDUCTOR_FX_GRAPH_CACHE=1
export TORCHINDUCTOR_AUTOGRAD_CACHE=1
export TORCHINDUCTOR_CACHE_DIR="${CACHE_DIR}/torchinductor"

# Create the hidden cache directories on your persistent volume
mkdir -p "${UV_CACHE_DIR}"
mkdir -p "${HF_HOME}"
mkdir -p "${TRITON_CACHE_DIR}"
mkdir -p "${TORCHINDUCTOR_CACHE_DIR}"

source "${SCRIPTS_DIR}/runpod_start.sh"
source "${SCRIPTS_DIR}/load_code_cache.sh"
source "${SCRIPTS_DIR}/install_code_cli.sh"
source "${SCRIPTS_DIR}/start_code_server.sh"
source "${SCRIPTS_DIR}/install_uv.sh"
source "${SCRIPTS_DIR}/install_zstd.sh"
source "${SCRIPTS_DIR}/configure_git.sh"
source "${SCRIPTS_DIR}/load_project.sh" $GIT_URL
source "${SCRIPTS_DIR}/export_vars.sh" "${EXPORT_VAR_NAMES[@]}"

echo "sleep infinity"
sleep infinity
