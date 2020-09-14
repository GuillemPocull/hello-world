#script to process 2019 nectar robbing interaction data

library(plyr)
library(tidyverse)
library(readr)

raw <- read_csv("Raw/2019RobFlorivFrugiv_RAW_LS.csv")
str(raw)

# Check for differences of format in 'ID'
check_differences <- grepl("Z", raw$plant_ID, ignore.case = FALSE, perl = FALSE,
                           fixed = FALSE, useBytes = FALSE)

table(check_differences) # If there is a wrong string, the table will show FALSE = 'number of wrong strings'

# Check for wrong values in numeric variables
summary(raw)

##################
#INTERACTION DATA
##################
#renames columns to match the standard format (new name = old name)
format_int <- raw %>% dplyr::rename(plant.id.field = plant_ID, presence = base, date = sampling_date, inflor.tot.fl = focal_flowers, inflor.tot.fr = focal_fruit, flower.pos = flower_ID)

#adds columns to match the standard format. year is a character because it will just be used as a factor. Some columns don't apply for this datset, so they are NA. This step will be unique for each dataset.
format_int <- format_int %>% add_column(dataset.id = "rob_2019", interaction = "rob", year = "2019", survey.id = NA, inflor.id = NA, count = NA)

#re-order formatted dataset to stardard. This line should be in every processing script; if there's a problem, the formatting isn't correct.
format_int <- format_int[c("dataset.id","interaction","year","date","plant.id.field","survey.id","inflor.id" ,"inflor.tot.fl" ,"inflor.tot.fr","flower.pos","presence","count")]

#save the formatted dataset
write.csv(format_int, "Processing/2019Rob_Interaction_Formatted.csv", row.names = FALSE)

#clear the environment so the next script doesn't use anything from here
rm(list=ls())
