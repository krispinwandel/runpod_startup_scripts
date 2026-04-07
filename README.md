# Runpod Startup Scripts

A collection of startup scripts to set up development environments on Runpod. Specifically, it installs vscode cli and starts a VSCode server, installs uv, exports environment variables, and clones a Git repository. It also contains scripts to save snapshots of your project dir and VSCode server data.

## First-Time Startup: Creating a VSCode Server Token

1. Deploy a runpod and mount a network volume at `/workspace` (default mount dir).
2. Choose a unique tunnel name for this machine (for example `cloud-dev-a100-1`).
3. Open the web terminal and run the following commands to generate a VSCode server token:

```bash
cd /workspace
git clone https://github.com/krispinwandel/runpod_startup_scripts.git
cd runpod_startup_scripts
# install code cli
source install_code_cli.sh
# required: unique tunnel name per machine
export TUNNEL_NAME=cloud-dev-a100-1
# optional explicit shared token store (already set by install_code_cli.sh)
export VSCODE_CLI_DATA_DIR="/workspace/.cache/code_cli"
# generate vscode server token
code tunnel user login
```
4. Terminate the pod.


## Configure Runpod Template

1. In your runpod template, use this start command: 
```bash
bash -c 'cd /workspace && if [ -d runpod_startup_scripts ]; then git -C runpod_startup_scripts pull; else git clone https://github.com/krispinwandel/runpod_startup_scripts.git; fi && bash /workspace/runpod_startup_scripts/setup_dev_env_snap.sh "$GIT_HTTPS_URL"'
```
2. Add `GIT_HTTPS_URL` and all environment variables as listed in `setup_dev_env_snap.sh` to your template. You can remove any env vars that are not needed for your use case.

Optional AWS variables supported by startup scripts:

- `AWS_USER_KEY`
- `AWS_SECRET_KEY`
- `AWS_LOCATION` (default: `us-ca-2`)
- `AWS_FORMAT` (default: `json`)

## Connect to VSCode Server

The scripts require `TUNNEL_NAME` and will fail fast if it is not set. Set a unique tunnel name per machine in your Runpod template environment variables (for example `cloud-dev-a100-1`, `cloud-dev-a100-2`).

Tunnel auth/runtime state is stored in:

```bash
/workspace/.cache/code_cli/tunnels/<TUNNEL_NAME>
```

This allows multiple machines to use the same VS Code account token while avoiding state collisions between machines. The shared canonical token is:

```bash
/workspace/.cache/code_cli/token.json
```

Backward compatibility is built in: startup uses the shared token store at:

```bash
/workspace/.cache/code_cli/token.json
```

Startup syncs `token.json` between the shared root and each tunnel folder. It does not copy tunnel metadata, logs, locks, or server binaries. This lets older single-directory setups migrate without redoing login for every new tunnel name.

Install the *Visual Studio Code Remote Development Extension Pack* and follow the instructions [here](https://code.visualstudio.com/docs/remote/tunnels#_remote-tunnels-extension) to connect to your VSCode server. Make sure to sign in to the same account used in the token login step.

## Multi-Machine Notes

- Use a distinct `TUNNEL_NAME` for every machine.
- Reuse the same `TUNNEL_NAME` on restart if you want stable tunnel identity.
- Do not run two machines with the same `TUNNEL_NAME` at the same time.
- Check tunnel logs in `/workspace/.cache/code_cli/tunnels/<TUNNEL_NAME>/tunnel.log`.
- If your old token was stored directly in `/workspace/.cache/code_cli`, new tunnel folders can inherit it automatically on first start.


## Save Snapshots

Simply run the following command in your project directory:
```bash
source /workspace/runpod_startup_scripts/save_snaps.sh .
```




