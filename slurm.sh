# added to .bashrc or .zshrc

# slurm-related config and aliases
export SINFO_FORMAT='%n %.8O %.12P %.11T %.4c %.8z %.6m %.6w %10E %15R %G'
export SQUEUE_FORMAT='%.7i %.8u %.30j %.12P %.11T %.10M %.7C %.7m %.10R %b %l'
export SACCT_FORMAT="JobID%20,JobName,User,Partition,NodeList,Elapsed,State,ExitCode,MaxRSS,AllocTRES%32"

alias nlpqueue='squeue -p nlplab,nlplab-core,bhuwan,wiseman -o "%7i %8u %30j %.12P %.11T %10M %.7C %.7m %10R %b"'

# Define a constant for the common SLURM arguments
INTERACTIVE_SLURM_ARG="--nodes=1 --ntasks-per-node=1 --mem=30G -t 3:00:00 --pty bash -i"

function islurm() {
    # Default values
    partition="compsci-gpu"
    gpu_model=""

    # Parse options
    while getopts ":p:g:h" opt; do
        case $opt in
            p)
                partition="$OPTARG"
                ;;
            g)
                gpu_model="$OPTARG"
                ;;
            h)
                echo "Usage: islurm -p <partition> -g <gpu_model>"
                echo "Available gpu models: A5000, A6000, v100, 2080rtx, etc., default: random"
                echo "Available partitions: compsci-gpu, nlplab, nlplab-core, default: compsci-gpu"
                return 0
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                return 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done

    # Set GPU resource argument
    if [ -z "$gpu_model" ]; then
        echo "Using random gpu model"
        gpu_arg="--gres=gpu:1"
    else
        gpu_arg="--gres=gpu:$gpu_model:1"
    fi

    # Execute srun with appropriate settings
    if [ "$partition" = "compsci-gpu" ]; then
        eval "set -- $INTERACTIVE_SLURM_ARG"
        srun --partition="$partition" $gpu_arg "$@"
    else
        eval "set -- $INTERACTIVE_SLURM_ARG"
        srun --partition="$partition" --account="$partition" $gpu_arg "$@"
    fi
}
