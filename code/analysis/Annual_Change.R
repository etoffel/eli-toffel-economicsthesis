
source('housekeeping.R')

avg_stock <- read_csv("data/clean/Avg_Stock_Cleaned.csv")

avg_stock <- avg_stock %>%
  mutate(Annual_Change = as.numeric(gsub("%", "", Annual_Change)))

avg_stock <- avg_stock %>%
  mutate(Year.y = ifelse(Year.y == 0, NA, Year.y))

avg_stock <- avg_stock %>%
  mutate(
    Year.y = ifelse(Year.y == 0, NA, Year.y),  # Ensure untreated firms have NA for Year.y
    Pledge_Status = case_when(
      Year.x == Year.y ~ "Pledged This Year",  # Firms that pledged in the current year
      is.na(Year.y) | Year.x < Year.y | Target_Category == "Other" ~ "Not Pledged Yet / Never Pledged",  # Include "Other" in Not Pledged
      TRUE ~ NA_character_  # Handles unexpected cases (though unlikely)
    )
  )

annual_change_summary <- avg_stock %>%
  group_by(Pledge_Status) %>%
  summarize(mean_annual_change = mean(Annual_Change, na.rm = TRUE),
            sd_annual_change = sd(Annual_Change, na.rm = TRUE),
            n = n())

t_test_result <- t.test(Annual_Change ~ Pledge_Status, data = avg_stock, var.equal = TRUE)
print(t_test_result)

avg_stock <- avg_stock %>%
  mutate(Pledge_Status = factor(Pledge_Status))
View(avg_stock)
pledge_effect_model <- feols(Annual_Change ~ Pledge_Status + Revenue.y | Unique_ID + Year.x, 
                             data = avg_stock)

summary(pledge_effect_model)

write.csv(avg_stock, "data/clean/Annual_Change.csv", row.names = FALSE)


