# Make Bash history better
export HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and commands starting with space
export HISTSIZE=10000                   # Long history
export HISTFILESIZE=20000               # Long history file
shopt -s histappend                     # Append to history, don't overwrite

# Colored prompt (example, customize as you like)
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable programmable completion features (if not already enabled in /etc/bash.bashrc)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# =============================================================================
# ALIASES - SHORTCUTS FOR COMMON COMMANDS
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
alias rm='rm -I'           # Prompt once before removing more than three files, or when removing recursively. Use 'rm -i' for per-file prompt.
alias mkdir='mkdir -pv'    # Create parent directories as needed, verbose

# --- System & Info ---
alias dfh='df -h'          # Disk free, human-readable
alias duh='du -sh'         # Disk usage of current folder (human-readable)
alias dufh='du -sh * | sort -rh' # Disk usage of files/folders in current directory, sorted by size
alias freeh='free -h'      # Free memory, human-readable
alias psef='ps -ef | grep --color=auto -i' # Grep process list
alias myip='curl -s ipinfo.io/ip || curl -s ifconfig.me' # Get public IP
alias update='sudo apt update && sudo apt upgrade -y' # For Debian/Ubuntu systems. Change for other distros (e.g., `sudo dnf upgrade` for Fedora, `sudo pacman -Syu` for Arch)
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
alias ghprc='gh pr create'
alias ghprl='gh pr list'
alias ghprv='gh pr view'
alias ghrepoweb='gh repo view --web' # Open current repo in browser

# =============================================================================
# FUNCTIONS - MORE POWERFUL CUSTOM COMMANDS (CAN TAKE ARGUMENTS)
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
    # -r: recursive
    # -I: ignore binary files (GNU grep specific, might not be on macOS)
    # -l: print only filenames with matches
}

# Backup a file with a timestamp
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
        *.rar)            unrar x "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.tar)            tar xvf "$1" ;;
        *.zip|*.jar)      unzip "$1" ;; # Added jar
        *.Z)              uncompress "$1" ;;
        *.7z)             7z x "$1" ;;
        *)                echo "Don't know how to extract '$1'..." ;;
    esac
}

# List N largest files/directories in current path
# Usage: lsbig [N=20]
lsbig() {
    local num_items=${1:-20}
    find . -type f -print0 | xargs -0 du -h | sort -rh | head -n "$num_items"
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
    if [ -n "$3" ] && [ -n "$4" ]; then # If username and password are provided
        auth_proxy_address="$3:$4@$proxy_address"
    elif [ -n "$3" ]; then # If only username is provided
        echo "Warning: Username provided without a password. Assuming username is part of host or proxy needs only username."
        auth_proxy_address="$3@$proxy_address" # Or handle as an error specific to your proxy
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

# SOCKS5 Proxy (Example with port 1080)
# Usage: setsocks <socks_host> <socks_port> [username] [password]
setsocks() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: setsocks <socks_host> <socks_port> [username] [password]"
        return 1
    fi
    local socks_address="$1:$2"
    local auth_socks_address=""

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
    # Note: Some applications might need http_proxy/https_proxy to point to socks proxy
    # e.g. export http_proxy="socks5h://user:pass@host:port"
    # This function sets ALL_PROXY which is respected by curl, git, etc.
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

# =============================================================================
# PYTHON & VIRTUAL ENVIRONMENT MANAGEMENT
# =============================================================================

# --- Conda ---
# Make sure conda is initialized first. If not, run `conda init bash` once.
# The following aliases assume conda base environment is not auto-activated,
# or you want explicit commands.

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

# Function to create conda env and install common packages
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
        # Conda activate might not work directly in scripts this way always,
        # but user can manually activate. For direct activation in script,
        # one might need: eval "$(conda shell.bash hook)" then conda activate
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


# --- Standard Python venv & uv ---
# `uv` is a fast Python package installer and resolver.
# `uv venv` creates a standard Python virtual environment.

# Create Python virtual environment (using python3 -m venv) and optionally activate
# Usage: mkvenv [env_name] [--no-activate]
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

# Aliases for uv (if you have it installed: `pip install uv` or `cargo install uv`)
if command -v uv &> /dev/null; then
    alias uvv='uv venv' # Create venv (e.g., uvv .venv)
    alias uva='source .venv/bin/activate' # Common activation path, adjust if your venv name differs
                                        # You might prefer a function like `activate_venv <name>`
    alias uvi='uv pip install'
    alias uvu='uv pip uninstall'
    alias uvl='uv pip list'
    alias uvf='uv pip freeze'
    alias uvsync='uv pip sync' # Sync environment from requirements file
    alias uvtree='uv pip tree' # Show dependency tree
    alias uvcompile='uv pip compile' # Compile requirements.txt to requirements.lock

    # Create venv using uv and activate
    # Usage: mkuvenv [env_name=.venv] [--no-activate]
    mkuvenv() {
        local env_name="${1:-.venv}"
        local activate_env=true

        if [ "$1" == "--no-activate" ]; then
            env_name=".venv"
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


# =============================================================================
# END OF CUSTOMIZATIONS
# =============================================================================

# Source global bashrc if it exists
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Add user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

echo "Custom .bashrc loaded successfully!" # Optional: for confirmation
