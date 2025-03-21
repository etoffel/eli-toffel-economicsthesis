library(dplyr)
library(fixest)
library(ggplot2)
library(lubridate)

carbon_neutral <- read_csv("data/Build 2/Carbon Neutral Pledging Data.csv")
stock_data <- read_csv("data/Build 2/Stock Data.csv")
revenue_data <- read_csv("data/Build 2/Revenue Data.csv")
View(revenue_data)


# Merge by Unique ID and Year
merged_data2 <- stock_data %>%
  left_join(carbon_neutral, by = "Unique ID")

merged_data2 <- merged_data2 %>%
  rename(
    Unique_ID = `Unique ID`,
    Avg_Stock_Price = `Average Stock Price`,
    Year_Open = `Year Open`,
    Year_High = `Year High`,
    Year_Low = `Year Low`,
    Year_Close = `Year Close`,
    Annual_Change = `Annual % Change`,
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
  mutate(Year.x = ifelse(Year.x == 25, 2025, Year.x))

#Creating quartiles to filter out outliars
Q1 <- quantile(merged_data2$Avg_Stock_Price, 0.25, na.rm = TRUE)  # First quartile
Q3 <- quantile(merged_data2$Avg_Stock_Price, 0.75, na.rm = TRUE)  # Third quartile
IQR_value <- Q3 - Q1  # Calculate IQR

# Define lower and upper bounds
lower_bound <- Q1 - 1.5 * IQR_value
upper_bound <- Q3 + 1.5 * IQR_value

# Filter out extreme outliars
cleaned_data <- merged_data2 %>%
  filter(Avg_Stock_Price >= lower_bound & Avg_Stock_Price <= upper_bound)

# Check how many rows remain
nrow(cleaned_data)

ggplot(merged_data2, aes(x = End_Target, y = Avg_Stock_Price, fill = End_Target)) +
  geom_boxplot() +
  labs(title = "Stock Price Distribution by Carbon Pledge Type",
       x = "Pledge Type",
       y = "Average Stock Price") +
  theme_minimal()

#####################
merged_data2 <- merged_data2 %>%
  filter(!is.na(Avg_Stock_Price))


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

View(merged_data2)

ggplot(merged_data2, aes(x = as.factor(Post_Pledge), y = Avg_Stock_Price, fill = as.factor(Post_Pledge))) +
  geom_boxplot() +
  labs(title = "Stock Price Before vs. After Carbon Pledge",
       x = "Period (0 = Before Pledge, 1 = After Pledge)",
       y = "Average Stock Price") +
  theme_minimal()

event_study_model <- feols(Avg_Stock_Price ~ i(Years_to_Pledge, Treated, ref = -1) + Revenue | Unique_ID + Year.x, 
                           data = merged_data2)

######## Adding Revenue to the regression

merged_data2 <- merged_data2 %>%
  filter(Year.x != 2025)  # Exclude 2025 observations

merged_data2 <- merged_data2 %>%
  left_join(revenue_data, by = c("Unique_ID" = "Unique ID", "Year.x" = "Year"))

View(merged_data2)

merged_data2 <- merged_data2 %>%
  mutate(Revenue.y = as.numeric(gsub("[$,]", "", Revenue.y)))

event_study_model <- feols(Avg_Stock_Price ~ i(Years_to_Pledge, Treated, ref = -1) + Revenue.y | Unique_ID + Year.x, 
                           data = merged_data2)

summary(event_study_model)

########## Seperating the target types into 4 categories
merged_data3 <- merged_data2 %>%
  mutate(Target_Category = case_when(
    End_Target %in% c("Net zero", "Carbon neutral(ity)") ~ "Net Zero",
    End_Target %in% c("Emissions reduction target", "Science-Based Target") ~ "Reduction",
    End_Target %in% c("No target") ~ "No Target",
    TRUE ~ "Other"
  ))

event_study_model <- feols(Avg_Stock_Price ~ i(Years_to_Pledge, Target_Category, ref = -1) + Revenue.y | Unique_ID + Year.x, 
                           data = merged_data3)
summary(event_study_model)

View(merged_data3)

event_study_model <- feols(Avg_Stock_Price ~ i(Years_to_Pledge, Target_Category, ref = -1) * Treated + Revenue.y | Unique_ID + Year.x, 
                           data = merged_data3)
summary(event_study_model)

######## Heterogeniety

##Published Plan
merged_data4 <- merged_data3 %>%
  mutate(
    Published_Plan = as.factor(Published_Plan),
    Carbon_Credits = as.factor(Carbon_Credits),
    Accountability_delivery = as.factor(Accountability_delivery)
  )
View(merged_data4)

event_study_model <- feols(Avg_Stock_Price ~ i(Years_to_Pledge, Target_Category, ref = -1) * Published_Plan + Revenue.y | 
                             Unique_ID + Year.x, 
                           data = merged_data4)
summary(event_study_model)




