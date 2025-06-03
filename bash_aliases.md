# My Custom Bash Environment Setup

This document outlines the setup for custom aliases and functions used to enhance the Bash shell experience. All custom commands are stored in `~/.bash_aliases` for better organization and easier management.

## Purpose

The primary goal of this setup is to:
* Streamline common command-line tasks using shorter, memorable aliases.
* Implement more complex custom commands using Bash functions.
* Significantly enhance safety by replacing the standard `rm` command with a version that moves files to a trash directory.
* Keep the main `~/.bashrc` file clean by centralizing personal customizations in `~/.bash_aliases`.

## File Structure

The setup involves two main files:

1.  **`~/.bashrc`**:
    * The standard Bash run control script that executes when an interactive non-login shell starts.
    * It is configured to source (load) the `~/.bash_aliases` file.

2.  **`~/.bash_aliases`**:
    * This file contains all user-defined aliases and functions.
    * **Note**: Although named `.bash_aliases`, this file is used to store **both** aliases and functions for this setup.

## How It Works

The `~/.bashrc` file contains a snippet that checks for the existence of `~/.bash_aliases`. If the file exists, `~/.bashrc` will "source" it. This means it reads and executes the commands within `~/.bash_aliases` in the current shell session, making all the defined aliases and functions available for use.

The relevant lines in `~/.bashrc` are:

```bash
# Source custom commands, if the file exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases  # You can also use 'source ~/.bash_aliases'
fi
````

## 🌟 Important: Safe `rm` (Move to Trash) 🌟

The standard `rm` command has been **overridden** by a safer version (`safe_rm_to_trash`). Instead of permanently deleting files and directories, this new `rm` command moves them to a trash directory located at `~/.Trash`.

  * **Behavior**:
      * `rm file.txt` will move `file.txt` to `~/.Trash/file.txt.<timestamp>`.
      * `rm -r my_directory` will move `my_directory` to `~/.Trash/my_directory.<timestamp>`.
      * It attempts to respect `-f` (force, ignore non-existent files) and `-v` (verbose) flags.
      * The `-i` (interactive) flag is **not supported** by this custom `rm`.
  * **Trash Management**:
      * A new command `emptytrash` (also aliased as `cleartrash`) is available to permanently delete all items from the `~/.Trash` directory after prompting for confirmation.
  * **Safety**: This significantly reduces the risk of accidental permanent data loss.

## Custom Commands in `~/.bash_aliases`

Below is a detailed list of the aliases and functions available:

### General Aliases

| Alias      | Description                                                                 | Original Command (Example)      |
| :--------- | :-------------------------------------------------------------------------- | :------------------------------ |
| `..`       | Go up one directory.                                                        | `cd ..`                         |
| `...`      | Go up two directories.                                                      | `cd ../..`                      |
| `....`     | Go up three directories.                                                    | `cd ../../..`                   |
| `ls`       | List directory contents with colors.                                        | `ls --color=auto`               |
| `ll`       | List all files in long format with type indicators and colors.              | `ls -alF --color=auto`          |
| `la`       | List all files including hidden, with colors.                               | `ls -A --color=auto`            |
| `l`        | List files in columns with type indicators and colors.                      | `ls -CF --color=auto`           |
| `lsg`      | List files (long format) and grep (case-insensitive).                       | `ll \| grep --color=auto -i`    |
| `cp`       | Copy files with prompt before overwrite and verbose output.                 | `cp -iv`                        |
| `mv`       | Move/rename files with prompt before overwrite and verbose output.          | `mv -iv`                        |
| `mkdir`    | Create directory, including parent directories, with verbose output.        | `mkdir -pv`                     |
| `dfh`      | Show disk free space in human-readable format.                              | `df -h`                         |
| `duh`      | Show disk usage of current folder in human-readable format.                 | `du -sh`                        |
| `dufh`     | Show disk usage of items in current directory, sorted by size.              | `du -sh * \| sort -rh`          |
| `freeh`    | Show free memory in human-readable format.                                  | `free -h`                       |
| `psef`     | Grep process list (case-insensitive).                                       | `ps -ef \| grep --color=auto -i`|
| `myip`     | Get your public IP address.                                                 | `curl -s ipinfo.io/ip \|\| curl -s ifconfig.me` |
| `update`   | Update system packages (Debian/Ubuntu example).                             | `sudo apt update && sudo apt upgrade -y` |
| `cls`, `c` | Clear terminal screen.                                                      | `clear`                         |
| `pingg`    | Ping https://www.google.com/url?sa=E\&source=gmail\&q=google.com.                                                            | `ping google.com`               |
| `sln`      | Create a symbolic link (`TARGET LINK_NAME`).                                | `ln -s`                         |
| `slnh`     | Create a symbolic link, treating `LINK_NAME` as a normal file (`TARGET LINK_NAME`). | `ln -s -T`                      |

-----

### GPU Aliases (NVIDIA)

| Alias      | Description                                                                 | Original Command (Example)      |
| :--------- | :-------------------------------------------------------------------------- | :------------------------------ |
| `gpu`      | Show NVIDIA GPU status.                                                     | `nvidia-smi`                    |
| `gpumem`   | Show NVIDIA GPU memory usage (used, total).                                 | `nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits` |
| `gpuwatch` | Monitor NVIDIA GPU status, refreshing every 1 second.                       | `watch -n 1 nvidia-smi`         |

-----

### Git Aliases

*(See also `gac` and `gpush` functions below)*
| Alias      | Description                                                                 | Original Command (Example)      |
| :--------- | :-------------------------------------------------------------------------- | :------------------------------ |
| `gcl`      | Git clone a repository.                                                     | `git clone`                     |
| `ga`       | Git add specific files.                                                     | `git add`                       |
| `gaa`      | Git add all changes in the current directory.                               | `git add .`                     |
| `gad`      | Git add all changes in the repository (tracked and untracked).              | `git add -A`                    |
| `gc`       | Git commit with a message: `gc "My message"`                                | `git commit -m`                 |
| `gca`      | Git add all tracked files and commit: `gca "My message"`                    | `git commit -a -m`              |
| `gco`      | Git checkout a branch or commit.                                            | `git checkout`                  |
| `gcb`      | Git create and checkout a new branch.                                       | `git checkout -b`               |
| `gb`       | Git list branches.                                                          | `git branch`                    |
| `gbd`      | Git delete a branch.                                                        | `git branch -d`                 |
| `gbD`      | Git force delete a branch.                                                  | `git branch -D`                 |
| `gs`       | Git status (short format, with branch info).                                | `git status -sb`                |
| `gst`      | Git status.                                                                 | `git status`                    |
| `gd`       | Git diff (show changes).                                                    | `git diff`                      |
| `gds`      | Git diff (show staged changes).                                             | `git diff --staged`             |
| `gp`       | Git push (simple form, often needs more arguments).                         | `git push`                      |
| `gpo`      | Alias for `gpush` function (pushes current branch to origin by default).    | `gpush` (see Functions)         |
| `gpl`      | Git pull.                                                                   | `git pull`                      |
| `gplr`     | Git pull with rebase.                                                       | `git pull --rebase`             |
| `glg`      | Git log (one line, graph, decorated, all).                                  | `git log --oneline --graph --decorate --all` |
| `glg_`     | Git log (alternative detailed and colored view).                              | `git log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit` |
| `gignore`  | Tell Git to ignore tracking changes to a file: `gignore <file>`             | `git update-index --assume-unchanged` |
| `gunignore`| Tell Git to resume tracking changes to a file: `gunignore <file>`           | `git update-index --no-assume-unchanged` |
| `gundo`    | Undo last commit, keeping changes in working directory.                     | `git reset HEAD~`               |
| `gclean`   | Remove untracked files and directories from Git working tree (CAUTION\!).     | `git clean -fd`                 |
| `ghprc`    | GitHub CLI: create pull request (if `gh` installed).                        | `gh pr create`                  |
| `ghprl`    | GitHub CLI: list pull requests (if `gh` installed).                         | `gh pr list`                    |
| `ghprv`    | GitHub CLI: view pull request (if `gh` installed).                          | `gh pr view`                    |
| `ghrepoweb`| GitHub CLI: open current repository in web browser (if `gh` installed).     | `gh repo view --web`            |

-----

### Python Environment Aliases (Conda & uv)

| Alias      | Description                                                                 | Original Command (Example)      |
| :--------- | :-------------------------------------------------------------------------- | :------------------------------ |
| `ca`       | Conda activate environment: `ca <env_name>`                                 | `conda activate`                |
| `cdx`      | Conda deactivate environment.                                               | `conda deactivate`              |
| `clse`     | Conda list environments.                                                    | `conda env list`                |
| `cenv`     | Conda list environments (alternative).                                      | `conda env list`                |
| `cins`     | Conda install packages: `cins <pkg_name>`                                   | `conda install`                 |
| `cunins`   | Conda uninstall packages: `cunins <pkg_name>`                               | `conda uninstall`               |
| `ccreate`  | Conda create new environment (prefix for `conda create -n`).                | `conda create -n`               |
| `csearch`  | Conda search for packages.                                                  | `conda search`                  |
| `cupc`     | Conda update conda itself.                                                  | `conda update conda`            |
| `cupall`   | Conda update all packages in current environment.                           | `conda update --all`            |
| `crmenv`   | Conda remove an environment: `crmenv <env_name>`                            | `conda env remove -n`           |
| `uvv`      | `uv`: create virtual environment (if `uv` installed): `uvv <env_name>`      | `uv venv`                       |
| `uva`      | `uv`: activate common `.venv` (if `uv` installed and venv exists).          | `source .venv/bin/activate`     |
| `uvi`      | `uv`: install packages (if `uv` installed): `uvi <pkg_name>`                | `uv pip install`                |
| `uvu`      | `uv`: uninstall packages (if `uv` installed): `uvu <pkg_name>`              | `uv pip uninstall`              |
| `uvl`      | `uv`: list installed packages (if `uv` installed).                          | `uv pip list`                   |
| `uvf`      | `uv`: freeze installed packages (like `pip freeze`, if `uv` installed).     | `uv pip freeze`                 |
| `uvsync`   | `uv`: synchronize environment from a requirements file (if `uv` installed). | `uv pip sync`                   |
| `uvtree`   | `uv`: show dependency tree (if `uv` installed).                             | `uv pip tree`                   |
| `uvcompile`| `uv`: compile `requirements.txt` to `requirements.lock` (if `uv` installed).| `uv pip compile`                |

-----

### Tmux Aliases (Terminal Multiplexer)

*(See also `t` function below for comprehensive session management)*

| Alias      | Description                                                              | Original Command (Example)                      |
| :--------- | :----------------------------------------------------------------------- | :---------------------------------------------- |
| `tl`       | List active tmux sessions.                                               | `tmux ls`                                       |
| `ta`, `tat`| Attach to a specific session: `ta <session_name>`                        | `tmux attach-session -t`                        |
| `tn`       | Create a new named session: `tn <session_name>`                          | `tmux new-session -s`                           |
| `td`       | Detach current client (use **INSIDE** tmux).                             | `tmux detach-client`                            |
| `tkill`    | Kill a specific session: `tkill <session_name>`                          | `tmux kill-session -t`                          |
| `tkillsrv` | Kill the tmux server and all attached sessions (CAUTION\!).               | `tmux kill-server`                              |
| `tnw`      | **INSIDE tmux:** New window (opens in current pane's path).              | `tmux new-window -c "#{pane_current_path}"`     |
| `trns`     | **INSIDE tmux:** Rename current session: `trns <new_name>`                 | `tmux rename-session`                           |
| `trnw`     | **INSIDE tmux:** Rename current window: `trnw <new_name>`                  | `tmux rename-window`                            |
| `tsph`     | **INSIDE tmux:** Split pane horizontally (new pane in current path).       | `tmux split-window -h -c "#{pane_current_path}"`|
| `tspv`     | **INSIDE tmux:** Split pane vertically (new pane in current path).         | `tmux split-window -v -c "#{pane_current_path}"`|
| `tsnxt`    | **INSIDE tmux:** Go to next window.                                      | `tmux next-window`                              |
| `tsprev`   | **INSIDE tmux:** Go to previous window.                                  | `tmux previous-window`                          |
| `tslw`     | **INSIDE tmux:** Go to last (previously selected) window.                | `tmux last-window`                              |
| `tkw`      | **INSIDE tmux:** Kill current window.                                    | `tmux kill-window`                              |
| `tkp`      | **INSIDE tmux:** Kill current pane.                                      | `tmux kill-pane`                                |

-----

### General Functions

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `mkcd`          | Create a directory (and any parent directories) and then change into it.      | `mkcd my_new_project`                                |
| `findf`         | Find a file by name (case-insensitive) in current or specified directory.     | `findf report.txt` or `findf image.jpg ./docs`       |
| `grepdir`       | Recursively search for text patterns within files in current/specified dir.   | `grepdir "API_KEY"` or `grepdir "TODO" "*.py"`       |
| `backupfile`    | Create a backup of a file or directory with a timestamp (e.g., `item.timestamp`). | `backupfile important.doc` or `backupfile project_folder` |
| `extract`       | Extract various archive types (tar.gz, zip, rar, etc.).                       | `extract archive.zip` or `extract data.tar.bz2`      |
| `lsbig`         | List N largest files/directories (by size) directly in current dir (default N=10). | `lsbig` or `lsbig 5`                               |
| `lstree`        | Recursively list files/dirs up to N levels (uses `tree` cmd if available).    | `lstree` (depth 2) or `lstree 3 ./src`               |
| `conn`          | Quickly SSH into a host (uses current username if not specified).             | `conn myserver` or `conn user@another.server.com`    |

-----

### Git Functions

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `gac`           | Git: Add all changes (`git add -A`) and commit with the provided message.     | `gac "Implemented new login feature"`                |
| `gpush`         | Git: Push current or specified branch to `origin`.                            | `gpush` or `gpush feature-branch`                    |

-----

### Networking & Proxy Functions

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `setproxyhost`  | **(NEEDS CONFIG)** Set HTTP/HTTPS/FTP proxy environment variables.            | `setproxyhost myproxy.server.com 8080 [user] [pass]` |
| `unsetproxy`    | Unset HTTP/HTTPS/FTP proxy environment variables.                             | `unsetproxy`                                         |
| `setsocks`      | **(NEEDS CONFIG)** Set SOCKS5 proxy environment variables (using `ALL_PROXY`).| `setsocks my.socks.server 1080 [user] [pass]`        |
| `unsetsocks`    | Unset SOCKS5 proxy environment variables.                                     | `unsetsocks`                                         |

-----

### Software Management & Utility Functions

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `get_anaconda`  | Downloads the specified Anaconda installer script and makes it executable.    | `get_anaconda` or `get_anaconda ~/my_installers`     |
| `emptytrash`    | **Trash Mgmt:** Interactively permanently delete all items in `~/.Trash`.     | `emptytrash`                                         |
| `cleartrash`    | Alias for `emptytrash`.                                                       | `cleartrash`                                         |

-----

### Python Environment Management Functions

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `mkcenv`        | Create a Conda environment and optionally install packages.                   | `mkcenv myenv python=3.9 numpy pandas`               |
| `mkstdvenv`     | Create a standard Python virtual environment (using `python3 -m venv`).       | `mkstdvenv .myenv` or `mkstdvenv` (creates `.venv`)  |
| `mkuvenv`       | Create a Python virtual environment using `uv` (if `uv` installed).           | `mkuvenv .my_uv_env` or `mkuvenv` (creates `.venv`)  |
| `act`           | Activate a Python virtual environment (if `uv` installed, also generic).      | `act` (tries `.venv`, `venv`, `env`) or `act myenv`    |

-----

### Tool-Specific Helper Functions (with install prompt)

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `t`             | **Tmux:** Start new or attach to existing tmux session. Prompts to install if missing. Handles various scenarios like being inside/outside tmux. | `t` (intelligent attach/new) or `t mysession`                   |
| `nvt`           | **Nvitop:** Run `nvitop` for NVIDIA GPU monitoring. Prompts to install if missing. | `nvt` or `nvt -m` (passes args to nvitop)         |

## ⚠️ Critical: Proxy Configuration ⚠️

If you plan to use the proxy helper functions (`setproxyhost`, `setsocks`):

  * You **MUST** open `~/.bash_aliases`.
  * Locate the `setproxyhost` and `setsocks` functions within this file.
  * Replace placeholder values like `YOUR_PROXY_HOST`, `YOUR_PROXY_PORT`, `YOUR_USERNAME`, `YOUR_PASSWORD` with your **actual proxy server details and credentials**.
  * Adjust the `no_proxy` list in `setproxyhost` to include any internal domains you need to access directly without going through the proxy.

## Customization

### Adding or Modifying Commands

To add new aliases or functions, or to modify existing ones:

1.  Open `~/.bash_aliases` with your preferred text editor (e.g., `nano ~/.bash_aliases`).
2.  Make your changes.
3.  Save the file.
4.  Apply the changes (see "Activation" below).

## Activation

For any changes made to `~/.bash_aliases` to take effect in your current terminal session, you must re-source your `~/.bashrc` file:

```bash
source ~/.bashrc
```

Alternatively, you can close your current terminal window and open a new one. New terminal sessions will automatically load the updated configuration from `~/.bash_aliases`.
