source('housekeeping.R')

# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)  # Needed for `expand_grid()`

# Read datasets
MergedPanel <- read_csv("data/work/almostMergedHPFortune.csv")

#Only keep the continuous variables
continuous_df <- MergedPanel %>%
  select(-industry, -sector, -headquarters_state, -headquarters_city, 
         -founder_is_ceo, -female_ceo, -newcomer_to_fortune_500, -global_500)

