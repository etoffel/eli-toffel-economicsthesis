# Load necessary libraries
library(dplyr)
library(fuzzyjoin)
library(readr)
library(stringdist)

# Read datasets
HPPanel <- read_csv("data/work/HP 2nd Round - Panel.csv")
FortuneInfo <- read_csv("data/raw/Fortune 500 Info Data.csv")

# Rename columns in FortuneInfo (ensure consistent naming)
FortuneInfo <- FortuneInfo %>%
  rename(Year = year, Company = name)

# Ensure 'Year' is numeric in both datasets
HPPanel <- HPPanel %>%
  mutate(Year = as.integer(Year))

FortuneInfo <- FortuneInfo %>%
  mutate(Year = as.integer(Year))

# Perform fuzzy join on "Company" and exact join on "Year" (Keep all HPPanel rows)
merged_df <- stringdist_left_join(
  HPPanel,        
  FortuneInfo,    
  by = "Company",  
  method = "jw",   
  max_dist = 0.05  # Adjust for accurate fuzzy matching
) %>%
  filter(is.na(Year.y) | Year.x == Year.y) %>%  # Keep only exact Year matches
  rename(Year = Year.x) %>%  # Rename column for consistency
  select(-Year.y)  # Remove redundant Year column

# View final merged dataset
View(merged_df)

write_csv(merged_df, "data/work/almostMergedHPFortune.csv")
