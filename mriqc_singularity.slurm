#!/bin/bash
#SBATCH --partition=batch
#SBATCH --cpus-per-task=4
#SBATCH --job-name=mriqc
#SBATCH --chdir=/mnt/beegfs/home/ilkay.isik/mri_data/lscp_data/derivatives/mriqc
#SBATCH --output=mriqc-%A-%a.out
#SBATCH --array=1-26
#SBATCH --nodelist=cn1-hpc

subj=$(printf "%02d" ${SLURM_ARRAY_TASK_ID})

singularity run /mnt/beegfs/singularity_images/mriqc/mriqc-0.14.2.simg \
	/mnt/beegfs/home/ilkay.isik/mri_data/lscp_data/bids \
	/mnt/beegfs/home/ilkay.isik/mri_data/lscp_data/derivatives/mriqc \
	participant --participant_label $subj
