source('housekeeping.R')

# Load datasets
pulled_together <- read_csv("data/clean/MediaDataPulledTogether.csv")


# Clean and rename media_data before merging
pulled_together <- pulled_together %>%
  rename(
    Media_Articles_Total = `Number of Media Articles Total`,
    Negative_Business_Articles = `Negative Business Articles`,
    Negative_Personal_Articles = `Negative Personal Articles`,
    Nexis_Input = `Input into Nexis`,  # Rename before dropping
    Parent_Company = `Parent Company`  # Rename before dropping
  ) %>%
  select(-Nexis_Input, -Parent_Company)  # Drop unnecessary columns

## Housekeeping, 
#Remove those that I couldn't find Media info on
pulled_together <- pulled_together %>%
  filter(!is.na(Media_Articles_Total))

#Limiting Subaru which made a pledge in 2000 and removing companies that aren't tracked by CarbonTracker
pulled_together <- pulled_together %>% filter(Years_to_Pledge <= 10, !is.na(Unique_ID))

#

         
# Event Study Regression: Total Media Coverage
event_study_media <- feols(Media_Articles_Total ~ i(Years_to_Pledge, Target_Category, ref = -1)| 
                             Unique_ID + Year.x, 
                           data = pulled_together)


# Summary of the model
summary(event_study_media)

# Event Study Regression: Negative Personal 
pulled_together <- pulled_together %>%
  mutate(
    Percent_Negative_Business = ifelse(Media_Articles_Total > 0, 
                                       Negative_Business_Articles / Media_Articles_Total * 100, NA),
    Percent_Negative_Personal = ifelse(Media_Articles_Total > 0, 
                                       Negative_Personal_Articles / Media_Articles_Total * 100, NA)
  )

event_study_media_business <- feols(Percent_Negative_Business ~ i(Years_to_Pledge, Target_Category, ref = -1)| 
                             Unique_ID + Year.x, 
                           data = pulled_together)

summary(event_study_media_business)

event_study_media_personal <- feols(Percent_Negative_Personal ~ i(Years_to_Pledge, Target_Category, ref = -1)| 
                                      Unique_ID + Year.x, 
                                    data = pulled_together)

summary(event_study_media_personal)



