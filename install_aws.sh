#!/bin/bash

set -e

AWS_LOCATION="${AWS_LOCATION:-us-ca-2}"
AWS_FORMAT="${AWS_FORMAT:-json}"
AWS_CACHE_DIR="${AWS_CACHE_DIR:-${HOME}/.cache/aws}"

# Add cached AWS bin to PATH if it exists
if [ -f "${AWS_CACHE_DIR}/bin/aws" ]; then
    export PATH="${AWS_CACHE_DIR}/bin:${PATH}"
    echo "Using cached AWS CLI from ${AWS_CACHE_DIR}/bin"
elif ! command -v aws >/dev/null 2>&1; then
    echo "Installing AWS CLI to ${AWS_CACHE_DIR}..."
    mkdir -p "${AWS_CACHE_DIR}"
    
    if ! command -v unzip >/dev/null 2>&1; then
        apt-get update && apt-get install -y unzip
    fi

    # Download and install to cache directory
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install --install-dir "${AWS_CACHE_DIR}" --bin-dir "${AWS_CACHE_DIR}/bin"
    rm -rf /tmp/awscliv2.zip /tmp/aws
    
    # Add to PATH
    export PATH="${AWS_CACHE_DIR}/bin:${PATH}"
    echo "AWS CLI installed to ${AWS_CACHE_DIR}"
fi

mkdir -p "$HOME/.aws"

if [ -n "${AWS_USER_KEY:-}" ] && [ -n "${AWS_SECRET_KEY:-}" ]; then
    echo "Configuring AWS credentials from environment variables..."
    aws configure set aws_access_key_id "$AWS_USER_KEY"
    aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
    aws configure set default.region "$AWS_LOCATION"
    aws configure set default.output "$AWS_FORMAT"
    echo "AWS CLI configured for region '$AWS_LOCATION' with output '$AWS_FORMAT'."
else
    echo "AWS_USER_KEY or AWS_SECRET_KEY not set."
    echo "AWS CLI installed, but credentials were not configured."
    echo "Set AWS_USER_KEY and AWS_SECRET_KEY to enable automatic configuration."
fi
