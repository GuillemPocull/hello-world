#script to process 2020 seed predation interaction data
library(plyr)
library(tidyverse)
library(readr)

raw <- read_csv("Raw/2020Frugiv_RAW_GP.csv",col_types = cols(hole_robbing = col_character()))
str(raw)

# new column created for presence/absence of larvae I
raw$presence_larvae_I <- ifelse(raw$num_larvae_I >= 1, 1, 0)

###first subset and format the "interaction" data (and in this case convert proportion to binary). Then subset and format the "individual-level" covariate data (size stuff).

################
#INTERACTION DATA
################

#unique for this dataset, we need to convert number of fruits with holes out of total fruits to 0/1 observation for individual fruits
#helpful code from GitHub user aosmith16 https://aosmith.rbind.io/2019/10/04/expanding-binomial-to-binary/
binary_dat <- raw

#renames columns to match the standard format (new name = old name)
format_int <- binary_dat %>% dplyr::rename(plant.id.field = ID, presence = presence_larvae_I, count = num_larvae_I)

#adds columns to match the standard format. year is a character because it will just be used as a factor. Some columns don't apply for this datset, so they are NA. This step will be unique for each dataset.
format_int <- format_int %>% add_column(dataset.id = "frugiv.larvae.I_2020", interaction = "frugiv", year = "2020", date = NA, survey.id = NA, inflor.id = NA, inflor.tot.fl = NA, inflor.tot.fr = NA, flower.pos = NA)

#re-order formatted dataset to stardard. This line should be in every processing script; if there's a problem, the formatting isn't correct.
format_int <- format_int[c("dataset.id","interaction","year","date","plant.id.field","survey.id","inflor.id","inflor.tot.fl","inflor.tot.fr","flower.pos","presence","count")]

#save the formatted dataset
write.csv(format_int, "Processing/2020FrugivLarvaeI_Interaction_Formatted.csv", row.names = FALSE)

################
#COVARIATE DATA
################

#Each dataset has its own individual-level covariates (plant size and display size) that were recorded in the field at the same time the interaction was observed. These are different than size and flower color data from AntSpec.

#get the sum of the three stages that were counted per focal stem
format_cov <- ddply(raw, c("plant.id","whole.plant.additional.flowers","whole.plant.additional.mature.fr","height_cm"), summarise, 
                    focal.fl = sum(focal.stem.flowers),
                    focal.mature.fr = sum(focal.stem.mature.fr),
                    focal.med.fr = sum(focal.stem.med.fr)
)
#number of rows should equal unique individuals
nrow(format_cov) == length(unique(raw$plant.id))

#now add up all fruits and flowers
format_cov <- format_cov %>% mutate(tot.fl.field = focal.fl + whole.plant.additional.flowers, tot.fr.field = focal.mature.fr + focal.med.fr + whole.plant.additional.mature.fr) 
#renames columns to match the standard format (new name = old name)
format_cov <- format_cov %>% dplyr::rename(height.field = height_cm, plant.id.field = plant.id)

#adds columns to match the standard format. year is a character because it will just be used as a factor. Some columns don't apply for this datset, so they are NA. This step will be unique for each dataset.
format_cov <- format_cov %>% add_column(dataset.id = "seed.pred_2020", interaction = "seed.pred", year = "2020", date = NA, fl.stems.field = NA)

#re-order formatted dataset to stardard. This line should be in every processing script; if there's a problem, the formatting isn't correct.
format_cov <- format_cov[c("dataset.id","interaction","year","date","plant.id.field","height.field","fl.stems.field","tot.fl.field","tot.fr.field")]

#save the formatted dataset
write.csv(format_cov, "Processing/2020SeedPred_Cov_Formatted.csv", row.names = FALSE)

#clear the environment so the next script doesn't use anything from here
rm(list=ls())
