#!/usr/bin/env bash

# This script converts tifs to jpgs. It works in a nested directory structure
# where microscope runs are separated into 24 directories, one for each well 
# in a 24-well plate. The script is run by a slurm array that navigates to a 
# directory and runs the script inside. It then saves the processed images to
# the following hard-coded location:

# output_dir='/xdisk/rpalaniv/cedar/image_processing/stabilized_jpgs'
output_dir='/xdisk/rpalaniv/cedar/image_processing/normalized_stabilized_jpgs'

# Getting the image sequence basename
sequence_name=${PWD##*/}
sequence_name=${sequence_name%_normalized_stabilized}

echo "THIS IS THE BASH SCRIPT"
echo $1

mkdir /xdisk/rpalaniv/cedar/image_processing/normalized_stabilized_jpgs/${1}

for well in well_*; do
    printf "\nProcessing ${well}\n"
	output_well_dir=${output_dir}/${1}/${well}
    mkdir ${output_well_dir}
    cd ${well}

	# Converting the images
	for image in *.tif; do
		# IMAGEMAGICK COMMAND (with path of new location)
		# echo ${image}
		convert ${image} -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace Gray ${output_well_dir}/${image%.*}.jpg
	done

    cd ..
done
