
source('housekeeping.R')

avg_stock <- read_csv("data/clean/Avg_Stock_Cleaned.csv")

avg_stock <- avg_stock %>%
  mutate(Annual_Change = as.numeric(gsub("%", "", Annual_Change)))

View(avg_stock)

avg_stock <- avg_stock %>%
  mutate(Year.y = ifelse(Year.y == 0, NA, Year.y))


pledge_effect_model <- feols(Annual_Change ~ Year.y + Revenue.y | Unique_ID + Year.x, 
                             data = avg_stock)

summary(pledge_effect_model)

####### New Test

avg_stock <- avg_stock %>%
  group_by(Year.x) %>%
  mutate(Pledged_This_Year = ifelse(Year.y == Year.x, 1, 0)) %>%
  ungroup()

annual_change_summary <- avg_stock %>%
  group_by(Pledged_This_Year) %>%
  summarize(mean_annual_change = mean(Annual_Change, na.rm = TRUE),
            sd_annual_change = sd(Annual_Change, na.rm = TRUE),
            n = n())

t_test_result <- t.test(Annual_Change ~ Pledged_This_Year, data = avg_stock, var.equal = TRUE)
print(t_test_result)

pledge_effect_model <- feols(Annual_Change ~ Pledged_This_Year + Revenue.y | Industry + Year.x, 
                             data = avg_stock)

summary(pledge_effect_model)

ggplot(annual_change_summary, aes(x = as.factor(Pledged_This_Year), y = mean_annual_change, fill = as.factor(Pledged_This_Year))) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Average Annual Change by Pledge Status",
       x = "Pledged This Year (0 = No, 1 = Yes)",
       y = "Mean Annual Change (%)") +
  theme_minimal()