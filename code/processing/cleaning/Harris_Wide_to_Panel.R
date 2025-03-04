# Load necessary libraries
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

#read first round cleaned data
df1 <- read_csv("data/work/Harris Poll 1st Round Cleaning.csv")

# Reshape wide data to long format (panel data)
panel_data <- df1 %>%
  pivot_longer(
    cols = starts_with("20"),  # Select all year-based columns
    names_to = "Year",         # New column for Year
    values_to = "Reputation_Score"  # New column for reputation scores
  ) %>%
  mutate(Year = as.integer(str_extract(Year, "\\d{4}")))  # Extract 4-digit year

library(dplyr)

# Update the "Company" column in HPPanel
panel_data <- panel_data %>%
  mutate(Company = ifelse(Company == "Amazon.com", "Amazon", Company))

# Check if the change was applied
unique(panel_data$Company)

View(panel_data)
# Save the file in "data/work" folder
write_csv(panel_data, "data/work/HP 2nd Round - Panel.csv")
