# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)  # Needed for `expand_grid()`

# Read datasets
HPPanel <- read_csv("data/work/HP 2nd Round - Panel.csv")
FortuneInfo <- read_csv("data/raw/Fortune 500 Info Data.csv")

# Rename columns in FortuneInfo (ensure consistent naming)
FortuneInfo <- FortuneInfo %>%
  rename(Year = year, Company = name) %>%
  mutate(Company = case_when(
    Company == "Amazon.com" ~ "Amazon",
    Company == "UPS" ~ "United Parcel Service",
    Company == "Meta Platforms" ~ "Facebook",
    TRUE ~ Company  # Keep all other names unchanged
  ))

# Ensure 'Year' is numeric in both datasets
HPPanel <- HPPanel %>%
  mutate(Year = as.integer(Year))

FortuneInfo <- FortuneInfo %>%
  mutate(Year = as.integer(Year))

# Step 1: Create a full dataset of all Companies and all Years
all_years <- unique(HPPanel$Year)  # Extract all available years
all_companies <- unique(HPPanel$Company)  # Extract all company names from HPPanel

# Expand dataset to ensure every company appears in all years
expanded_df <- expand_grid(Company = all_companies, Year = all_years)

# Step 2: Merge back HPPanel data (preserve Reputation Score and other columns)
expanded_hp <- expanded_df %>%
  left_join(HPPanel, by = c("Company", "Year"))

# Step 3: Merge Fortune 500 data separately
final_df <- expanded_hp %>%
  left_join(FortuneInfo, by = c("Company", "Year"))

# View and save the final dataset
View(final_df)

write_csv(final_df, "data/work/almostMergedHPFortune.csv")
