#!/bin/bash
#SBATCH -p lrz-cpu
#SBATCH --qos=cpu
#SBATCH --nodelist=cpu-003
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=2-00:00:00
#SBATCH --job-name=demo2
#SBATCH --output=lrzAIdemo/slurm/slurm-%j.out
#SBATCH --error=lrzAIdemo/slurm/slurm-%j.err

# Define the container path
CONTAINER_PATH="$SLURM_SUBMIT_DIR/lrzAIdemo/containers/r-custom-final.sqsh"

# Return to the directory from which sbatch was invoked
cd "$SLURM_SUBMIT_DIR"

# Log memory usage of R processes every 10 seconds
JOB_ID=${SLURM_JOB_ID}
MEMLOG="lrzAIdemo/slurm/slurm-${JOB_ID}.txt"
(
  while true; do
    timestamp=$(date)
    ps -C R,Rscript -o rss=,vsz= --no-headers | \
    awk -v ts="$timestamp" '
      { rss += $1; vsz += $2 }
      END {
        rss_mib = rss / 1024;
        vsz_mib = vsz / 1024;
        printf "%s | Total RSS: %.1f MiB | Total VSZ: %.1f MiB\n", ts, rss_mib, vsz_mib;
      }
    '
    sleep 10
  done
) >> "$MEMLOG" 2>&1 &

# Run the R script inside the container
srun --container-image="$CONTAINER_PATH" \
     --container-mounts="$SLURM_SUBMIT_DIR:$SLURM_SUBMIT_DIR" \
     bash -c "cd $SLURM_SUBMIT_DIR && Rscript lrzAIdemo/demo_r.R"