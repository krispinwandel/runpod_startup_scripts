#!/bin/bash

set -e

AWS_LOCATION="${AWS_LOCATION:-us-ca-2}"
AWS_FORMAT="${AWS_FORMAT:-json}"

if ! command -v aws >/dev/null 2>&1; then
    echo "Installing AWS CLI..."
    if ! command -v unzip >/dev/null 2>&1; then
        apt-get update && apt-get install -y unzip
    fi

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf awscliv2.zip aws
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
