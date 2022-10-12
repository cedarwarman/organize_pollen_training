#!/usr/bin/env bash
#SBATCH --job-name=compress_jpgs
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH --time=12:00:00
#SBATCH --account=rpalaniv
#SBATCH --partition=standard
#SBATCH --output=%x_%A_%a.out
#SBATCH --error=%x_%A_%a.err

tar -czvf /xdisk/rpalaniv/cedar/image_processing/temp/all_stab_jpgs.tar.gz /xdisk/rpalaniv/cedar/image_processing/stabilized_jpgs

