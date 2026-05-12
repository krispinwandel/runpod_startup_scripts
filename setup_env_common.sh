#!/bin/bash

set -eo pipefail

# Shared environment setup for dev pods. Pass git URL and optional flag to start code server.
setup_dev_environment() {
    local git_url="${1:-}"
    local start_code_server="${2:-true}"

    if [ -z "$git_url" ]; then
        echo "❌ Error: Please provide a Git URL."
        echo "Usage: setup_dev_environment <git-repo-url> [start-code-server=true|false]"
        return 1
    fi

    local MNT_DIR="/workspace"
    local CACHE_DIR="${MNT_DIR}/.cache"
    local SCRIPTS_DIR="${MNT_DIR}/runpod_startup_scripts"
    local EXPORT_VAR_NAMES=(
        "UV_CACHE_DIR"
        "HF_HOME"
        "HF_TOKEN"
        "WANDB_API_KEY"
        "AWS_USER_KEY"
        "AWS_SECRET_KEY"
        "AWS_LOCATION"
        "AWS_FORMAT"
        "AWS_CACHE_DIR"
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
    export AWS_CACHE_DIR="${CACHE_DIR}/aws"
    export TRITON_CACHE_DIR="${CACHE_DIR}/triton"
    export TORCHINDUCTOR_FX_GRAPH_CACHE=1
    export TORCHINDUCTOR_AUTOGRAD_CACHE=1
    export TORCHINDUCTOR_CACHE_DIR="${CACHE_DIR}/torchinductor"

    # Create the hidden cache directories on your persistent volume
    mkdir -p "${UV_CACHE_DIR}"
    mkdir -p "${HF_HOME}"
    mkdir -p "${AWS_CACHE_DIR}"
    mkdir -p "${TRITON_CACHE_DIR}"
    mkdir -p "${TORCHINDUCTOR_CACHE_DIR}"

    source "${SCRIPTS_DIR}/runpod_start.sh"
    source "${SCRIPTS_DIR}/load_code_cache.sh"
    source "${SCRIPTS_DIR}/install_code_cli.sh"
    if [ "${start_code_server}" = "true" ]; then
        source "${SCRIPTS_DIR}/start_code_server.sh"
    fi
    source "${SCRIPTS_DIR}/install_uv.sh"
    source "${SCRIPTS_DIR}/install_zstd.sh"
    source "${SCRIPTS_DIR}/install_aws.sh"
    source "${SCRIPTS_DIR}/configure_git.sh"
    source "${SCRIPTS_DIR}/load_project.sh" "$git_url"
    source "${SCRIPTS_DIR}/export_vars.sh" "${EXPORT_VAR_NAMES[@]}"
}
