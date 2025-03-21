source('housekeeping.R')

carbon_neutral <- read_csv("data/Build 2/Carbon Neutral Pledging Data.csv")
stock_data <- read_csv("data/Build 2/Stock Data.csv")
revenue_data <- read_csv("data/Build 2/Revenue Data.csv")
media_data <- read_csv("data/Build 2/Media Data.csv")

media_data <- media_data %>%
  rename(
    `Unique ID` = `Unique ID'`,
  )

# Merge by Unique ID and Year
merged_data2 <- media_data %>%
  left_join(carbon_neutral, by = "Unique ID")
View(merged_data2)

merged_data2 <- merged_data2 %>%
  rename(
    Unique_ID = `Unique ID`,
    End_Target = `End Target`,  
    Target_Reduction = `End_target_percentage_reduction`,
    Target_Baseline_Year = `End_target_baseline_year2`,
    Target_Completion_Year = `End_target_year`,
    Target_Status = `Status_of_end_target`,
    Last_Update = `Date_of_last_status_update`,
    Target_Details = `End_target_text`,
    Interim_Target = `Interim_target`,
    Interim_Target_Year = `Interim_target_year`,
    Interim_Target_Reduction = `Interim_target_percentage_reduction`,
    Interim_Target_Baseline = `Interim_target_baseline_year`,
    Interim_Target_Details = `Interim_target_text`,
    Target_Notes = `Targets_notes`,  # Renamed this "Notes"
    Scope_1 = `Scope_1_coverage`,
    Scope_2 = `Scope_2_coverage`,
    Scope_3 = `Scope_3_coverage`,
    Published_Plan = `Published_plan`,
    Reporting_Method = `Reporting_mechanism`,
    Carbon_Credits = `Carbon_credits`,
    Credit_Conditions = `Carbon_credits_conditions`,
    Emissions = `GHG_emissions`,
    Emissions_Year = `GHG_emissions_year`,
    Pledge_Date = `Date of Carbon Pledge`,
    Net_Zero_Year = `Carbon Neutral or Net Zero by`,
    Revenue = `Company_annual_revenue`,
    Industry = `Industry`,
    Employees = `Employees`,
    Additional_Notes = `Notes`  # Renamed the second "Notes" to avoid duplication
  )

# Fixing mistaken inputs

merged_data2 <- merged_data2 %>%
  mutate(End_Target = ifelse(Unique_ID == 98 & Company.x == "Yum! Brands", "Net zero", End_Target))

merged_data2 <- merged_data2 %>%
  mutate(End_Target = ifelse(Unique_ID == 60 & Company.x == "Netflix", "Net zero", End_Target))

#####################


merged_data2 <- merged_data2 %>%
  mutate(
    Treated = ifelse(!is.na(Year.y) & Year.y != 0, 1, 0)
  )

merged_data2 <- merged_data2 %>%
  mutate(
    Post_Pledge = ifelse(Treated == 0, 0,  # All untreated firms get Post_Pledge = 0
                         ifelse(Year.x >= Year.y, 1, 0))  # Treated firms follow the pledge year rule
  )

# Compute the median pledge year across treated firms
median_pledge_year <- median(merged_data2$Year.y[merged_data2$Treated == 1], na.rm = TRUE)

# Assign untreated firms a placebo pledge year
merged_data2 <- merged_data2 %>%
  mutate(Years_to_Pledge = ifelse(Treated == 1, Year.x - Year.y,  # Treated firms use real pledge year
                                  Year.x - median_pledge_year)) 

########## Seperating the target types into 4 categories
merged_data3 <- merged_data2 %>%
  mutate(Target_Category = case_when(
    End_Target %in% c("Net zero", "Carbon neutral(ity)") ~ "Net Zero",
    End_Target %in% c("Emissions reduction target", "Science-Based Target") ~ "Reduction",
    End_Target %in% c("No target") ~ "No Target",
    TRUE ~ "Other"
  ))

write.csv(merged_data3, "data/clean/PulledTogether", row.names = FALSE)
