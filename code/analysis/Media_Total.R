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

pulled_together <- pulled_together %>%
  mutate(
    Percent_Negative_Business = ifelse(Percent_Negative_Business > 100, 100, Percent_Negative_Business),
    Percent_Negative_Personal = ifelse(Percent_Negative_Personal > 100, 100, Percent_Negative_Personal)
  )

event_study_media_business <- feols(Percent_Negative_Business ~ i(Years_to_Pledge, Target_Category, ref = -1)| 
                             Unique_ID + Year.x, 
                           data = pulled_together)

summary(event_study_media_business)

event_study_media_personal <- feols(Percent_Negative_Personal ~ i(Years_to_Pledge, Target_Category, ref = -1)| 
                                      Unique_ID + Year.x, 
                                    data = pulled_together)

summary(event_study_media_personal)

##Plotting
event_results <- broom::tidy(event_study_media, conf.int = TRUE)

# Tidy and filter regression results
event_plot_data <- tidy(event_study_media, conf.int = TRUE) %>%
  filter(grepl("Years_to_Pledge", term)) %>%
  separate(term, into = c("Years_to_Pledge", "Target_Category"), sep = ":Target_Category::") %>%
  mutate(
    Years_to_Pledge = as.numeric(gsub("Years_to_Pledge::", "", Years_to_Pledge)),
    Target_Category = factor(Target_Category)
  ) %>%
  filter(!is.na(Years_to_Pledge), Years_to_Pledge >= -3, Target_Category != "Other")


ggplot(event_plot_data, aes(x = Years_to_Pledge, y = estimate, color = Target_Category)) +
  geom_line(size = 1) +
  geom_point() +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = Target_Category), alpha = 0.2, color = NA) +
  geom_vline(xintercept = -1, linetype = "dashed", color = "black") +
  labs(
    title = "Media Coverage Over Time by Target Category",
    x = "Years to Pledge",
    y = "Estimated Change in Media Articles"
  ) +
  theme_minimal()

#### Tabling
# Filter dataset
filtered_data <- pulled_together %>%
  filter(Target_Category != "Other", Years_to_Pledge >= -3)

# Rerun regressions on filtered data
event_study_media <- feols(
  Media_Articles_Total ~ i(Years_to_Pledge, Target_Category, ref = -1) | Unique_ID + Year.x,
  data = filtered_data
)

event_study_media_business <- feols(
  Percent_Negative_Business ~ i(Years_to_Pledge, Target_Category, ref = -1) | Unique_ID + Year.x,
  data = filtered_data
)

event_study_media_personal <- feols(
  Percent_Negative_Personal ~ i(Years_to_Pledge, Target_Category, ref = -1) | Unique_ID + Year.x,
  data = filtered_data
)

# Display regression tables side-by-side
modelsummary(
  list(
    "Total Media Articles" = event_study_media,
    "Negative Business (%)" = event_study_media_business,
    "Negative Personal (%)" = event_study_media_personal
  ),
  stars = TRUE,
  estimate = "{estimate} ({std.error})",
  statistic = "p.value",
  gof_omit = "IC|Log|Adj|Within|Pseudo|F",
  output = "markdown"
)

# Save regression results to a Word file
modelsummary(
  list(
    "Total Media Articles" = event_study_media,
    "Negative Business (%)" = event_study_media_business,
    "Negative Personal (%)" = event_study_media_personal
  ),
  stars = TRUE,
  estimate = "{estimate} ({std.error})",
  statistic = "p.value",
  gof_omit = "IC|Log|Adj|Within|Pseudo|F",
#  output = "output/event_study_results.docx"  # Make sure this path exists
)



