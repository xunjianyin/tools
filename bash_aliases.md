# My Custom Bash Environment Setup

This document outlines the setup for custom aliases and functions used to enhance the Bash shell experience. All custom commands are stored in `~/.bash_aliases` for better organization and easier management.

## Purpose

The primary goal of this setup is to:
* Streamline common command-line tasks using shorter, memorable aliases.
* Implement more complex custom commands using Bash functions.
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

## Custom Commands in `~/.bash_aliases`

Below is a detailed list of the aliases and functions available:

### Aliases

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
| `rm`       | Prompt before removing multiple files or recursively.                       | `rm -I`                         |
| `mkdir`    | Create directory, including parent directories, with verbose output.        | `mkdir -pv`                     |
| `dfh`      | Show disk free space in human-readable format.                              | `df -h`                         |
| `duh`      | Show disk usage of current folder in human-readable format.                 | `du -sh`                        |
| `dufh`     | Show disk usage of items in current directory, sorted by size.              | `du -sh * \| sort -rh`          |
| `freeh`    | Show free memory in human-readable format.                                  | `free -h`                       |
| `psef`     | Grep process list (case-insensitive).                                       | `ps -ef \| grep --color=auto -i`|
| `myip`     | Get your public IP address.                                                 | `curl -s ipinfo.io/ip`          |
| `update`   | Update system packages (Debian/Ubuntu example).                             | `sudo apt update && sudo apt upgrade -y` |
| `cls`      | Clear terminal screen.                                                      | `clear`                         |
| `c`        | Clear terminal screen.                                                      | `clear`                         |
| `pingg`    | Ping https://www.google.com/url?sa=E\&source=gmail\&q=google.com.                                                            | `ping google.com`               |
| `gpu`      | Show NVIDIA GPU status.                                                     | `nvidia-smi`                    |
| `gpumem`   | Show NVIDIA GPU memory usage (used, total).                                 | `nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits` |
| `gpuwatch` | Monitor NVIDIA GPU status, refreshing every 1 second.                       | `watch -n 1 nvidia-smi`         |
| `sln`      | Create a symbolic link (source target).                                     | `ln -s`                         |
| `slnh`     | Create a symbolic link (target link\_name).                                  | `ln -s -T`                      |
| `gcl`      | Git clone a repository.                                                     | `git clone`                     |
| `ga`       | Git add specific files.                                                     | `git add`                       |
| `gaa`      | Git add all changes in the current directory.                               | `git add .`                     |
| `gad`      | Git add all changes in the repository (tracked and untracked).              | `git add -A`                    |
| `gc`       | Git commit with a message.                                                  | `git commit -m`                 |
| `gca`      | Git add all tracked files and commit.                                       | `git commit -a -m`              |
| `gco`      | Git checkout a branch or commit.                                            | `git checkout`                  |
| `gcb`      | Git create and checkout a new branch.                                       | `git checkout -b`               |
| `gb`       | Git list branches.                                                          | `git branch`                    |
| `gbd`      | Git delete a branch.                                                        | `git branch -d`                 |
| `gbD`      | Git force delete a branch.                                                  | `git branch -D`                 |
| `gs`       | Git status (short format, with branch info).                                | `git status -sb`                |
| `gst`      | Git status.                                                                 | `git status`                    |
| `gd`       | Git diff (show changes).                                                    | `git diff`                      |
| `gds`      | Git diff (show staged changes).                                             | `git diff --staged`             |
| `gp`       | Git push.                                                                   | `git push`                      |
| `gpo`      | Git push current branch to origin.                                          | `git push origin $(git rev-parse --abbrev-ref HEAD)` |
| `gpl`      | Git pull.                                                                   | `git pull`                      |
| `gplr`     | Git pull with rebase.                                                       | `git pull --rebase`             |
| `glg`      | Git log (one line, graph, decorated, all).                                  | `git log --oneline --graph --decorate --all` |
| `glg_`     | Git log (alternative detailed and colored view).                              | `git log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit` |
| `gignore`  | Tell Git to ignore tracking changes to a file.                              | `git update-index --assume-unchanged` |
| `gunignore`| Tell Git to resume tracking changes to a file.                              | `git update-index --no-assume-unchanged` |
| `gundo`    | Undo last commit, keeping changes in working directory.                     | `git reset HEAD~`               |
| `gclean`   | Remove untracked files and directories from Git working tree.               | `git clean -fd`                 |
| `ghprc`    | GitHub CLI: create pull request.                                            | `gh pr create`                  |
| `ghprl`    | GitHub CLI: list pull requests.                                             | `gh pr list`                    |
| `ghprv`    | GitHub CLI: view pull request.                                              | `gh pr view`                    |
| `ghrepoweb`| GitHub CLI: open current repository in web browser.                         | `gh repo view --web`            |
| `ca`       | Conda activate environment.                                                 | `conda activate`                |
| `cdx`      | Conda deactivate environment.                                               | `conda deactivate`              |
| `clse`     | Conda list environments.                                                    | `conda env list`                |
| `cenv`     | Conda list environments (alternative).                                      | `conda env list`                |
| `cins`     | Conda install packages.                                                     | `conda install`                 |
| `cunins`   | Conda uninstall packages.                                                   | `conda uninstall`               |
| `ccreate`  | Conda create new environment (prefix for `conda create -n`).                | `conda create -n`               |
| `csearch`  | Conda search for packages.                                                  | `conda search`                  |
| `cupc`     | Conda update conda itself.                                                  | `conda update conda`            |
| `cupall`   | Conda update all packages in current environment.                           | `conda update --all`            |
| `crmenv`   | Conda remove an environment.                                                | `conda env remove -n`           |
| `uvv`      | `uv`: create virtual environment (requires `uv` to be installed).           | `uv venv`                       |
| `uva`      | `uv`: activate virtual environment (e.g., `.venv/bin/activate`).            | `source .venv/bin/activate`     |
| `uvi`      | `uv`: install packages.                                                     | `uv pip install`                |
| `uvu`      | `uv`: uninstall packages.                                                   | `uv pip uninstall`              |
| `uvl`      | `uv`: list installed packages.                                              | `uv pip list`                   |
| `uvf`      | `uv`: freeze installed packages (like `pip freeze`).                        | `uv pip freeze`                 |
| `uvsync`   | `uv`: synchronize environment from a requirements file.                     | `uv pip sync`                   |
| `uvtree`   | `uv`: show dependency tree.                                                 | `uv pip tree`                   |
| `uvcompile`| `uv`: compile requirements.txt to requirements.lock.                        | `uv pip compile`                |

### Functions

| Function        | Description                                                                   | Usage Example                                        |
| :-------------- | :---------------------------------------------------------------------------- | :--------------------------------------------------- |
| `mkcd`          | Create a directory (and any parent directories) and then change into it.      | `mkcd my_new_project`                                |
| `findf`         | Find a file by name (case-insensitive) in current or specified directory.     | `findf report.txt` or `findf image.jpg ./docs`       |
| `grepdir`       | Recursively search for text patterns within files in current/specified dir.   | `grepdir "API_KEY"` or `grepdir "TODO" "*.py"`       |
| `backupfile`    | Create a backup of a file or directory with a timestamp.                      | `backupfile important.doc` or `backupfile project_folder` |
| `extract`       | Extract various archive types (tar.gz, zip, rar, etc.).                       | `extract archive.zip` or `extract data.tar.bz2`      |
| `lsbig`         | List N largest files/directories in the current path (default N=20).          | `lsbig` or `lsbig 10`                                |
| `gac`           | Git: Add all changes and commit with the provided message.                    | `gac "Implemented new login feature"`                |
| `gpush`         | Git: Push current or specified branch to origin.                              | `gpush` or `gpush feature-branch`                    |
| `setproxyhost`  | **(NEEDS CONFIG)** Set HTTP/HTTPS/FTP proxy environment variables.            | `setproxyhost myproxy.server.com 8080 [user] [pass]` |
| `unsetproxy`    | Unset HTTP/HTTPS/FTP proxy environment variables.                             | `unsetproxy`                                         |
| `setsocks`      | **(NEEDS CONFIG)** Set SOCKS5 proxy environment variables (using ALL\_PROXY).  | `setsocks my.socks.server 1080 [user] [pass]`        |
| `unsetsocks`    | Unset SOCKS5 proxy environment variables.                                     | `unsetsocks`                                         |
| `conn`          | Quickly SSH into a host (uses current username if not specified).             | `conn myserver` or `conn user@another.server.com`    |
| `mkcenv`        | Create a Conda environment and optionally install packages.                   | `mkcenv myenv python=3.9 numpy pandas`               |
| `mkstdvenv`     | Create a standard Python virtual environment (using `python3 -m venv`).       | `mkstdvenv .myenv` or `mkstdvenv` (creates `.venv`)  |
| `mkuvenv`       | Create a Python virtual environment using `uv` (if installed).                | `mkuvenv .my_uv_env` or `mkuvenv` (creates `.venv`)  |
| `act`           | Activate a Python virtual environment (looks for common names or takes path). | `act` (tries `.venv`, `venv`, `env`) or `act myenv`    |

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
