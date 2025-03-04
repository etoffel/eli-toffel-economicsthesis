# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)  # Needed for `expand_grid()`

# Read datasets
HPPanel <- read_csv("data/work/HP 2nd Round - Panel.csv")
FortuneInfo <- read_csv("data/raw/Fortune 500 Info Data.csv")
Fortune2024 <- read_csv("data/raw/2024 Fortune 500 - Sheet1 (1).csv")

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

### Adding 2024 Data

Fortune2024 <- Fortune2024 %>%
  mutate(Company = case_when(
    Company == "Meta Platforms" ~ "Facebook",
    TRUE ~ Company  # Keep all other names unchanged
  ))

# Perform exact join on Company and Year
final_filled_df <- final_df %>%
  left_join(Fortune2024, by = c("Company", "Year")) %>%
  mutate(
    rank = coalesce(as.numeric(rank.x), as.numeric(rank.y)),  # Convert to numeric before coalescing
    market_value_mil = coalesce(as.numeric(market_value_mil.x), as.numeric(market_value_mil.y)), 
    revenue_mil = coalesce(as.numeric(revenue_mil.x), as.numeric(revenue_mil.y)), 
    profit_mil = coalesce(as.numeric(profit_mil.x), as.numeric(profit_mil.y)), 
    asset_mil = coalesce(as.numeric(asset_mil.x), as.numeric(asset_mil.y)), 
    employees = coalesce(as.numeric(employees.x), as.numeric(employees.y)),
    founder_is_ceo = coalesce(founder_is_ceo.x, founder_is_ceo.y),
    female_ceo = coalesce(female_ceo.x, female_ceo.y)
  ) %>%
  select(-rank.x, -rank.y, -market_value_mil.x, -market_value_mil.y, 
         -revenue_mil.x, -revenue_mil.y, -profit_mil.x, -profit_mil.y, 
         -asset_mil.x, -asset_mil.y, -employees.x, -employees.y, -founder_is_ceo.x, -founder_is_ceo.y, -female_ceo.x, -female_ceo.y,)  # Remove duplicate columns

# View the final dataframe
View(final_filled_df)

write_csv(final_filled_df, "data/work/almostMergedHPFortune.csv")
