#script to process 2020 nectar robbing interaction data
install.packages("plyr")
install.packages("tidyverse")
install.packages("readr")


library(plyr)
library(tidyverse)
library(readr)

raw <- read_csv("Raw/2020FruitHole_RAW_GP.csv")
str(raw)

# Create processing columns
raw <- raw[!(is.na(raw$Holes)),]
raw$success <- ifelse(raw$Holes == raw$presence_indirect,1,0)
raw$false_positive <- ifelse(raw$Holes == 1 & raw$presence_indirect == 0, 1, 0)
raw$false_negative <- ifelse(raw$Holes == 0 & raw$presence_indirect == 1, 1, 0)
raw$equal_ID <- as.numeric(c(NA, raw$Envelope_ID[-1] == raw$Envelope_ID[-nrow(raw)])) # This columns type 1 if two contiguous rows have the same ID.
raw$equal_ID[1] <- "0" 
raw$human_error <- ifelse(raw$equal_ID == raw$Holes, 0, 1)
raw$human_error[c(44,141)] <- "0" # These are special rows that are currently correct.

# Check for wrong values in numeric variables
summary(raw)

##################
#INTERACTION DATA
##################
#renames columns to match the standard format (new name = old name)
format_int <- raw %>% dplyr::rename(envelope.id.field = Envelope_ID, pres.holes = Holes, pres.larvae = Larvae_weevil, pres.indirect = presence_indirect,
                                    false.positive = false_positive, false.negative = false_negative, error = human_error)

#adds columns to match the standard format. year is a character because it will just be used as a factor. Some columns don't apply for this datset, so they are NA. This step will be unique for each dataset.
format_int <- format_int %>% add_column(dataset.id = "seed.pred.env_2020", date = NA, interaction = "seed.pred", year = "2020", survey.id = NA)

#re-order formatted dataset to stardard. This line should be in every processing script; if there's a problem, the formatting isn't correct.
format_int <- format_int[c("dataset.id","interaction","year","date","envelope.id.field","survey.id","pres.holes","pres.larvae", "pres.indirect",
                           "false.positive", "false.negative", "error")]

#save the formatted dataset
write.csv(format_int, "Processing/2020SeedPredEnv_Cov_Formatted.csv", row.names = FALSE)

#clear the environment so the next script doesn't use anything from here
rm(list=ls())