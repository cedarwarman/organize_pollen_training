# Introduction ------------------------------------------------------------
# This script will randomly select images from the larger dataset (as of
# 2022-05-23) then create bash code to copy them to a new directory for 
# uploading.

library(tidyverse)
library(googlesheets4)

# Adding my Google service account credentials
gs4_auth(path = "~/.credentials/google_sheets_api/service_account.json")

# Here's how I did it for Xander, base it off this:

# # Getting the image names -------------------------------------------------
# shortest_pistils <- c("CW0081", "CW0054", "CW0042", "CW0041")
# longest_pistils <- c("CW0060", "CW0056", "CW0065", "CW0064")
# 
# chosen_accession_ids <- c(shortest_pistils, longest_pistils)
# 
# # None of the images are named after their accession, just the wells. The 
# # required information to link well to accession can be found in this sheet:
# wells_to_accessions <- read_sheet("1yQ5yAKiL6BzwZ-wH-Q44RoUEwMZztTYafzdvVylq6fo")
# 
# # Selecting only rows for the chosen accessions
# wells_to_accessions <- wells_to_accessions[wells_to_accessions$accession %in% chosen_accession_ids, ]
# 
# # Only keeping the columns we need
# wells_to_accessions <- wells_to_accessions[ , c("date", "run", "well", "temp_target", "accession")]
# 
# # Also I need to pull in which wells are a good density
# wells_with_good_density <- read_sheet("10_lG9N0wGvgOmxDGuX5PXILB7QwC7m6CuYXzi78Qe3Q")
# 
# # Combining
# file_names <- left_join(wells_to_accessions, wells_with_good_density, by = c("date", "run", "well"))
# 
# # Only keeping the good ones
# file_names <- file_names[file_names$count == "g", ]
# file_names <- file_names[ , 1:5]
# 
# # Selecting 8 random rows per accession/temp (seed makes it reproducible)
# set.seed(13)
# file_names <- file_names %>%
#   group_by(accession, temp_target) %>%
#   slice_sample(n = 8)
# 
# # We're using the 81st frame (starts at 0 so it's 80) from each image 
# # (~2 hours). We'll measure tube lengths from the control temp and bursting 
# # from both temps. 
# 
# # 2022-03-31 note: Now we're trying it 1/3 of the way through the sequence to 
# # try to capture tube lengths without bursting at 26 & 34. 
# file_names$string <- paste0(file_names$date,
#                             "_run",
#                             file_names$run,
#                             "_",
#                             file_names$temp_target,
#                             "C/well_",
#                             file_names$well,
#                             "/",
#                             file_names$date,
#                             "_run",
#                             file_names$run,
#                             "_",
#                             file_names$temp_target,
#                             "C_",
#                             file_names$well,
#                             "_t027.tif")
# 
# file_names$short_filename <- paste0(file_names$date,
#                                     "_run",
#                                     file_names$run,
#                                     "_",
#                                     file_names$temp_target,
#                                     "C_",
#                                     file_names$well,
#                                     "_t027")
# 
# 
# # Saving the key
# write.table(file_names[ , c("short_filename", "accession")],
#             file = file.path(getwd(), "data", "image_key_t027.txt"),
#             row.names = F,
#             col.names = F,
#             quote = F)
# 
# # file_names <- file_names[ , c("string", "accession")]
# 
# # Writing out the file names for the bash script to copy the images to a 
# # single directory
# write.table(file_names$string,
#             file = file.path(getwd(), "data", "image_paths_t027.txt"),
#             row.names = F,
#             col.names = F,
#             quote = F)
# 
# # The bash command (from /xdisk/rpalaniv/cedar/image_processing/processed_tifs)
# # is:
# # cat ~/scratch/image_paths_t027.txt | xargs -I % cp % ~/scratch/xander_pics_t027