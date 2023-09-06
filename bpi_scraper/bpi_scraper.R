#Packages needed 
#install.packages("tidyverse")
#install.packages("babynames")
#install.packages("dplyr")
#install.packages("rvest")
#install.packages("openxlsx")

#A web scraper to get BPI for college basketball teams from 2013-2023 (end of year). Data from ESPN. 

library("tidyverse")
library("babynames")
library("dplyr")
library("rvest")
library("openxlsx")

#FOR FIRST PAGE (URL)
html_data <- read_html("https://www.espn.com/mens-college-basketball/bpi")

html_data <- html_data %>% html_elements("td.Table__TD")

html_teams <- html_data %>% html_elements("span.TeamLink__Name") %>% html_text()

array <- html_data %>% html_text()

#For each team - loop for conference ; until 50 teams
# add year variable for each team/conf
year <- c()
html_conf <- c()
for (i in seq(2, 100, 2)) {
  html_conf <- append(html_conf, array[i])
  year <- append(year, 2023)
}

#For stats data 
# 1 : W-L; 2 : BPI; 3 : BPI Rank; 4 : Trend ; 5 : Off; 6 : Def ; 7-10 : Projections

html_record <- c()
html_bpi <- c()
html_rank <- c()
html_off <- c()
html_def <- c()
for (i in seq(101, 600, by=10)) {
  html_record <- append(html_record, array[i])
  html_bpi <- append(html_bpi, array[i+1])
  html_rank <- append(html_rank, array[i+2])
  html_off <- append(html_off, array[i+4])
  html_def <- append(html_def, array[i+5])
}

#For data from years 2022 back until 2013

for (i in 22:13) {
  new_year <- paste(c("20", i), collapse="")
  
  url <- sprintf("https://www.espn.com/mens-college-basketball/bpi/_/season/20%d", i)
  html_data <- read_html(url)

  html_data <- html_data %>% html_elements("td.Table__TD")

  array <- html_data %>% html_text()

  #Now have url; get elements from this url
  #For each team - loop for conference ; until 50 teams
  for (i in seq(1, 100, 2)) {
    html_teams <- append(html_teams, array[i])
    html_conf <- append(html_conf, array[i+1])
    year <- append(year, new_year)
  }

  #For stats data
  # 1 : W-L; 2 : BPI; 3 : BPI Rank; 4 : Trend ; 5 : Off; 6 : Def ; 7-10 :   Projections
  for (i in seq(101, 600, by=10)) {
    html_record <- append(html_record, array[i])
    html_bpi <- append(html_bpi, array[i+1])
    html_rank <- append(html_rank, array[i+2])
    html_off <- append(html_off, array[i+4])
    html_def <- append(html_def, array[i+5])
  }
}

#Create dataframe and put data together 
espn_bpi_data <- tibble(
  html_teams,
  html_conf,
  year,
  html_record,
  html_bpi,
  html_rank,
  html_off,
  html_def
)

#Clean column names
espn_bpi_data <- espn_bpi_data %>% rename(
  Team = html_teams,
  Conference = html_conf,
  Year = year,
  Record = html_record,
  BPI = html_bpi,
  BPIRank = html_rank,
  BPIOffense = html_off,
  BPIDefense = html_def
)

#Export data to CSV file / excel file 
write.csv(espn_bpi_data, file='/Users/fionamcgowan/Desktop/bpi_scraper/espn_bpi_data.csv')
write.xlsx(espn_bpi_data, file='/Users/fionamcgowan/Desktop/bpi_scraper/espn_bpi_data.xlsx')
