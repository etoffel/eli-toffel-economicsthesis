##RAW DATA
HarrisPoll <- read_csv("data/raw/Harris Poll Scraped Data 2019-2024.csv")
stock_data <- read_csv("data/Build 2/Stock Data.csv")

# View(HarrisPoll)
# View(stock_data)


library(dplyr)

stock_data_NAs <- stock_data %>% filter(is.na(Year))

View(stock_data_NAs)


