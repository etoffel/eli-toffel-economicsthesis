source('housekeeping.R')

media_change <- read_csv("data/clean/MediaDataPulledTogether.csv")
reputation_data <- read_csv("data/Build 2/Reputation Data.csv")

media_change <- media_change %>% 
  filter(Year.x != 2018)


reputation_data <- reputation_data %>%
  rename(
    Unique_ID = `Unique ID`,  # Ensure column name matches avg_stock
    Year.x = Year,  # Rename Year to match avg_stock
  )

# Merge datasets by Unique_ID and Year.x
reputation_data_merge <- media_change %>%
  left_join(reputation_data, by = c("Unique_ID", "Year.x"))

reputation_data_filtered <- reputation_data_merge %>%
  filter(Target_Category != "Other")

# Set Year.y to 0 for all Reduction target category companies
reputation_data_filtered <- reputation_data_merge %>%
  mutate(
    Year.y = ifelse(Target_Category == "Reduction", 0, Year.y)
  )


View(reputation_data_merge)
#Limiting Subaru which made a pledge in 2000 and removing companies that aren't tracked by CarbonTracker
reputation_data_merge <- reputation_data_merge %>% filter(Years_to_Pledge <= 10, !is.na(Unique_ID))

event_study_reputation <- feols(Reputation_Score ~ i(Years_to_Pledge, Target_Category, ref = -1) | 
                                  Unique_ID + Year.x, 
                                data = reputation_data_merge)

summary(event_study_reputation)

feols(Reputation_Score ~ i(Years_to_Pledge, Target_Category, ref = -1) | Unique_ID + Year.x, data = reputation_data_merge)

library(fixest)

# This assumes:
# - `Year.x` is the calendar year
# - `Year.y` is the year of pledge (treatment year)
# - `Treated` is 1 if the firm ever pledges, 0 otherwise
reputation_data_merge <- reputation_data_merge %>%
  mutate(
    Year.y = ifelse(Year.y == 0, NA, Year.y)
  )

staggered_did <- feols(Reputation_Score ~ sunab(Year.y, Year.x) | 
                         Unique_ID + Year.x, 
                       data = reputation_data_merge)
View(reputation_data_merge)

summary(staggered_did)

iplot(staggered_did,
      main = "Staggered DiD: Effect on Reputation Score",
      xlab = "Years Since Pledge",
      ylab = "Effect on Reputation Score")
