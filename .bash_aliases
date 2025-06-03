# ~/.bash_aliases
# My custom Bash aliases and functions

# =============================================================================
# ALIASES
# =============================================================================

# --- Navigation & Listing ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto' # List all files in long format with type indicators
alias la='ls -A --color=auto'   # List all files including hidden
alias l='ls -CF --color=auto'   # List files in columns with type indicators
alias lsg='ll | grep --color=auto -i' # List and grep

# --- File & Directory Management ---
alias cp='cp -iv'          # Prompt before overwrite, verbose
alias mv='mv -iv'          # Prompt before overwrite, verbose
alias rm='rm -I'           # Prompt once before removing more than three files, or when removing recursively.
alias mkdir='mkdir -pv'    # Create parent directories as needed, verbose

# --- System & Info ---
alias dfh='df -h'          # Disk free, human-readable
alias duh='du -sh'         # Disk usage of current folder (human-readable)
alias dufh='du -sh * | sort -rh' # Disk usage of files/folders in current directory, sorted by size
alias freeh='free -h'      # Free memory, human-readable
alias psef='ps -ef | grep --color=auto -i' # Grep process list
alias myip='curl -s ipinfo.io/ip || curl -s ifconfig.me' # Get public IP
alias update='sudo apt update && sudo apt upgrade -y' # For Debian/Ubuntu. Adjust for other distros.
alias cls='clear'
alias c='clear'
alias pingg='ping google.com'

# --- GPU Related (NVIDIA) ---
alias gpu='nvidia-smi'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits'
alias gpuwatch='watch -n 1 nvidia-smi'

# --- Symbolic Links ---
alias sln='ln -s'       # Create symbolic link (source target)
alias slnh='ln -s -T'   # Create symbolic link (target link_name - more intuitive for some)

# --- Git ---
alias gcl='git clone'
alias ga='git add'
alias gaa='git add .'
alias gad='git add -A'
alias gc='git commit -m'
alias gca='git commit -a -m' # Add all tracked files and commit
alias gco='git checkout'
alias gcb='git checkout -b' # Create and checkout new branch
alias gb='git branch'
alias gbd='git branch -d' # Delete branch
alias gbD='git branch -D' # Force delete branch
alias gs='git status -sb' # Short branch status
alias gst='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git push'
alias gpo='git push origin "$(git rev-parse --abbrev-ref HEAD)"' # Push current branch to origin
alias gpl='git pull'
alias gplr='git pull --rebase'
alias glg='git log --oneline --graph --decorate --all' # Nice git log view
alias glg_='git log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit' # Another detailed log
alias gignore='git update-index --assume-unchanged' # Ignore tracking for a file
alias gunignore='git update-index --no-assume-unchanged' # Resume tracking for a file
alias gundo='git reset HEAD~' # Undo last commit, keep changes
alias gclean='git clean -fd'  # Remove untracked files and directories

# For GitHub CLI (gh) if installed
if command -v gh &> /dev/null; then
    alias ghprc='gh pr create'
    alias ghprl='gh pr list'
    alias ghprv='gh pr view'
    alias ghrepoweb='gh repo view --web' # Open current repo in browser
fi

# --- Conda ---
alias ca='conda activate'
alias cdx='conda deactivate' # 'cd' is too common, 'cdeact' is also an option
alias clse='conda env list'
alias cenv='conda env list'
alias cins='conda install'
alias cunins='conda uninstall'
alias ccreate='conda create -n'
# Example: ccreate myenv python=3.10 numpy pandas -c conda-forge
alias csearch='conda search'
alias cupc='conda update conda'
alias cupall='conda update --all'
alias crmenv='conda env remove -n' # Remove environment

# --- Standard Python venv & uv ---
# `uv` is a fast Python package installer and resolver.
# `uv venv` creates a standard Python virtual environment.
if command -v uv &> /dev/null; then
    alias uvv='uv venv' # Create venv (e.g., uvv .venv)
    alias uva='source .venv/bin/activate' # Common activation path, adjust if your venv name differs
                                        # You might prefer a function like `act <name>`
    alias uvi='uv pip install'
    alias uvu='uv pip uninstall'
    alias uvl='uv pip list'
    alias uvf='uv pip freeze'
    alias uvsync='uv pip sync' # Sync environment from requirements file
    alias uvtree='uv pip tree' # Show dependency tree
    alias uvcompile='uv pip compile' # Compile requirements.txt to requirements.lock
fi

# --- Tmux (Terminal Multiplexer) ---
# The main tmux command 't' is a function below for comprehensive session management.
# Aliases for common operations:
if command -v tmux &> /dev/null; then
    alias tl='tmux ls'                      # List active tmux sessions
    alias ta='tmux attach-session -t'       # Attach to a specific session: ta <session_name>
    alias tat='tmux attach-session -t'      # (Alternative) Attach to a specific session: tat <session_name>
    alias tn='tmux new-session -s'          # Create a new named session: tn <session_name>
    alias td='tmux detach-client'           # Detach current client (use INSIDE tmux)
    alias tkill='tmux kill-session -t'      # Kill a specific session: tkill <session_name>
    alias tkillsrv='tmux kill-server'       # Kill the tmux server and all sessions

    # Aliases for use INSIDE a tmux session:
    alias tnw='tmux new-window -c "#{pane_current_path}"'             # New window (opens in current path)
    alias trns='tmux rename-session'      # Rename current session: trns <new_name>
    alias trnw='tmux rename-window'       # Rename current window: trnw <new_name>
    alias tsph='tmux split-window -h -c "#{pane_current_path}"'      # Split pane horizontally (in current path)
    alias tspv='tmux split-window -v -c "#{pane_current_path}"'      # Split pane vertically (in current path)
    alias tsnxt='tmux next-window'        # Go to next window
    alias tsprev='tmux previous-window'   # Go to previous window
    alias tslw='tmux last-window'         # Go to last (previously selected) window
    alias tkw='tmux kill-window'          # Kill current window (tmux kill-window -t :<current_window_id>)
    alias tkp='tmux kill-pane'            # Kill current pane (tmux kill-pane -t :<current_pane_id>)
fi
# The main nvitop command 'nvt' is a function below to handle installation check

# =============================================================================
# FUNCTIONS
# =============================================================================

# --- Directory & File Operations ---
# Create a directory and change into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Find a file by name (case-insensitive)
# Usage: findf <filename_pattern> [directory_to_search_in]
findf() {
    local search_dir=${2:-.} # Default to current directory if not specified
    find "$search_dir" -iname "*$1*"
}

# Find text in files (recursive grep)
# Usage: grepdir <text_pattern> [file_pattern e.g. "*.py"] [directory]
grepdir() {
    local pattern="$1"
    local file_glob="${2:-*}" # Default to all files if not specified
    local search_dir="${3:-.}" # Default to current directory

    if [ "$file_glob" = "*" ]; then
        grep -rIl --color=auto "$pattern" "$search_dir"
    else
        grep -rIl --color=auto --include="$file_glob" "$pattern" "$search_dir"
    fi
}

# Backup a file or directory with a timestamp
# Usage: backupfile <filename_or_dirname>
backupfile() {
    if [ ! -e "$1" ]; then
        echo "Error: File or directory '$1' not found."
        return 1
    fi
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="${1%/}_${timestamp}" # Remove trailing slash if any for dirs

    if [ -d "$1" ]; then
        tar -czf "${backup_name}.tar.gz" "$1" && echo "Directory backup created: ${backup_name}.tar.gz" || echo "Backup failed."
    else
        cp "$1" "$backup_name" && echo "File backup created: $backup_name" || echo "Backup failed."
    fi
}


# Extract various archive types
# Usage: extract <archive_file>
# Needs: tar, gzip, bzip2, unrar, unzip, p7zip-full (install if missing)
extract() {
    if [ ! -f "$1" ] ; then
        echo "'$1' is not a valid file"
        return 1
    fi
    case "$1" in
        *.tar.bz2|*.tbz2) tar xvjf "$1" ;;
        *.tar.gz|*.tgz)   tar xvzf "$1" ;;
        *.tar.xz|*.txz)   tar xvJf "$1" ;; # Added xz
        *.bz2)            bunzip2 "$1" ;;
        *.rar)            unrar x "$1" ;; # Needs 'unrar' command
        *.gz)             gunzip "$1" ;;
        *.tar)            tar xvf "$1" ;;
        *.zip|*.jar)      unzip "$1" ;; # Added jar
        *.Z)              uncompress "$1" ;;
        *.7z)             7z x "$1" ;; # Needs 'p7zip-full' package usually
        *)                echo "Don't know how to extract '$1'..." ;;
    esac
}

# List N largest files/directories in current path
# Usage: lsbig [N=20]
lsbig() {
    local num_items=${1:-20}
    find . -type f -print0 | xargs -0 du -h | sort -rh | head -n "$num_items"
}

# Recursively list files/directories up to N levels (uses 'tree' if available)
# Usage: lstree [depth] [directory]
lstree() {
    local depth="${1:-2}"         # Default depth to 2 levels
    local target_dir="${2:-.}"    # Default target to current directory

    if ! command -v tree &> /dev/null; then
        echo "'tree' command not found. Listing with 'find' (basic output):"
        find "$target_dir" -maxdepth "$depth" -print
        echo -e "\nFor a better hierarchical view, please install 'tree'."
        echo "Example: sudo apt install tree  OR  sudo dnf install tree OR brew install tree"
        return 1
    fi
    tree -L "$depth" -aF "$target_dir" # -a for all files, -F for type indicators
}


# --- Git Functions ---
# Git commit with a message (adds all changes first)
# Usage: gac <"commit message">
gac() {
    if [ -z "$1" ]; then
        echo "Error: Please provide a commit message."
        return 1
    fi
    git add -A && git commit -m "$1"
}

# Git push current branch to origin, or specified branch
# Usage: gpush [branch_name]
gpush() {
    local branch_name=${1:-$(git rev-parse --abbrev-ref HEAD)}
    git push origin "$branch_name"
}


# --- Networking & Proxy ---
# Set up proxy with host and port arguments
# Usage: setproxyhost <proxy_host> <proxy_port> [username] [password]
setproxyhost() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: setproxyhost <proxy_host> <proxy_port> [username] [password]"
        echo "Example: setproxyhost myproxy.server.com 8080"
        echo "Example with auth: setproxyhost myproxy.server.com 8080 myuser mypass"
        return 1
    fi

    local proxy_address="$1:$2"
    local auth_proxy_address=""

    # !!! IMPORTANT: REPLACE WITH YOUR ACTUAL PROXY DETAILS IF NEEDED !!!
    # Example: local proxy_user="YOUR_USERNAME"
    # Example: local proxy_pass="YOUR_PASSWORD"
    if [ -n "$3" ] && [ -n "$4" ]; then # If username and password are provided
        auth_proxy_address="$3:$4@$proxy_address"
    elif [ -n "$3" ]; then # If only username is provided
        # This case might mean username is part of host or no password needed with user
        auth_proxy_address="$3@$proxy_address"
    fi

    if [ -n "$auth_proxy_address" ]; then
        export http_proxy="http://$auth_proxy_address"
        export https_proxy="http://$auth_proxy_address" # Often the same as http_proxy
        export ftp_proxy="http://$auth_proxy_address"
        export HTTP_PROXY="$http_proxy" # Some tools use uppercase
        export HTTPS_PROXY="$https_proxy"
        export FTP_PROXY="$ftp_proxy"
    else
        export http_proxy="http://$proxy_address"
        export https_proxy="http://$proxy_address" # Often the same as http_proxy
        export ftp_proxy="http://$proxy_address"
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$https_proxy"
        export FTP_PROXY="$ftp_proxy"
    fi

    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,*.corp.example.com" # Add your internal domains
    export NO_PROXY="$no_proxy"
    echo "Proxy set to: $([ -n "$auth_proxy_address" ] && echo "$auth_proxy_address (with auth)" || echo "$proxy_address")"
    echo "no_proxy: $no_proxy"
}

# Unset proxy settings
unsetproxy() {
    unset http_proxy https_proxy ftp_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY
    echo "Proxy environment variables unset."
}

# SOCKS5 Proxy
# Usage: setsocks <socks_host> <socks_port> [username] [password]
setsocks() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: setsocks <socks_host> <socks_port> [username] [password]"
        return 1
    fi
    local socks_address="$1:$2"
    local auth_socks_address=""

    # !!! IMPORTANT: REPLACE WITH YOUR ACTUAL SOCKS DETAILS IF NEEDED !!!
    if [ -n "$3" ] && [ -n "$4" ]; then
        auth_socks_address="$3:$4@$socks_address"
    elif [ -n "$3" ]; then
        auth_socks_address="$3@$socks_address"
    fi

    if [ -n "$auth_socks_address" ]; then
        export ALL_PROXY="socks5h://$auth_socks_address" # Use socks5h for hostname resolution by proxy
        export all_proxy="$ALL_PROXY"
    else
        export ALL_PROXY="socks5h://$socks_address"
        export all_proxy="$ALL_PROXY"
    fi
    echo "SOCKS5 proxy set to: $ALL_PROXY"
}

unsetsocks() {
    unset ALL_PROXY all_proxy
    echo "SOCKS5 proxy (ALL_PROXY) unset."
}


# Quick SSH
# Usage: conn <user@host> OR conn <host> (uses current username)
conn() {
    if [[ "$1" == *"@"* ]]; then
        ssh "$1"
    else
        ssh "$(whoami)@$1"
    fi
}

# --- Software Installation & Management ---
# Download and prepare Anaconda installer
get_anaconda() {
    local anaconda_url="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh" # URL provided by user
    local installer_name
    installer_name=$(basename "$anaconda_url")
    local download_dir="${1:-$HOME/Downloads/Installers}" # Default download directory

    echo "Anaconda Installer URL: $anaconda_url"
    echo "Note: This URL is for a specific version. For the latest, please check the Anaconda website."

    if [ ! -d "$download_dir" ]; then
        mkdir -p "$download_dir"
        echo "Created download directory: $download_dir"
    fi

    echo "Downloading Anaconda installer to $download_dir/$installer_name..."
    wget -P "$download_dir" "$anaconda_url"

    if [ -f "$download_dir/$installer_name" ]; then
        echo "Download complete: $download_dir/$installer_name"
        chmod +x "$download_dir/$installer_name"
        echo "Installer made executable."
        echo -e "\nTo install Anaconda, run:"
        echo "  bash $download_dir/$installer_name"
        echo "Follow the on-screen prompts during installation."
        echo "It's recommended to NOT let the installer initialize conda by modifying your shell rc file automatically if you prefer manual setup or already have one."
    else
        echo "Error: Anaconda installer download failed."
        return 1
    fi
}

# --- Python & Virtual Environment Management ---
# Create Conda environment and install common packages
# Usage: mkcenv <env_name> [python_version=3.10] [package1 package2 ...]
mkcenv() {
    local env_name="$1"
    if [ -z "$env_name" ]; then
        echo "Usage: mkcenv <env_name> [python_version] [package1 package2 ...]"
        return 1
    fi
    shift # Remove env_name from arguments

    local python_version="3.10" # Default Python version
    if [[ "$1" =~ ^[0-9]+\.[0-9]+([0-9]+)?$ ]]; then # Check if first arg is a version
        python_version="$1"
        shift
    fi

    echo "Creating Conda environment: $env_name with Python $python_version"
    conda create -n "$env_name" python="$python_version" -y
    if [ $? -eq 0 ]; then
        echo "Activating environment: $env_name"
        # For direct activation in script, one might need: eval "$(conda shell.bash hook)" then conda activate
        conda activate "$env_name"
        if [ "$#" -gt 0 ]; then
            echo "Installing packages: $@"
            conda install -n "$env_name" "$@" -y
        fi
        echo "Done. To activate manually: conda activate $env_name"
    else
        echo "Failed to create Conda environment '$env_name'."
    fi
}


# Create Python virtual environment (using python3 -m venv) and optionally activate
# Usage: mkstdvenv [env_name] [--no-activate]
# Default env_name is '.venv'
mkstdvenv() {
    local env_name="${1:-.venv}" # Default to '.venv'
    local activate_env=true

    if [ "$1" == "--no-activate" ]; then
        env_name=".venv"
        activate_env=false
    elif [ "$2" == "--no-activate" ]; then
        activate_env=false
    fi

    if [ -d "$env_name" ]; then
        echo "Directory '$env_name' already exists."
    else
        echo "Creating standard Python virtual environment '$env_name'..."
        python3 -m venv "$env_name"
        echo "Python virtual environment '$env_name' created."
    fi

    if [ "$activate_env" = true ] && [ -f "$env_name/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$env_name/bin/activate"
        echo "Activated virtual environment '$env_name'."
    elif [ "$activate_env" = true ]; then
        echo "Could not find activate script for '$env_name'."
    fi
}

# uv related functions (conditional on uv installation)
if command -v uv &> /dev/null; then
    # Create venv using uv and activate
    # Usage: mkuvenv [env_name=.venv] [--no-activate]
    mkuvenv() {
        local env_name="${1:-.venv}"
        local activate_env=true

        if [ "$1" == "--no-activate" ]; then
            env_name=".venv" # Reset to default if first arg is the flag
            activate_env=false
        elif [ "$2" == "--no-activate" ]; then
            activate_env=false
        fi

        if [ -d "$env_name" ]; then
            echo "Directory '$env_name' already exists. Using existing."
        else
            echo "Creating Python virtual environment '$env_name' using uv..."
            uv venv "$env_name"
            if [ $? -ne 0 ]; then
                echo "Failed to create venv with uv."
                return 1
            fi
            echo "Python virtual environment '$env_name' created."
        fi

        if [ "$activate_env" = true ] && [ -f "$env_name/bin/activate" ]; then
            # shellcheck source=/dev/null
            source "$env_name/bin/activate"
            echo "Activated virtual environment '$env_name'."
        elif [ "$activate_env" = true ]; then
            echo "Could not find activate script for '$env_name'."
        fi
    }

    # Activate a virtual environment in the current directory or specified path
    # Usage: act [path_to_venv_dir OR venv_name_in_current_dir]
    # Example: act .venv  OR  act my_project_env
    act() {
        local venv_path="$1"
        if [ -z "$venv_path" ]; then # If no argument, try common names
            if [ -f ".venv/bin/activate" ]; then
                venv_path=".venv"
            elif [ -f "venv/bin/activate" ]; then
                venv_path="venv"
            elif [ -f "env/bin/activate" ]; then
                venv_path="env"
            else
                echo "No virtual environment specified and common names (.venv, venv, env) not found in current directory."
                echo "Usage: act [path_to_venv_dir]"
                return 1
            fi
        fi

        if [ -f "$venv_path/bin/activate" ]; then
            # shellcheck source=/dev/null
            source "$venv_path/bin/activate"
            echo "Activated: $venv_path"
        else
            echo "Error: Activation script not found at '$venv_path/bin/activate'"
            return 1
        fi
    }
fi


# --- Tmux (Terminal Multiplexer) ---
# Main tmux utility function: start new or attach to existing session.
# Prompts to install if tmux is missing.
# Usage: t [session_name]
t() {
    if ! command -v tmux &> /dev/null; then
        echo "tmux could not be found."
        read -r -p "Do you want to try installing it? (e.g., sudo apt install tmux) [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            # Attempt to install based on common package managers
            if command -v apt &> /dev/null; then sudo apt update && sudo apt install tmux -y;
            elif command -v dnf &> /dev/null; then sudo dnf install tmux -y;
            elif command -v yum &> /dev/null; then sudo yum install tmux -y;
            elif command -v pacman &> /dev/null; then sudo pacman -S tmux --noconfirm;
            elif command -v brew &> /dev/null; then brew install tmux;
            else echo "Package manager not recognized. Please install tmux manually."; return 1; fi

            if ! command -v tmux &> /dev/null; then
                 echo "tmux installation failed or was not completed. Please install it manually."
                 return 1
            fi
            echo "tmux installed successfully. Please run the command 't' again."
        else
            echo "Please install tmux to use this command."
            return 1
        fi
        return 0 # Exit after install attempt message
    fi

    local session_name="$1"
    # Check if already inside a tmux session
    if [ -n "$TMUX" ]; then
        if [ -z "$session_name" ]; then # Called as 't' inside tmux
            echo "Already inside a tmux session. Current session: $TMUX_PANE"
            echo "Use 'td' to detach, or tmux keybindings (e.g., Ctrl-b d)."
            return 0
        else # Called as 't <something>' inside tmux
            echo "Already inside a tmux session. To switch sessions, detach ('td') and re-attach, or use tmux keybindings (e.g. Ctrl-b s)."
            return 0
        fi
    fi

    if [ -z "$session_name" ]; then # No session name provided (and not inside tmux)
        if tmux has-session 2>/dev/null; then
            local num_sessions
            num_sessions=$(tmux ls 2>/dev/null | wc -l)
            if [ "$num_sessions" -eq 1 ]; then
                local only_session_name
                only_session_name=$(tmux ls -F "#{session_name}" 2>/dev/null)
                echo "Attaching to the only existing session: $only_session_name"
                tmux attach-session # Attaches to the only session or last active
            else
                echo "Available sessions:"
                tmux ls
                echo "To attach, use 't <session_name>', 'ta <session_name>', or 'tmux attach-session -t <session_name>'."
                echo "Attempting to attach to the last active session..."
                tmux attach-session # Attaches to last active by default
            fi
        else
            # No sessions running, create a new unnamed one
            echo "No sessions running. Creating and attaching to a new session..."
            tmux new-session
        fi
    else # Session name provided (and not inside tmux)
        if tmux has-session -t "=$session_name" 2>/dev/null; then # Check if session exists (exact match)
            echo "Attaching to existing tmux session: $session_name"
            tmux attach-session -t "$session_name"
        else
            echo "Creating and attaching to new tmux session: $session_name"
            tmux new-session -s "$session_name"
        fi
    fi
}

# --- Nvitop (NVIDIA GPU Monitoring) ---
# Main nvitop utility function: run nvitop, prompting for install if not found
# Usage: nvt [nvitop_arguments]
nvt() {
    if ! command -v nvitop &> /dev/null; then
        echo "nvitop could not be found."
        read -r -p "Do you want to try installing it? (e.g., pip install nvitop) [y/N] " response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            # Attempt to install using pip or pip3
            if command -v pip3 &> /dev/null; then pip3 install nvitop;
            elif command -v pip &> /dev/null; then pip install nvitop;
            else echo "pip (or pip3) could not be found. Please install nvitop manually (e.g., using your system's package manager or pip)."; return 1; fi

            if ! command -v nvitop &> /dev/null; then
                 echo "nvitop installation failed or was not completed. Please ensure it's in your PATH."
                 return 1
            fi
            echo "nvitop installed successfully. Please run the command 'nvt' again."
        else
            echo "Please install nvitop to use this command."
            return 1
        fi
        return 0 # Exit after install attempt message
    fi
    # Execute nvitop with any arguments passed to this function
    nvitop "$@"
}

# ------ rm --------
trash() {
    local trash_dir="${HOME}/.Trash"
    mkdir -p "$trash_dir" || {
        echo "Error: Could not create trash directory '$trash_dir'" >&2
        return 1
    }

    local r_flag=0
    local f_flag=0
    local v_flag=0
    local files=()

    while getopts "rfv" opt; do
        case "$opt" in
            r) r_flag=1 ;;
            f) f_flag=1 ;;
            v) v_flag=1 ;;
            \?)
                echo "Usage: rm [OPTION]... [FILE]..." >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND - 1))

    # Validate inputs
    if [ "$#" -eq 0 ]; then
        echo "rm (trash): missing operand" >&2
        echo "Usage: rm [OPTION]... [FILE]..." >&2
        return 1
    fi

    # Handle the files
    for file in "$@"; do
        if [ ! -e "$file" ] && [ ! -L "$file" ]; then
            if [ "$f_flag" -eq 1 ]; then
                continue
            else
                echo "rm (trash): cannot remove '$file': No such file or directory" >&2
                return 1
            fi
        fi

        # Get absolute path
        local real_file_path
        real_file_path=$(realpath -- "$file" 2>/dev/null || echo "$file")
        local real_trash_path
        real_trash_path=$(realpath -- "$trash_dir" 2>/dev/null || echo "$trash_dir")

        # Refuse to move trash dir itself or HOME/other protected directories
        if [[ "$real_file_path" == "$real_trash_path" ]] || [[ "$real_file_path" == "$(dirname "$real_trash_path")" ]] || [[ "$real_file_path" == "$HOME" ]] ; then
            echo "rm (trash): Refusing to move directory '$file' or home itself!" >&2
            return 1
        fi

        # Build name with timestamp
        local basename
        basename=$(basename -- "$file")
        local timestamp
        timestamp=$(date +%Y%m%d_%H%M%S_%N)
        local trashed_file_name="${basename}.${timestamp}"
        local full_trashed_path="${trash_dir}/${trashed_file_name}"

        # verbose mode
        if [ "$v_flag" -eq 1 ]; then
            echo "rm (trash): moving '$file' to '$full_trashed_path'"
        fi

        # Move to trash
        if mv -- "$file" "$full_trashed_path"; then
            if [ "$v_flag" -eq 1 ]; then
                echo "rm (trash): moved '$file' to '$full_trashed_path'"
            fi
        else
            echo "rm (trash): error moving '$file' to trash" >&2
            return 1
        fi
    done
}
alias rm='trash'

# =============================================================================
# END OF CUSTOMIZATIONS
# =============================================================================
echo "Personalized .bash_aliases loaded! 🚀" # Optional: for confirmation
