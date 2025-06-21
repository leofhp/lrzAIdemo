#!/bin/bash
#SBATCH -p lrz-cpu
#SBATCH --qos=cpu
#SBATCH --nodelist=cpu-002
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --time=2-00:00:00
#SBATCH --job-name=demo1
#SBATCH --output=lrzAIdemo/slurm/slurm-%j.out
#SBATCH --error=lrzAIdemo/slurm/slurm-%j.err

# Return to the directory from which sbatch was invoked
cd "$SLURM_SUBMIT_DIR"

# Run the demo script
python lrzAIdemo/demo_py.py