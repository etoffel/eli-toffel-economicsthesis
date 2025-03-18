carbon_neutral <- read_csv("data/Build 2/Carbon Neutral Pledging Data.csv")
stock_data <- read_csv("data/Build 2/Stock Data.csv")

library(dplyr)

# Merge by Unique ID and Year
merged_data2 <- stock_data %>%
  left_join(carbon_neutral, by = "Unique ID")

library(dplyr)

library(dplyr)

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

library(ggplot2)

Q1 <- quantile(merged_data2$Avg_Stock_Price, 0.25, na.rm = TRUE)  # First quartile
Q3 <- quantile(merged_data2$Avg_Stock_Price, 0.75, na.rm = TRUE)  # Third quartile
IQR_value <- Q3 - Q1  # Calculate IQR

# Define lower and upper bounds
lower_bound <- Q1 - 1.5 * IQR_value
upper_bound <- Q3 + 1.5 * IQR_value

# Filter out extreme outliers
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

View(merged_data2)



