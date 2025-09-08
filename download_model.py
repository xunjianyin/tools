#!/usr/bin/env python3
"""
Download a HuggingFace model to a clean local directory.
"""

from huggingface_hub import snapshot_download
import os


model_name = "Qwen/Qwen3-0.6B"
local_dir = f"/hpc/group/szhoulab/pretrain/{model_name}"

def download_model_to_local(model_name: str, local_dir: str):
    """
    Download a HuggingFace model to a clean local directory.
    
    Args:
        model_name: HuggingFace model name (e.g., "Qwen/Qwen3-0.6B")
        local_dir: Local directory to save the model
    """
    print(f"Downloading {model_name} to {local_dir}...")
    
    # Create directory if it doesn't exist
    os.makedirs(local_dir, exist_ok=True)
    
    # Download to local directory (not cache)
    snapshot_download(
        repo_id=model_name,
        local_dir=local_dir,
        local_dir_use_symlinks=False,  # This prevents symlinks to cache
        resume_download=True
    )
    
    print(f"Model downloaded successfully to {local_dir}")
    print(f"You can now use: {local_dir}")

if __name__ == "__main__":
    download_model_to_local(model_name, local_dir)
