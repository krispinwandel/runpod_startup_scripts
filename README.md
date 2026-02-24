# Runpod Startup Scripts

A collection of startup scripts to set up development environments on Runpod. Specifically, it installs vscode cli and starts a VSCode server, installs uv, exports environment variables, and clones a Git repository. It also contains scripts to save snapshots of your project dir and VSCode server data.

## Configure Runpod Template

1. In your runpod template, use this start command: 
```bash
bash /workspace/runpod_startup_scripts/setup_dev_env_snap.sh <GIT_URL>
```
2. Specify all environment variables as listed in `setup_dev_env_snap.sh`. You can remove any that are not needed for your use case.

## Save Snapshots

Simply run the following command in your project directory:
```bash
source /workspace/runpod_startup_scripts/save_snaps.sh .
```




