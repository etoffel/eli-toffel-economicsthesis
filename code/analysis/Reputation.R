source('housekeeping.R')

media_change <- read_csv("data/clean/Media_Change.csv")
reputation_data <- read_csv("data/Build 2/Reputation Data.csv")

reputation_data <- reputation_data %>%
  rename(
    Unique_ID = `Unique ID`,  # Ensure column name matches avg_stock
    Year.x = Year,  # Rename Year to match avg_stock
  )


View(reputation_data)
# Merge datasets by Unique_ID and Year.x
reputation_data <- media_change %>%
  left_join(reputation_data, by = c("Unique_ID", "Year.x"))
