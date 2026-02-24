# Runpod Startup Scripts

A collection of startup scripts to set up development environments on Runpod. Specifically, it installs vscode cli and starts a VSCode server, installs uv, exports environment variables, and clones a Git repository. It also contains scripts to save snapshots of your project dir and VSCode server data.

## First-Time Startup: Creating a VSCode Server Token

1. Deploy a runpod and mount a network volume at `/workspace` (default mount dir).
2. Open the web terminal and the following commands to generate a VSCode server token and save it:

```bash
cd /workspace
git clone https://github.com/krispinwandel/runpod_startup_scripts.git
cd runpod_startup_scripts
# install code cli
source install_code_cli.sh
# generate vscode server token
code tunnel user login
```
3. Terminate the pod.


## Configure Runpod Template

1. In your runpod template, use this start command: 
```bash
bash -c 'cd /workspace && if [ -d runpod_startup_scripts ]; then git -C runpod_startup_scripts pull; else git clone https://github.com/krispinwandel/runpod_startup_scripts.git; fi && bash /workspace/runpod_startup_scripts/setup_dev_env_snap.sh "$GIT_HTTPS_URL"'
```
2. Add `GIT_HTTPS_URL` and all environment variables as listed in `setup_dev_env_snap.sh` to your template. You can remove any env vars that are not needed for your use case.

## Connect to VSCode Server

The scripts will spawn a VSCode tunnel named **cloud-dev-machine**. You can adjust this name in `start_code_server.sh` if you want. Install the *Visual Studio Code Remote Development Extension Pack* and follow the instructions [here](https://code.visualstudio.com/docs/remote/tunnels#_remote-tunnels-extension) to connect to your VSCode server using the token you generated in the first step.


## Save Snapshots

Simply run the following command in your project directory:
```bash
source /workspace/runpod_startup_scripts/save_snaps.sh .
```




