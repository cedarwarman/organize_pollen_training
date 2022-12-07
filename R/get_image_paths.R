# Introduction ------------------------------------------------------------
# This script will randomly select images from the larger dataset (as of
# 2022-05-23) then create bash code to copy them to a new directory for 
# uploading.

library(dplyr)
library(googlesheets4)

# Makes the random selections reproducible
set.seed(13)

# Adding my Google service account credentials
gs4_auth(path = "~/.credentials/google_sheets_api/service_account.json")


# Getting all the image paths ---------------------------------------------
# None of the images are named after their accession, just the wells. The
# required information to link well to accession can be found in this sheet:
wells_to_accessions <- read_sheet("1yQ5yAKiL6BzwZ-wH-Q44RoUEwMZztTYafzdvVylq6fo")

# Only keeping the columns we need
wells_to_accessions <- wells_to_accessions[ , c("date", "run", "well", "temp_target", "accession")]

# Also I need to pull in which wells are a good density
wells_with_good_density <- read_sheet("10_lG9N0wGvgOmxDGuX5PXILB7QwC7m6CuYXzi78Qe3Q")

# Combining
file_names <- left_join(wells_to_accessions, wells_with_good_density, by = c("date", "run", "well"))

# Only keeping the good ones
file_names <- file_names[complete.cases(file_names), ]
file_names <- file_names[file_names$count == "g", ]

# Only keeping ones older that 2022-05-23 to match the first set
file_names <- file_names[file_names$date < "2022-05-23", ]

file_names <- file_names[ , 1:5]

# Now I need to make rows for each image sequence frame. The vast majority 
# were 83 frames so I'll go with that. Will probably run into some problems 
# with edge cases.

file_names <- file_names[rep(seq_len(nrow(file_names)), each = 83), ]
  
file_names$frame_num <- rep(seq(0, 82), times = nrow(file_names) / 83)

file_names$frame_num <- sprintf("%03d", file_names$frame_num) 

# This is the path of the base directory that the jpgs are in
base_dir_path <- "/xdisk/rpalaniv/cedar/image_processing/stabilized_jpgs/"

file_names$string <- paste0(base_dir_path,
                            file_names$date,
                            "_run",
                            file_names$run,
                            "_",
                            file_names$temp_target,
                            "C_stab/well_",
                            file_names$well,
                            "/",
                            file_names$date,
                            "_run",
                            file_names$run,
                            "_",
                            file_names$temp_target,
                            "C_",
                            file_names$well,
                            "_t",
                            file_names$frame_num,
                            "_stab.jpg")


# Subsetting and saving ---------------------------------------------------
# Getting a random order
random_vec <- sample(nrow(file_names))

# Pulling out lists of 400 random images for each upload
upload_1 <- file_names[random_vec[1:400], ]

# Writing out the first couple tables (we probably won't need that many)
write.table(upload_1[ , c("string")],
            file = file.path(getwd(), "data", "upload_1.txt"),
            row.names = F,
            col.names = F,
            quote = F)

upload_2 <- file_names[random_vec[401:800], ]

write.table(upload_2[ , c("string")],
            file = file.path(getwd(), "data", "upload_2.txt"),
            row.names = F,
            col.names = F,
            quote = F)

# The bash command to copy them is:
# cat ~/scratch/upload_1.txt | xargs -I % cp % ~/scratch/upload_1


# Data leakage ------------------------------------------------------------
# Oops, I forgot about data leakage. If the training images are very similar 
# to the validation images (e.g. they come from the same time-series) then 
# they're not a very good control. I will look here to see if there are any
# time-series that I didn't use yet for training. If there are any, I will 
# set them aside for validation. Or also I could split the existing ones to 
# make sure the validation ones are used in the training. Or if I already 
# used them all I can rank them and set aside the ones with the fewest 
# annotated.

# First, checking to see which time-series were not part of the first training 
# set (upload_1). OK I think this is working properly, this says that there are 
# still 2965 wells that have no time points in the training set.
not_part_of_upload_1 <- anti_join(distinct(file_names[ , 1:5]), distinct(upload_1[ , 1:5]))

# Next, in the current training set (upload_1), which wells have multiple time 
# points and could theoretically end up in both the training and validation 
# splits.
400 - nrow(distinct(upload_1[ , 1:5])) 

# Looks like 27 of the images are not from a well with only 1 time point in the 
# set. I could write the Python program to ignore these images. Also, if there's
# 3338 wells total, I could in the future just only use unique wells and still 
# label thousands and have thousands for testing and not have leakage from images
# in the same sequence. Are there any other sources of leakage?
