# Ting Han Gan 
# 19/08/21

library(data.table)

# reading csv from online and storing it in glb variable 
world = fread("https://covid.ourworldindata.org/data/owid-covid-data.csv")


world_case = world[,c(3,4,6)]
world_test = world[,c(3,4,26)]
world_deaths = world[,c(3,4,14)]
world_string = world[,c(3,4,46)]

case.df <- data.frame(location=character(), 
                     date=as.Date(character()), 
                     new_cases=numeric(), 
                     stringsAsFactors=FALSE) 

test.df <- data.frame(location=character(), 
                      date=as.Date(character()), 
                      new_tests=numeric(), 
                      stringsAsFactors=FALSE) 

deaths.df <- data.frame(location=character(), 
                      date=as.Date(character()), 
                      total_deaths=numeric(), 
                      stringsAsFactors=FALSE) 

stringency.df = data.frame(location=character(),
                           date=as.Date(character()),
                           stringency_index=numeric(),
                           stringsAsFactors=FALSE)

countries = unique(world_case$location)

world_case = na.omit(world_case)
world_test = na.omit(world_test)
world_deaths = na.omit(world_deaths)
world_string = na.omit(world_string)

# case
for(i in countries){
  cur_country = world_case[world_case$location == i,]
  cur_country$date = as.Date(cur_country$date)
  case.df = rbind(case.df, cur_country[which.max(cur_country$date),], use.names = FALSE)
}

# test
for(i in countries){
  cur_country = world_test[world_test$location == i,]
  cur_country$date = as.Date(cur_country$date)
  test.df = rbind(test.df, cur_country[which.max(cur_country$date),], use.names = FALSE)
}

# deaths
for(i in countries){
  cur_country = world_deaths[world_deaths$location == i,]
  cur_country$date = as.Date(cur_country$date)
  deaths.df = rbind(deaths.df, cur_country[which.max(cur_country$date),], use.names = FALSE)
}

# stringency
for(i in countries){
  cur_country = world_string[world_string$location == i,]
  cur_country$date = as.Date(cur_country$date)
  stringency.df = rbind(stringency.df, cur_country[which.max(cur_country$date),], use.names = FALSE)
}

# removing continents from dataframes
rows_remove = c(which(case.df$location == "Asia"), 
                which(case.df$location == "Europe"),
                which(case.df$location == "North America"),
                which(case.df$location == "South America"),
                which(case.df$location == "Africa"),
                which(case.df$location == "Oceania"),
                which(case.df$location == "World"))
case.df = case.df[-rows_remove,] 

rows_remove = c(which(deaths.df$location == "Asia"), 
                which(deaths.df$location == "Europe"),
                which(deaths.df$location == "North America"),
                which(deaths.df$location == "South America"),
                which(deaths.df$location == "Africa"),
                which(deaths.df$location == "Oceania"),
                which(deaths.df$location == "World"))
deaths.df = deaths.df[-rows_remove,] 

# writing file to csv 
## (change working directory if you want csv files to be saved in a specific folder)
write.csv(case.df, file="daily_cases.csv", row.names=FALSE)
write.csv(test.df, file="daily_tests.csv", row.names=FALSE)
write.csv(deaths.df, file="total_deaths.csv", row.names=FALSE)
write.csv(stringency.df, file="stringency.csv", row.names=FALSE)
