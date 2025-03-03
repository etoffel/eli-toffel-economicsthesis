source('housekeeping.R')

# Load necessary libraries
library(dplyr)
library(fuzzyjoin)
library(readr)
library(stringdist)

# Read datasets
HPPanel <- read_csv("data/work/HP 2nd Round - Panel.csv")
FortuneInfo <- read_csv("data/raw/Fortune 500 Info Data.csv")

# Rename Year and Company columns in Fortune 500 dataset
FortuneInfo <- FortuneInfo %>%
  rename(Year = year, Company = name)

# Ensure 'Year' is numeric in both datasets
HPPanel <- HPPanel %>%
  mutate(Year = as.integer(Year))

FortuneInfo <- FortuneInfo %>%
  mutate(Year = as.integer(Year))

# Perform fuzzy join with a stricter match distance
fuzzy_matched_df <- stringdist_left_join(
  HPPanel,        
  FortuneInfo,    
  by = "Company",  
  method = "jw",   
  max_dist = 0.15  # Reduce threshold to avoid excessive matches
)

# Ensure we keep only the best match (avoid multiple matches)
fuzzy_matched_df <- fuzzy_matched_df %>%
  mutate(match_score = stringdist(Company.x, Company.y, method = "jw")) %>%
  group_by(Company.x, Year.x) %>%  
  slice_min(match_score, n = 1) %>%  # Keep best match
  ungroup() %>%
  select(-match_score)  # Remove match score column

# Rename columns if necessary
if ("Year.x" %in% colnames(fuzzy_matched_df) & "Year.y" %in% colnames(fuzzy_matched_df)) {
  fuzzy_matched_df <- fuzzy_matched_df %>%
    rename(Year_HP = Year.x, Year_Fortune = Year.y)
} else {
  stop("Error: Expected Year columns not found after join!")
}

# Ensure all HPPanel years are kept
final_df <- fuzzy_matched_df %>%
  mutate(Year_Fortune = ifelse(is.na(Year_Fortune), Year_HP, as.integer(Year_Fortune))) %>%
  select(-Year_Fortune) %>%
  rename(Year = Year_HP)

# Check row counts before & after
cat("Original HPPanel rows:", nrow(HPPanel), "\n")
cat("Final dataset rows:", nrow(final_df), "\n")

# View the final matched dataset
View(final_df)