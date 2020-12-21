# Scrape Icelandic holidays and other events in Iceland

library(tidyverse)
library(rvest)
library(lubridate)


base_url <- "http://dagarnir.is/?year="
years <- 1990:2037
base_url <- paste0(base_url, years)


isl_holidays_list <- list()

for(i in seq_along(base_url)) {

    temp_url <- base_url[[i]]

    isl_table <- temp_url %>%
       read_html(temp_url) %>%
        html_nodes("td") %>%
        html_text()

    isl_table <- matrix(isl_table, ncol = 5, byrow = TRUE)
    isl_table <- as_tibble(isl_table) %>% select(-c(V1, V4))
    isl_table$year <- years[[i]]

    isl_holidays_list[[i]] <- isl_table

}

isl_holidays <- isl_holidays_list %>% bind_rows()

isl_eng_month <- tibble(manudur = c("janúar", "febrúar", "mars", "apríl", "maí", "júní", "júlí", "ágúst", "september", "október", "nóvember", "desember"),
                        month   = 1:12)

isl_holidays <- isl_holidays %>%
    separate(V5, c("dagur", "manudur"), sep = ". ") %>%
    left_join(isl_eng_month) %>%
    mutate(date = make_date(year = year, month = month, day = dagur)) %>%
    select(date, V2) %>%
    set_names("date", "holiday")

# Bæti við þorláksmessu

thorlaksmessa <- tibble(date = as.Date(paste(years, "12-23", sep = "-")),
                        holiday = "Þorláksmessa")


isl_holidays <- isl_holidays %>%
    bind_rows(thorlaksmessa) %>%
    arrange(date)

# Save data as xlsx

isl_holidays %>%
    openxlsx::write.xlsx("isl_holidays.xlsx")
