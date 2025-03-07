# Preliminaries -----------------------------------------------------------

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, scales)


# Read data and set workspace for knitr -------------------------------
full.ma.data <- readRDS('data/output/plan_data.rds')
contract.service.area <- readRDS('data/output/service_area.rds')

# Create objects for markdown ---------------------------------------------

plan.type.table <- full.ma.data %>% group_by(plan_type) %>% count() %>% arrange(-n)
tot.obs <- as.numeric(count(full.ma.data %>% ungroup()))
plan.type.year1 <- full.ma.data %>% group_by(plan_type) %>% count() %>% arrange(-n) %>% filter(plan_type!="NA")

final.plans <- full.ma.data %>%
  filter(snp == "No" & eghp == "No" &
           (planid < 800 | planid >= 900))
plan.type.year2 <- final.plans %>% group_by(plan_type) %>% count() %>% arrange(-n)

plan.type.enroll <- final.plans %>% group_by(plan_type) %>% summarize(n=n(), enollment=mean(enrollment, na.rm=TRUE)) %>% arrange(-n)

final.data <- final.plans %>%
  inner_join(contract.service.area %>% 
               select(contractid, fips, year), 
             by=c("contractid", "fips", "year")) %>%
  filter(!is.na(enrollment))
