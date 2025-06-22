# Demo: LRZ AI Systems Batch Jobs

This repository demonstrates how to run batch jobs on the [LRZ AI Systems](https://doku.lrz.de/lrz-ai-systems-11484278.html), with an add-on section for executing R batch jobs using custom container images.

## Getting started

### Prerequisites

To run batch jobs on the LRZ AI Systems, you need:
- A valid LRZ account with access to the LRZ AI Systems.
- A connection to the Munich Scientific Network (MWN).

If you don’t yet have access, refer to the official ["Access and Getting Started" guide](https://doku.lrz.de/3-access-and-getting-started-10746642.html). 

> **Recommended setup:** Use VS Code for its SSH and Git integration. However, you may use any IDE or terminal-based workflow you prefer.

### Connecting to LRZ

Log in to the LRZ AI Systems and enter your password when prompted:

- **Via terminal:**

    ```bash
    ssh login.ai.lrz.de -l <YOUR-LRZ-ACCOUNT>
    ```

- **Via VS Code (recommended for ease of use):**  
  With the [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh), open the command palette and choose:  
  **"Connect to Host..." → `login.ai.lrz.de`**

Optionally, clone this repository to follow along step by step:

```bash
git clone https://github.com/leofhp/lrzAIdemo.git
```

Alternatively, you can follow the instructions independently and adjust paths and filenames as needed.

---

## Running a Batch Job

A SLURM batch job is specified through a script like `demo_py.sbatch`, which might look as follows:

```bash
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

cd "$SLURM_SUBMIT_DIR"
python lrzAIdemo/demo_py.py
```

### Explanation of Key Directives

- `-p lrz-cpu`: Selects the CPU-only partition. For GPU jobs, see the available partitions in [this guide](https://doku.lrz.de/1-general-description-and-resources-10746641.html).
- `--qos=cpu`: Specifies the Quality of Service level, which is required on LRZ. For CPU jobs, use `cpu`.
- `--nodelist`: Specifies a specific node (optional).
    - As of June 2025, the `lrz-cpu` partition includes:
        - `cpu-001` -- `cpu-006`: Intel Xeon Gold 6148
        - `cpu-007`: Intel Xeon E7-4850
        - `cpu-008` -- `cpu-012`: AMD EPYC 7642
    - To check node availability, you can either run:

    ```bash
    sinfo -Nel -p lrz-cpu
    ```

    or use the included helper script `lrz_cpu_availability.sh` for a structured overview of available cores and free memory per node:

    ```bash
    lrzAIdemo/lrz_cpu_availability.sh
    ```
    - Avoid `cpu-007` for compute-intensive jobs -- it tends to be significantly slower.
- `--cpus-per-task=1`: Requests one CPU core. Increase this only if your script is parallelized.
- `--mem=8G`: Allocates 8 GB of RAM.
- `--time=2-00:00:00`: Sets the maximum runtime to 2 days. There's no harm in requesting the full 2-day limit.
- `--job-name=demo_job`: Assigns a name to your job for easier tracking.
- `--output` and `--error`: Define separate log files for standard output and errors. Change these paths if you didn't clone the repository.

### Submitting the job

To submit the job:

```bash
sbatch lrzAIdemo/demo_py.sbatch
```

Monitor it with:

```bash
squeue -u $USER
```

This shows:
- Job ID
- Partition name
- Job name
- Your LRZ account name
- Job state ([see list of states](https://slurm.schedmd.com/squeue.html#lbAG))
- Runtime and node assignment

### Viewing Logs

If you used the example `demo_py.py` script, the output file (e.g. `slurm/slurm-123456.out`) will show:

- Time remaining
- Current memory usage
- Iteration info

You can monitor the output live using:

```bash
tail -f lrzAIdemo/slurm/slurm-<JOBID>.out
```

---

## Running R Batch Jobs Using Containers

Unlike Python, **R is not pre-installed** on the LRZ AI Systems. However, you can easily run R scripts using containers based on images from the [Rocker project](https://hub.docker.com/r/rocker/). This section walks through:

- Creating a container with R and required packages.
- Running an R batch job using that container.

> For background and advanced usage, see the [official guide](https://doku.lrz.de/11-0-managing-r-packages-in-a-containerized-environment-17826524.html).

### Step 1: Create a Custom Container with R

Create a folder to store your container images:

```bash
mkdir -p ~/lrzAIdemo/containers
cd ~/lrzAIdemo/containers
```

Start an interactive session on a CPU node:

```bash
srun -p lrz-cpu -q cpu --mem=32G --pty bash
```

Import a Rocker container image. The ml-verse variant includes common data science packages and is recommended. Note that these images are large (> 6 GB) and importing them will take several minutes:

```bash
enroot import docker://rocker/ml-verse:latest
```

Create and start the container:

```bash
enroot create --name r-custom rocker+ml-verse+latest.sqsh
enroot start r-custom bash
```

Start R inside the container and install any additional packages:

```bash
R
> install.packages(c("CICI", "this.path")) # Replace with your actual requirements
> q()
```

Exit the container and export the modified image, which will take several minutes:

```bash
exit
enroot export --output r-custom-final.sqsh r-custom
```

This will save the finalized container as `r-custom-final.sqsh` in your `containers` folder.

Leave the interactive session and return to your home directory:

```bash
exit
cd
```

### Step 2: Run an R Batch Job with Your Container

You can now run R scripts using the customized container. In your batch script (e.g. `demo_r.sbatch`), specify the image using `--container-image`:

```bash
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
#SBATCH --container-image=<YOUR-ABSOLUTE-PATH>/lrzAIdemo/containers/r-custom-final.sqsh

cd "$SLURM_SUBMIT_DIR"
Rscript lrzAIdemo/demo_r.R
```

This script will:

- Run `demo_r.R` using 4 CPU cores.
- Log output and error messages to the `slurm` directory.
- Write results to `demo_r_results/results.csv`.

Submit the job as usual:

```bash
sbatch lrzAIdemo/demo_r.sbatch
```

Monitor it using:

```bash
squeue -u $USER
```

--- 

## Additional Resources

- [LRZ AI Systems documentation](https://doku.lrz.de/lrz-ai-systems-11484278.html), including:
    - [Running Applications as Batch Jobs](https://doku.lrz.de/7-running-applications-as-batch-jobs-on-the-lrz-ai-systems-10746643.html)
    - [Managing R Packages in a Containerized Environment](https://doku.lrz.de/11-0-managing-r-packages-in-a-containerized-environment-17826524.html)