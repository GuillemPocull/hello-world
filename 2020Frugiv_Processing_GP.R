#script to process 2020 frugivory interaction data
library(plyr)
library(tidyverse)
library(readr)

raw <- read_csv("Raw/2020FrugivRob_RAW_GP.csv")
str(raw)

# new column created for presence/absence of larvae I
raw$presence_larvae_I <- ifelse(raw$num_larvae_I >= 1, 1, 0)

# Correct or delete wrong rows 
raw <- raw[-c(113, 1000),]
raw[raw$ID=="pA00835", "ID"] <- "pA0835"


################
#INTERACTION DATA (this dataset only includes interaction data; all covariates are in the general Trimble data from 2020)
################
#renames columns to match the standard format (new name = old name)
format_int <- raw %>% dplyr::rename(plant.id.field == ID, presence = presence_larvae_I, count = num_larvae_I)

#adds columns to match the standard format. year is a character because it will just be used as a factor. Some columns don't apply for this datset, so they are NA. This step will be unique for each dataset.
format_int <- format_int %>% add_column(dataset.id = 'frugiv_2020', interaction = "frugiv", year = "2020", date = NA, survey.id = NA, inflor.id = NA, inflor.tot.fl = NA, inflor.tot.fr = NA, flower.pos = "top")

#re-order formatted dataset to stardard. This line should be in every processing script; if there's a problem, the formatting isn't correct.
format_int <- format_int[c("dataset.id","interaction","year","date","plant.id.field","survey.id","inflor.id","inflor.tot.fl","inflor.tot.fr","flower.pos","presence","count")]

#save the formatted dataset
write.csv(format_int, "Processing/2020Frugiv_Interaction_Formatted.csv", row.names = FALSE)

#clear the environment so the next script doesn't use anything from here
rm(list=ls())
