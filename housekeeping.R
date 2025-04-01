# Housekeeping.R
# By: Eli Toffel
# Date: YYYY-MM-DD
# What: This script loads the packages and data needed for the paper.


if (!requireNamespace("pacman", quietly =TRUE)) install.packages("pacman")
pacman::p_load(gridExtra,grid, gridGraphics, tidyverse, modelsummary,pandoc,dplyr,fuzzyjoin,stringr,
               broom,ggplot2,lubridate,tidygeocoder,plm, tigris, sf, fixest, 
               prettymapr, ggspatial, knitr, kableExtra, tidyr, gt)

## Directory creation

here::i_am('housekeeping.R')

data_dir <- here::here('data')
raw_dir <- here::here(data_dir,'raw')
clean_dir <- here::here(data_dir,'clean')
output_dir <- here::here('output')
code_dir <- here::here('code')
work_dir <- here::here(data_dir, 'work')
processing_dir <- here::here(code_dir,'processing')
analysis_dir <- here::here(code_dir,'analysis')
documentation_dir <- here::here('documentation')
cleaning_dir <- here::here(processing_dir,'cleaning')
merging_dir <- here::here(processing_dir, 'merging')

suppressWarnings({
    dir.create(data_dir)
    dir.create(raw_dir)
    dir.create(clean_dir)
    dir.create(documentation_dir)
    dir.create(code_dir)
    dir.create(processing_dir)
    dir.create(analysis_dir)
    dir.create(output_dir)
    dir.create(work_dir)
    dir.create(cleaning_dir)
    dir.create(merging_dir)
})