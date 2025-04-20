# Undergraduate thesis: Praise or Panic? Investor Reactions to Corporate Carbon Neutral Pledges

## Project Overview

This project examines corporate sustainability promises by analyzing the impact of carbon-neutral pledging on companies’ average yearly stock prices. 

The project consists of two main parts: data collection and analysis. Initially, a sample of the most visible companies are scraped from the Axios Harris Poll 100 from 2019-2024 using web scraping techniques. Stock data from public companies are scraped from Macrotrends, and media data is scraped from Nexis Uni searches. Lastly, carbon neutral pledge data is collected from Carbon Neutral Tracker. 98 companies appeared in the Axios Harris Poll for more than one year and also were listed in the carbon neutral tracker dataset. Media data was scraped for the 98 companies and stock data was scraped for all the public companies, which were 80 of the 98. that. These scraped datasets were inputted into R under 'Data/Build 2'. Raw data for the original Axios Harris Poll scrape and Carbon Neutral tracker is listed under 'Data/raw'. The collected data is then merged to create a unified dataset for analysis. 

To replicate the project, an internet connection and access to R are required. Running the code files in order will generate the final report.

### Running scripts (R versions)
Run in this order: 
1. Run code/processing/merging/PullingTogether.R
2. Run Staggered DiD Average Stock.Rmd
3. Media Staggered DiD and Heterogeniety.Rmd' 

## Steps to Replicate
To analyze carbon neutral effects on stock prices, run 'Staggered DiD Average Stock.Rmd'. 
To analyze carbon neutral effects on media attention, run 'Media Staggered DiD and Heterogeniety.Rmd'. 

### Other folders:

- presentations folder: Presentations given to create the project
- writing folder: drafts for sections of the Final Paper
housekeeping.r is an R script in the main directory that sets relative file paths and loads all packages. It is run at the beginning of all other R scripts.

### Data sources

Here are the main data sources in the data project. Descriptions to come! 

- Axios Harris Poll 100 2019-2024
The Axios Harris 100 poll of corporate reputations, March 6, 2019. https://www.axios.com/2019/03/06/axios-harris-poll-corporate-reputations.
The 2020 Axios Harris Poll 100 reputation rankings, July 30, 2020. https://www.axios.com/2020/07/30/axios-harris-poll-corporate-reputations-2020.
The 2021 Axios Harris Poll 100 reputation rankings, May 13, 2021. https://www.axios.com/2021/05/13/the-2021-axios-harris-poll-100-reputation-rankings.
The 2022 Axios Harris Poll 100 reputation rankings, May 24, 2022. https://www.axios.com/2022/05/24/2022-axios-harris-poll-100-rankings.
The 2023 Axios Harris Poll 100 reputation rankings, May 23, 2023. https://www.axios.com/2023/05/23/corporate-brands-reputation-america.
The 2024 Axios Harris Poll 100 reputation rankings, May 22, 2024. https://www.axios.com/2024/05/22/axios-harris-poll-company-reputation-ranking-data-source.

- Media Data
Nexis Uni: https://advance-lexis-com.lprx.bates.edu/bisnexishome/?pdmfid=1519360&crid=86cffcd6-15f2-429e-b553-9228a0d54fab

- Carbon Neutral Pledge Data
John Lang, Camilla Hyslop, Diego Manya, Sybrig Smit, Peter Chalkley, John Bervin Galang, Frances Green, Thomas Hale, Frederic Hans, Nick Hay, Angel Hsu, Takeshi Kuramochi, Steve Smith. Net Zero Tracker. Energy and Climate Intelligence Unit, Data-Driven EnviroLab, NewClimate Institute, Oxford Net Zero. 2024.
"Net Zero Targets among World’s Largest Companies Double, But..." Net Zero Tracker, June 12, 2023. https://zerotracker.net/insights/net-zero-targets-among-worlds-largest-companies-double-but-credibility-gaps-undermine-progress.

- Stock Data
The Long Term Perspective on Markets. Macrotrends. Accessed April 17, 2025. https://macrotrends.net/.