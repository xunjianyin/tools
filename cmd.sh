srun -p gpu-common --gres=gpu:1 --pty bash -i

tmux new -s my_slurm_session
srun --job-name=interactive_session --cpus-per-task=4 --mem=16G --time=30-00:00:00 --pty bash
