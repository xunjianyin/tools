# ~/.zsh_aliases
# My custom Zsh aliases and functions

# =============================================================================
# PRELIMINARY HELPER FUNCTIONS (for safe_rm)
# =============================================================================

# Basic realpath fallback if `realpath` command is not available.
# GNU realpath is preferred (on macOS, install with 'brew install coreutils' and use 'grealpath').
# Needed for safety checks in safe_rm.
_my_realpath() {
    if command -v realpath &> /dev/null; then
        realpath -m -- "$1" # -m for no error on non-existent paths, useful for checks
    else
        # Basic fallback for realpath - less robust than GNU realpath for complex symlink scenarios
        local path_to_resolve="$1"
        local abs_path=""
        if [ -d "$path_to_resolve" ]; then
            abs_path=$(cd "$path_to_resolve" 2>/dev/null && pwd -P)
        elif [ -e "$path_to_resolve" ]; then # Handles files and existing symlinks
            local dir_name base_name
            dir_name=$(dirname -- "$path_to_resolve")
            base_name=$(basename -- "$path_to_resolve")
            if [ "$dir_name" = "." ]; then # File in current directory
                abs_path="$(pwd -P)/$base_name"
            else
                abs_path=$(cd "$dir_name" 2>/dev/null && pwd -P)/"$base_name"
            fi
        fi
        # If resolution failed or path doesn't exist but we need an absolute form for comparison
        if [ -z "$abs_path" ]; then
            if [[ "$path_to_resolve" = /* ]]; then # Already absolute
                echo "$path_to_resolve"
            else # Construct absolute path from current directory
                echo "$(pwd -P)/$path_to_resolve"
            fi
        else
            echo "$abs_path"
        fi
    fi
}

# =============================================================================
# SAFE RM REPLACEMENT (MOVES TO TRASH)
# =============================================================================

# Moves files/directories to a trash folder instead of permanent deletion.
# Tries to respect -f (force, ignore non-existent) and -v (verbose) flags.
# -i (interactive) is not supported. -r (recursive) is handled by 'mv'.
safe_rm_to_trash() {
    local trash_dir="${HOME}/.Trash"
    local F_FLAG=false # Force: ignore non-existent files, no error messages for them
    local R_FLAG=false # Recursive: (effectively ignored, as 'mv' handles directories)
    local V_FLAG=false # Verbose: print what is being done
    local files_to_trash=()
    local original_args_string="$*" # For messages

    # Create trash directory if it doesn't exist
    if ! mkdir -p "${trash_dir}"; then
        echo "Error: Could not create trash directory '${trash_dir}'" >&2
        echo "Original 'rm' command not executed for: ${original_args_string}" >&2
        return 1
    fi

    # Zsh array handling - convert arguments to array
    local args_copy=("$@")
    local current_arg_index=1  # Zsh arrays are 1-indexed
    while [ "$current_arg_index" -le "${#args_copy[@]}" ]; do
        local arg="${args_copy[$current_arg_index]}"
        case "$arg" in
            -*) # An option or combined options (e.g., -rf, -v)
                if [[ "$arg" == *f* ]]; then F_FLAG=true; fi
                if [[ "$arg" == *r* || "$arg" == *R* ]]; then R_FLAG=true; fi # Not strictly needed for 'mv' but good for rm parity
                if [[ "$arg" == *v* ]]; then V_FLAG=true; fi
                if [[ "$arg" == *i* ]]; then
                    echo "rm (trash): Interactive mode (-i) is not supported. Command: rm $original_args_string" >&2
                    return 1;
                fi
                ;;
            --) # End of options marker
                current_arg_index=$((current_arg_index + 1))
                while [ "$current_arg_index" -le "${#args_copy[@]}" ]; do
                    files_to_trash+=("${args_copy[$current_arg_index]}")
                    current_arg_index=$((current_arg_index + 1))
                done
                break
                ;;
            *) # A file/directory
                files_to_trash+=("$arg")
                ;;
        esac
        current_arg_index=$((current_arg_index + 1))
    done
    
    if [ ${#files_to_trash[@]} -eq 0 ]; then
        if [ "$F_FLAG" = true ]; then return 0; fi # 'rm -f' with no files is a no-op
        if [[ ! "$original_args_string" =~ ^-[^-]*f ]]; then
            echo "rm (trash): missing operand" >&2
            echo "Usage: rm [OPTION]... [FILE]..." >&2
            return 1
        fi
        return 0 # Only options like -v or -r passed
    fi

    local item success_all=true
    for item in "${files_to_trash[@]}"; do
        local abs_item_path; abs_item_path=$(_my_realpath "$item")
        local abs_trash_path; abs_trash_path=$(_my_realpath "$trash_dir")
        local abs_home_path; abs_home_path=$(_my_realpath "$HOME")

        # Basic Safety checks
        if [[ "$abs_item_path" == "$abs_trash_path" ]]; then
            echo "rm (trash): Refusing to move the trash directory '$item' into itself." >&2
            success_all=false; continue
        fi
        if [[ "$abs_item_path" == "$abs_home_path" ]] && \
           [[ ( "$item" == "." && "$(pwd -P)" == "$abs_home_path" ) || \
              "$item" == "$HOME" || "$item" == "$HOME/" || "$item" == "~" || "$item" == "~/" || \
              ( "$item" == "*" && "$(pwd -P)" == "$abs_home_path" && ${#files_to_trash[@]} -eq 1 ) \
           ]]; then
            echo "rm (trash): Potentially dangerous operation on HOME directory '$item' blocked." >&2
            success_all=false; continue
        fi

        if [ ! -e "$item" ] && [ ! -L "$item" ]; then # Check if file/dir/symlink exists
            if [ "$F_FLAG" = true ]; then continue; # If -f, ignore non-existent files silently
            else echo "rm (trash): cannot remove '$item': No such file or directory" >&2; success_all=false; continue; fi
        fi

        local timestamp; timestamp=$(date +%Y%m%d_%H%M%S_%N)
        local base_name; base_name=$(basename -- "$item")
        if [ -z "$base_name" ] || [ "$base_name" = "/" ] || [ "$base_name" = "." ] || [ "$base_name" = ".." ]; then base_name="unnamed_item"; fi
        local trashed_item_name="${base_name}.${timestamp}"
        local full_trashed_path="${trash_dir}/${trashed_item_name}"

        if [ "$V_FLAG" = true ]; then echo "rm (trash): moving '$item' to '$full_trashed_path'"; fi

        if mv -- "$item" "$full_trashed_path"; then
            if [ "$V_FLAG" = true ]; then
                # Check if the moved item was a directory to mimic GNU rm -v output style
                # Note: $full_trashed_path is the new path, check its type
                if [ -d "$full_trashed_path" ]; then echo "rm (trash): moved directory '$item' -> '$full_trashed_path'";
                else echo "rm (trash): moved '$item' -> '$full_trashed_path'"; fi
            fi
        else
            echo "rm (trash): failed to move '$item' to trash directory '${trash_dir}'." >&2
            success_all=false
        fi
    done

    if [ "$success_all" = true ]; then return 0; else return 1; fi
}
alias rm='safe_rm_to_trash' # Override rm

# Function to empty the trash directory
emptytrash() {
    local trash_dir="${HOME}/.Trash"
    if [ ! -d "$trash_dir" ] || [ -z "$(ls -A "$trash_dir" 2>/dev/null)" ]; then # Check if dir is empty or non-existent
        echo "Trash directory '$trash_dir' is empty or does not exist."
        return 0
    fi

    echo "Contents of trash directory '$trash_dir':"
    command ls -lA "$trash_dir" # Use 'command ls' if 'ls' is aliased to something complex
    read -r "response?Are you sure you want to permanently delete all items in '$trash_dir'? [y/N] "
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Emptying trash: $trash_dir ..."
        # Use 'command rm' to call the original rm, not the alias.
        # The :? ensures trash_dir is set and not empty, crucial for 'rm -rf'.
        command rm -rf "${trash_dir:?}/"*
        if [ -z "$(ls -A "$trash_dir" 2>/dev/null)" ]; then echo "Trash emptied successfully.";
        else echo "Warning: Some items might not have been deleted from trash, or new items appeared." >&2; fi
    else
        echo "Trash not emptied."
    fi
}
alias cleartrash='emptytrash'

# =============================================================================
# ALIASES
# =============================================================================

# --- Navigation & Listing ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias lsg='ll | grep --color=auto -i'

# --- File & Directory Management (rm is now safe_rm_to_trash) ---
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'

# --- System & Info ---
alias dfh='df -h'
alias duh='du -sh'
alias dufh='du -sh * | sort -rh' # Sizes of items in current dir
alias freeh='free -h'
alias psef='ps -ef | grep --color=auto -i'
alias myip='curl -s ipinfo.io/ip || curl -s ifconfig.me'
alias update='sudo apt update && sudo apt upgrade -y' # Debian/Ubuntu. For Fedora: sudo dnf upgrade --refresh. For Arch: sudo pacman -Syu
alias cls='clear'; alias c='clear'
alias pingg='ping google.com'

# --- GPU Related (NVIDIA) ---
alias gpu='nvidia-smi'
alias gpumem='nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits'
alias gpuwatch='watch -n 1 nvidia-smi'

# --- Symbolic Links ---
alias sln='ln -s'
alias slnh='ln -s -T'

# --- Git ---
alias gcl='git clone'
alias ga='git add'; alias gaa='git add .'; alias gad='git add -A'
alias gc='git commit -m'; alias gca='git commit -a -m'
alias gco='git checkout'; alias gcb='git checkout -b'
alias gb='git branch'; alias gbd='git branch -d'; alias gbD='git branch -D'
alias gs='git status -sb'; alias gst='git status'
alias gd='git diff'; alias gds='git diff --staged'
alias gp='git push'
# gpush function is defined below, gpo can alias to it for convenience
alias gpl='git pull'; alias gplr='git pull --rebase'
alias glg='git log --oneline --graph --decorate --all'
alias glg_='git log --color --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gundo='git reset HEAD~'
alias gclean='git clean -fd'

if command -v gh &> /dev/null; then
    alias ghprc='gh pr create'; alias ghprl='gh pr list'; alias ghprv='gh pr view'; alias ghrepoweb='gh repo view --web'
fi

# --- Conda ---
alias ca='conda activate'; alias cdx='conda deactivate'
alias clse='conda env list'; alias cenv='conda env list'
alias cins='conda install'; alias cunins='conda uninstall'
alias ccreate='conda create -n'; alias csearch='conda search'
alias cupc='conda update conda'; alias cupall='conda update --all'
alias crmenv='conda env remove -n'

# --- Standard Python venv & uv ---
if command -v uv &> /dev/null; then
    alias uvv='uv venv'; alias uva='source .venv/bin/activate' # Adjust if venv name/path differs
    alias uvi='uv pip install'; alias uvu='uv pip uninstall'
    alias uvl='uv pip list'; alias uvf='uv pip freeze'
    alias uvsync='uv pip sync'; alias uvtree='uv pip tree'; alias uvcompile='uv pip compile'
fi

# --- Tmux (Terminal Multiplexer) ---
if command -v tmux &> /dev/null; then
    alias tl='tmux ls'
    alias ta='tmux attach-session -t'; alias tat='tmux attach-session -t' # ta <name>
    alias tn='tmux new-session -s' # tn <name>
    alias td='tmux detach-client' # Use INSIDE tmux
    alias tkill='tmux kill-session -t'; alias tkillsrv='tmux kill-server'
    # Aliases for use INSIDE a tmux session:
    alias tnw='tmux new-window -c "#{pane_current_path}"'
    alias trns='tmux rename-session'; alias trnw='tmux rename-window'
    alias tsph='tmux split-window -h -c "#{pane_current_path}"'
    alias tspv='tmux split-window -v -c "#{pane_current_path}"'
    alias tsnxt='tmux next-window'; alias tsprev='tmux previous-window'; alias tslw='tmux last-window'
    alias tkw='tmux kill-window'; alias tkp='tmux kill-pane'
fi

# =============================================================================
# FUNCTIONS
# =============================================================================

# --- Directory & File Operations ---
mkcd() { mkdir -p "$1" && cd "$1" || return 1; }

findf() { local search_dir=${2:-.}; find "$search_dir" -iname "*$1*"; }

grepdir() {
    local pattern="$1"; local file_glob="${2:-*}"; local search_dir="${3:-.}"
    if [ "$file_glob" = "*" ]; then grep -rIl --color=auto "$pattern" "$search_dir";
    else grep -rIl --color=auto --include="$file_glob" "$pattern" "$search_dir"; fi
}

backupfile() {
    if [ ! -e "$1" ]; then echo "Error: File or directory '$1' not found." >&2; return 1; fi
    local timestamp; timestamp=$(date +%Y%m%d_%H%M%S_%N) # Nanoseconds for uniqueness
    local backup_name="${1%/}_${timestamp}" # Remove trailing slash for dirs
    if [ -d "$1" ]; then
        tar -czf "${backup_name}.tar.gz" "$1" && echo "Directory backup created: ${backup_name}.tar.gz" || { echo "Backup failed for directory '$1'." >&2; return 1; }
    else
        cp "$1" "$backup_name" && echo "File backup created: $backup_name" || { echo "Backup failed for file '$1'." >&2; return 1; }
    fi
}

extract() {
    if [ ! -f "$1" ] ; then echo "'$1' is not a valid file." >&2; return 1; fi
    case "$1" in
        *.tar.bz2|*.tbz2) tar xvjf "$1" ;; *.tar.gz|*.tgz)   tar xvzf "$1" ;;
        *.tar.xz|*.txz)   tar xvJf "$1" ;; *.bz2)            bunzip2 "$1"  ;;
        *.rar)            unrar x "$1"  ;; *.gz)             gunzip "$1"   ;;
        *.tar)            tar xvf "$1"  ;; *.zip|*.jar)      unzip "$1"    ;;
        *.Z)              uncompress "$1";; *.7z)             7z x "$1"     ;;
        *) echo "Don't know how to extract '$1'..." >&2; return 1 ;;
    esac
}

# Lists N largest files or directories (by their total size) directly in the current directory.
# Usage: lsbig [N=10]
lsbig() {
    local num_items=${1:-10}
    # -maxdepth 1: current directory, -mindepth 1: exclude '.' itself
    # -print0 and xargs -0 handle spaces/special chars in names
    find . -maxdepth 1 -mindepth 1 -print0 | xargs -0 du -sh | sort -rh | head -n "$num_items"
}

lstree() {
    local depth="${1:-2}"; local target_dir="${2:-.}"
    if ! command -v tree &> /dev/null; then
        echo "'tree' command not found. Listing with 'find' (basic view):" >&2
        find "$target_dir" -maxdepth "$depth" -print # Basic fallback
        echo -e "\nFor a better hierarchical view, install 'tree' (e.g., sudo apt install tree)." >&2
        return 1
    fi
    tree -L "$depth" -aF "$target_dir" # -a for all files, -F for type indicators
}

# --- Git Functions ---
gac() { # Git Add All and Commit
    if [ -z "$1" ]; then echo "Error: Commit message is required for gac." >&2; return 1; fi
    git add -A && git commit -m "$1"
}

gpush() { # Git Push current or specified branch to origin
    local branch_name=${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}
    if [ -z "$branch_name" ]; then echo "Error: Not a git repository or no branch detected." >&2; return 1; fi
    git push origin "$branch_name"
}
alias gpo='gpush' # Alias gpo to the more flexible gpush function for convenience

# --- Networking & Proxy ---
setproxyhost() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "Usage: setproxyhost <host> <port> [user] [pass]" >&2; return 1; fi
    local proxy_address="$1:$2"; local auth_proxy_address=""
    # !!! IMPORTANT: REPLACE placeholder values with your ACTUAL proxy details !!!
    # E.g.: local user="proxy_user"; local pass="proxy_password"
    if [ -n "$3" ] && [ -n "$4" ]; then auth_proxy_address="$3:$4@$proxy_address";
    elif [ -n "$3" ]; then auth_proxy_address="$3@$proxy_address"; fi # Username only

    if [ -n "$auth_proxy_address" ]; then
        export http_proxy="http://$auth_proxy_address"; export https_proxy="http://$auth_proxy_address"; export ftp_proxy="http://$auth_proxy_address"
    else
        export http_proxy="http://$proxy_address"; export https_proxy="http://$proxy_address"; export ftp_proxy="http://$proxy_address"
    fi
    export HTTP_PROXY="$http_proxy"; export HTTPS_PROXY="$https_proxy"; export FTP_PROXY="$ftp_proxy"
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"; export NO_PROXY="$no_proxy" # Customize no_proxy
    echo "Proxy set to: $([ -n "$auth_proxy_address" ] && echo "$auth_proxy_address (auth)" || echo "$proxy_address")"
}

unsetproxy() {
    unset http_proxy https_proxy ftp_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY all_proxy ALL_PROXY no_proxy NO_PROXY
    echo "Proxy environment variables unset."
}

setsocks() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "Usage: setsocks <host> <port> [user] [pass]" >&2; return 1; fi
    local socks_address="$1:$2"; local auth_socks_address=""
    # !!! IMPORTANT: REPLACE placeholder values with your ACTUAL SOCKS proxy details !!!
    if [ -n "$3" ] && [ -n "$4" ]; then auth_socks_address="$3:$4@$socks_address";
    elif [ -n "$3" ]; then auth_socks_address="$3@$socks_address"; fi

    if [ -n "$auth_socks_address" ]; then export ALL_PROXY="socks5h://$auth_socks_address";
    else export ALL_PROXY="socks5h://$socks_address"; fi
    export all_proxy="$ALL_PROXY"; echo "SOCKS5 proxy set to: $ALL_PROXY"
}

unsetsocks() { unset ALL_PROXY all_proxy; echo "SOCKS5 proxy (ALL_PROXY) unset."; }

conn() { # Quick SSH
    if [ -z "$1" ]; then echo "Usage: conn <user@host_or_alias> or conn <host_or_alias>" >&2; return 1; fi
    if [[ "$1" == *"@"* ]]; then ssh "$1"; else ssh "$(whoami)@$1"; fi
}

# --- Software Installation & Management ---
get_anaconda() {
    local anaconda_url="https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh" # User-provided URL
    local installer_name; installer_name=$(basename "$anaconda_url")
    local download_dir="${1:-$HOME/Downloads/Installers}" # Default download directory

    echo "Anaconda Installer URL: $anaconda_url"
    echo "Note: This URL points to a specific version. For the latest, please check the Anaconda website."
    if [ ! -d "$download_dir" ]; then mkdir -p "$download_dir"; echo "Created download directory: $download_dir"; fi

    echo "Downloading Anaconda installer to $download_dir/$installer_name..."
    wget -P "$download_dir" "$anaconda_url"
    if [ -f "$download_dir/$installer_name" ]; then
        echo "Download complete: $download_dir/$installer_name"; chmod +x "$download_dir/$installer_name"
        echo "Installer made executable."
        echo -e "\nTo install Anaconda, run:\n  bash $download_dir/$installer_name"
        echo "Follow prompts. Consider NOT letting installer auto-modify .bashrc if you prefer manual setup."
    else echo "Error: Anaconda installer download failed." >&2; return 1; fi
}

# --- Python & Virtual Environment Management ---
mkcenv() { # Create Conda environment
    local env_name="$1"; if [ -z "$env_name" ]; then echo "Usage: mkcenv <env_name> [python_version] [package1 ...]" >&2; return 1; fi
    shift; local python_version="3.10" # Default Python version
    if [[ "$#" -gt 0 && "$1" =~ ^[0-9]+\.[0-9]+([0-9]+)?$ ]]; then python_version="$1"; shift; fi
    echo "Creating Conda environment: '$env_name' with Python $python_version"
    conda create -n "$env_name" python="$python_version" -y
    if [ $? -eq 0 ]; then
        # Note: Direct activation in scripts can be tricky. 'conda shell.bash hook' might be needed.
        echo "Conda environment '$env_name' created. Activate with: conda activate $env_name"
        if [ "$#" -gt 0 ]; then echo "Installing packages: $@"; conda install -n "$env_name" "$@" -y; fi
    else echo "Failed to create Conda environment '$env_name'." >&2; fi
}

mkstdvenv() { # Create standard Python venv
    local env_name="${1:-.venv}"; local activate_env=true
    if [ "$1" == "--no-activate" ]; then env_name=".venv"; activate_env=false;
    elif [ "$2" == "--no-activate" ]; then activate_env=false; fi
    if [ -d "$env_name" ]; then echo "Directory '$env_name' already exists.";
    else echo "Creating standard Python virtual environment '$env_name'..."; python3 -m venv "$env_name"; echo "Virtual environment '$env_name' created."; fi
    if [ "$activate_env" = true ] && [ -f "$env_name/bin/activate" ]; then source "$env_name/bin/activate"; echo "Activated virtual environment '$env_name'.";
    elif [ "$activate_env" = true ]; then echo "Could not find activate script for '$env_name'." >&2; fi
}

if command -v uv &> /dev/null; then
  mkuvenv() { # Create venv using uv
      local env_name="${1:-.venv}"; local activate_env=true
      if [ "$1" == "--no-activate" ]; then env_name=".venv"; activate_env=false;
      elif [ "$2" == "--no-activate" ]; then activate_env=false; fi
      if [ -d "$env_name" ]; then echo "Directory '$env_name' already exists.";
      else echo "Creating Python virtual environment '$env_name' using uv..."; uv venv "$env_name";
           if [ $? -ne 0 ]; then echo "Failed to create venv with uv." >&2; return 1; fi
           echo "Virtual environment '$env_name' created."; fi
      if [ "$activate_env" = true ] && [ -f "$env_name/bin/activate" ]; then source "$env_name/bin/activate"; echo "Activated virtual environment '$env_name'.";
      elif [ "$activate_env" = true ]; then echo "Could not find activate script for '$env_name'." >&2; fi
  }
  act() { # Activate Python venv (uv-aware, but general)
      local venv_path="$1"
      if [ -z "$venv_path" ]; then # Try common venv names if no arg
          if [ -f ".venv/bin/activate" ]; then venv_path=".venv";
          elif [ -f "venv/bin/activate" ]; then venv_path="venv";
          elif [ -f "env/bin/activate" ]; then venv_path="env";
          else echo "No virtual environment specified and common names (.venv, venv, env) not found." >&2; return 1; fi
      fi
      if [ -f "$venv_path/bin/activate" ]; then source "$venv_path/bin/activate"; echo "Activated virtual environment: $venv_path";
      else echo "Error: Activation script not found at '$venv_path/bin/activate'" >&2; return 1; fi
  }
fi

# --- Tmux (Terminal Multiplexer) ---
t() { # Comprehensive tmux session manager
    if ! command -v tmux &> /dev/null; then
        echo "tmux could not be found." >&2
        read -r "response?Do you want to try installing it? (e.g., sudo apt install tmux) [y/N] "
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            if command -v apt &>/dev/null; then sudo apt update && sudo apt install tmux -y;
            elif command -v dnf &>/dev/null; then sudo dnf install tmux -y;
            elif command -v yum &>/dev/null; then sudo yum install tmux -y;
            elif command -v pacman &>/dev/null; then sudo pacman -S tmux --noconfirm;
            elif command -v brew &>/dev/null; then brew install tmux;
            else echo "Package manager not recognized. Please install tmux manually." >&2; return 1; fi
            if ! command -v tmux &>/dev/null; then echo "Tmux installation failed or was not completed." >&2; return 1; fi
            echo "Tmux installed successfully. Please run the command 't' again."
        else echo "Please install tmux to use this command." >&2; return 1; fi; return 0
    fi

    local session_name="$1"
    if [ -n "$TMUX" ]; then # If already inside a tmux session
        if [ -z "$session_name" ]; then echo "Already inside tmux session: $TMUX_PANE. Use 'td' to detach."; return 0;
        else echo "Already inside tmux. To switch sessions, detach ('td') and re-attach, or use tmux keybindings (e.g. Ctrl-b s)." >&2; return 0; fi
    fi

    if [ -z "$session_name" ]; then # No session name provided (and not inside tmux)
        if tmux has-session 2>/dev/null; then
            local num_sessions; num_sessions=$(tmux ls 2>/dev/null | wc -l)
            if [ "$num_sessions" -eq 1 ]; then
                local only_session_name; only_session_name=$(tmux ls -F "#{session_name}" 2>/dev/null | head -n 1)
                echo "Attaching to the only existing session: $only_session_name"
                tmux attach-session # Attaches to the only session or last active
            else
                echo "Available tmux sessions:"
                tmux ls
                echo "To attach, use 't <session_name>', 'ta <session_name>', or 'tmux attach-session -t <session_name>'."
                echo "Attempting to attach to the last active session..."
                tmux attach-session # Attaches to last active by default
            fi
        else echo "No sessions running. Creating and attaching to a new session..."; tmux new-session; fi
    else # Session name provided (and not inside tmux)
        if tmux has-session -t "=$session_name" 2>/dev/null; then # Check if session exists (exact match)
            echo "Attaching to existing tmux session: $session_name"; tmux attach-session -t "$session_name";
        else echo "Creating and attaching to new tmux session: $session_name"; tmux new-session -s "$session_name"; fi
    fi
}

# --- Nvitop (NVIDIA GPU Monitoring) ---
nvt() { # Run nvitop, prompting for install if not found
    if ! command -v nvitop &> /dev/null; then
        echo "nvitop could not be found." >&2
        read -r "response?Do you want to try installing it? (e.g., pip install nvitop) [y/N] "
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            if command -v pip3 &>/dev/null; then pip3 install nvitop;
            elif command -v pip &>/dev/null; then pip install nvitop;
            else echo "pip (or pip3) could not be found. Please install nvitop manually." >&2; return 1; fi
            if ! command -v nvitop &>/dev/null; then echo "Nvitop installation failed or was not completed. Please ensure it's in your PATH." >&2; return 1; fi
            echo "Nvitop installed successfully. Please run the command 'nvt' again."
        else echo "Please install nvitop to use this command." >&2; return 1; fi; return 0
    fi
    nvitop "$@" # Execute nvitop with any arguments passed
}
