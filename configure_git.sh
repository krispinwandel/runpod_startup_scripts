#!/bin/bash

# 1. Validation: Ensure variables are set
if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: One or more environment variables (GIT_NAME, GIT_EMAIL, GITHUB_TOKEN) are missing."
    exit 1
fi

echo "Configuring Git for: $GIT_NAME <$GIT_EMAIL>..."

# 2. Set Global Identity
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global pull.rebase false

# 3. Configure Authentication using GITHUB_TOKEN
# This tells Git to intercept any HTTPS request to github.com and 
# inject the token into the URL automatically.
git config --global url."https://x-access-token:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# 4. Verification
echo "--- Current Global Git Config ---"
git config --global --list

echo -e "\nSuccess: Git is now configured to use your environment variables."