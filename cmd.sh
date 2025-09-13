srun -p gpu-common --gres=gpu:1 --pty bash -i

tmux new -s my_slurm_session
srun --partition=compsci --job-name=interactive_compsci --cpus-per-task=4 --mem=16G --time=7-00:00:00 --pty bash

squeue -u xy200
