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

# Only keeping ones older than 2022-05-23 because the camera switched
file_names <- file_names[file_names$date < "2022-05-23", ]

file_names <- file_names[ , 1:5]

# This is the path of the base directory that the jpgs are in
base_dir_path <- "/xdisk/rpalaniv/cedar/image_processing/stabilized_jpgs/"

file_names$string <- paste0(base_dir_path,
                            file_names$date,
                            "_run",
                            file_names$run,
                            "_",
                            file_names$temp_target,
                            "C_stab/well_",
                            file_names$well)


# Saving ------------------------------------------------------------------
write.table(file_names[ , c("string")],
            file = file.path(getwd(), "data", "inference_dirs_2022-12-26.txt"),
            row.names = F,
            col.names = F,
            quote = F)


# There are 3338 image sequences total
