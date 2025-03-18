# Load necessary libraries
library(readr)
library(dplyr)

# Define file paths
carbon_neutral <- read_csv("data/Build 2/Carbon Neutral Pledging Data.csv")
stock_data <- read_csv("data/Build 2/Stock Data.csv")
media_data <- read_csv("data/Build 2/Media Data.csv")
reputation_data <- read_csv("data/Build 2/Reputation Data.csv")
revenue_data <- read_csv("data/Build 2/Revenue Data.csv")


#Rename a variable
media_data <- read_csv("data/Build 2/Media Data.csv") %>% 
  rename(`Unique ID` = `Unique ID'`)

#Merge data
merged_data <- media_data %>%
  full_join(reputation_data, by = c("Unique ID", "Year")) %>%
  full_join(revenue_data, by = c("Unique ID", "Year")) %>%
  full_join(stock_data, by = c("Unique ID", "Year"))

merged_data1 <- merged_data %>% 
  select(-c(Company.x, Company.y, Company.x.x, Company.y.y))
