# Preliminaries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table)

#contract info
contract.info <- read_csv("data/input/CPSC_Contract_Info_2015_01.csv", 
                          skip = 1, 
                          col_names = c("contractid", "planid", "org_type", "plan_type",
                                        "partd", "snp", "eghp", "org_name", "org_marketing_name",
                                        "plan_name", "parent_org", "contract_date"),
                          col_types = cols(
                            contractid = col_character(),
                            planid = col_double(),
                            org_type = col_character(),
                            plan_type = col_character(),
                            partd = col_character(),
                            snp = col_character(),
                            eghp = col_character(),
                            org_name = col_character(),
                            org_marketing_name = col_character(),
                            plan_name = col_character(),
                            parent_org = col_character(),
                            contract_date = col_character()
                          ))
colnames(contract.info)
contract.info <- contract.info %>%
  group_by(contractid, planid) %>%
  mutate(id_count=row_number()) %>%
  filter(id_count==1) %>%
  select(-id_count)

#enrollment info
enroll.info <- read_csv("data/input/CPSC_Enrollment_Info_2015_01.csv", 
                        skip = 1,
                        col_names = c("contractid", "planid", "ssa", "fips", "state", "county", "enrollment"),
                        col_types = cols(
                          contractid = col_double(),
                          planid = col_double(),
                          ssa = col_double(),
                          fips = col_double(),
                          state = col_character(),
                          county = col_character(),
                          enrollment = col_double()
                        ),na = '*')


## Merge contract info with enrollment info
plan.data <- contract.info %>%
  left_join(enroll.info, by=c("contractid", "planid")) %>%
  mutate(year=2015) %>%
  group_by(state, county) %>%
  fill(fips) %>%
  group_by(contractid, planid) %>%
  fill(plan_type, partd, snp, eghp, plan_name) %>%
  group_by(contractid) %>%
  fill(org_type,org_name,org_marketing_name,parent_org)


write_rds(plan.data,"data/output/plan_data.rds")
