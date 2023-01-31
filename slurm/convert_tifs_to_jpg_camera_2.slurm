#!/usr/bin/env bash
#SBATCH --job-name=tif_to_jpg
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=500mb
#SBATCH --time=0:20:00
#SBATCH --account=rpalaniv
#SBATCH --partition=standard
#SBATCH --array=1-249%200
#SBATCH --output=%x_%A_%a.out
#SBATCH --error=%x_%A_%a.err

# Setting nullglob so that globs that match nothing don't make errors
shopt -s nullglob

# Moving to the processed images directory
cd /xdisk/rpalaniv/cedar/image_processing/normalized_stabilized/

# Setting up the array
image_sequence=$(find . -maxdepth 1 -name '*run*' | sed -n ${SLURM_ARRAY_TASK_ID}p)

# Making sure it's not blank
if [ ${image_sequence} = "" ]
then
	echo "Image sequence is blank, exiting"
	exit 1
fi

# Deletes "./"
image_sequence=${image_sequence:2}

# Looping through the image sequence folder
printf "Image sequence variable is: ${image_sequence}\n"
cd ./${image_sequence}
printf "Present working directory is: ${PWD}\n"
# Getting the image sequence basename
sequence_name=${PWD##%*/}
printf "\nProcessing ${sequence_name}\n"

# Converts tif to jpg
printf "Converting\n"
MAGICK_THREAD_LIMIT=1
bash /home/u16/cedar/git/organize_pollen_training/bash/convert_tif_to_jpg_camera_2.sh ${image_sequence}

# Cleaning up
shopt -u nullglob

