# Ting Han Gan
# 17/09/21

library(dplyr)
library(class)
library(rpart)

world = read.csv("owid-covid-data.csv")

world_cases = world[,c(3,4,12,46,48,52,53,56:59,61)]
world_deaths = world[,c(3,4,15,46,50,52:61)]


locations = unique(world_cases$location)
location_count = length(locations)

latest_cases <- data.frame(location=character(location_count),
                              date=character(location_count), 
                              new_cases_per_million=numeric(location_count), 
                              stringency_index=numeric(location_count),
                              population_density=numeric(location_count),
                              gdp_per_capita=numeric(location_count),
                              extreme_poverty=character(location_count),
                              female_smokers=numeric(location_count),
                              male_smokers=numeric(location_count),
                              handwashing_facilities=numeric(location_count),
                              hospital_beds_per_thousand=numeric(location_count),
                              human_development_index=numeric(location_count),
                              stringsAsFactors=FALSE) 

latest_deaths <- data.frame(location=character(location_count),
                           date=character(location_count), 
                           new_deaths_per_million=numeric(location_count), 
                           stringency_index=numeric(location_count),
                           aged_65_older=numeric(location_count),
                           gdp_per_capita=numeric(location_count),
                           extreme_poverty=character(location_count),
                           cardiovasc_death_rate=character(location_count), 
                           diabetes_prevalence=numeric(location_count), 
                           female_smokers=numeric(location_count),
                           male_smokers=numeric(location_count),
                           handwashing_facilities=numeric(location_count),
                           hospital_beds_per_thousand=numeric(location_count),
                           life_expectancy=numeric(location_count),
                           human_development_index=numeric(location_count),
                           stringsAsFactors=FALSE) 

count = 1
for(i in locations){
  cur_country_cases = world_cases[world_cases$location == i,]
  cur_country_deaths = world_deaths[world_deaths$location == i,]
  latest_cases[count,] = apply(cur_country_cases,2,function(x)x[max(which(!is.na(x)))])
  latest_deaths[count,] = apply(cur_country_deaths,2,function(x)x[max(which(!is.na(x)))])
  count = count + 1
}

# removing continents from dataframes
rows_remove = c(which(latest_cases$location == "Asia"), 
                which(latest_cases$location == "Europe"),
                which(latest_cases$location == "North America"),
                which(latest_cases$location == "South America"),
                which(latest_cases$location == "Africa"),
                which(latest_cases$location == "Oceania"),
                which(latest_cases$location == "World"))

latest_cases = latest_cases[-rows_remove,] 

rows_remove = c(which(latest_deaths$location == "Asia"), 
                which(latest_deaths$location == "Europe"),
                which(latest_deaths$location == "North America"),
                which(latest_deaths$location == "South America"),
                which(latest_deaths$location == "Africa"),
                which(latest_deaths$location == "Oceania"),
                which(latest_deaths$location == "World"))
latest_deaths = latest_deaths[-rows_remove,] 


latest_cases$location <- NULL
latest_cases$date <- NULL
latest_deaths$location <- NULL
latest_deaths$date <- NULL

latest_cases <- mutate_all(latest_cases, function(x) as.numeric(as.character(x)))

latest_cases = latest_cases[complete.cases(latest_cases$new_cases_per_million),]

cases_parts = boxplot(latest_cases$new_cases_per_million)

# Categorising sections from Low - Extreme
low_cases = latest_cases[latest_cases$new_cases_per_million > cases_parts$stats[1] & latest_cases$new_cases_per_million < cases_parts$stats[2],]
low_cases$new_cases_per_million = "Low"

moderate_cases = latest_cases[latest_cases$new_cases_per_million > cases_parts$stats[2] & latest_cases$new_cases_per_million < cases_parts$stats[3],]
moderate_cases$new_cases_per_million = "Moderate"

high_cases = latest_cases[latest_cases$new_cases_per_million > cases_parts$stats[3] & latest_cases$new_cases_per_million < cases_parts$stats[4],]
high_cases$new_cases_per_million = "High"

extreme_cases = latest_cases[latest_cases$new_cases_per_million > cases_parts$stats[4] & latest_cases$new_cases_per_million < cases_parts$stats[5],]
extreme_cases$new_cases_per_million = "Extreme"

latest_cases = rbind(low_cases, moderate_cases, high_cases, extreme_cases)

latest_cases$new_cases_per_million <- as.factor(latest_cases$new_cases_per_million)


colnames(latest_cases)[1] = "target"

latest_deaths <- mutate_all(latest_deaths, function(x) as.numeric(as.character(x)))

latest_deaths = latest_deaths[complete.cases(latest_deaths$new_deaths_per_million),]

cases_parts = boxplot(latest_deaths$new_deaths_per_million)

# Categorising sections from Low - Extreme
low_cases = latest_deaths[latest_deaths$new_deaths_per_million > cases_parts$stats[1] & latest_deaths$new_deaths_per_million < cases_parts$stats[2],]
low_cases$new_deaths_per_million = "Low"

moderate_cases = latest_deaths[latest_deaths$new_deaths_per_million > cases_parts$stats[2] & latest_deaths$new_deaths_per_million < cases_parts$stats[3],]
moderate_cases$new_deaths_per_million = "Moderate"

high_cases = latest_deaths[latest_deaths$new_deaths_per_million > cases_parts$stats[3] & latest_deaths$new_deaths_per_million < cases_parts$stats[4],]
high_cases$new_deaths_per_million = "High"

extreme_cases = latest_deaths[latest_deaths$new_deaths_per_million > cases_parts$stats[4] & latest_deaths$new_deaths_per_million < cases_parts$stats[5],]
extreme_cases$new_deaths_per_million = "Extreme"

latest_deaths = rbind(low_cases, moderate_cases, high_cases, extreme_cases)

latest_deaths$new_deaths_per_million <- as.factor(latest_deaths$new_deaths_per_million)

colnames(latest_deaths)[1] = "target"

# ____________________ ANALYSIS ________________________
# Subset the data into train and test 
set.seed(1)
train.row.cases = sample(1:nrow(latest_cases), 0.7*nrow(latest_cases))
latest_cases.train = latest_cases[train.row.cases,]
latest_cases.test = latest_cases[-train.row.cases,]
train.target.cases = latest_cases.train$target
test.target.cases = latest_cases.test$target

train.row.deaths = sample(1:nrow(latest_deaths), 0.7*nrow(latest_deaths))
latest_deaths.train = latest_deaths[train.row.deaths,]
latest_deaths.test = latest_deaths[-train.row.deaths,]
train.target.deaths = latest_deaths.train$target
test.target.deaths = latest_deaths.test$target

acc <- function(x){sum(diag(x)/(sum(rowSums(x)))) * 100}

# ____________________ Decision Tree ________________________
db.tree_cases = rpart(target~., data = latest_cases.train)
# Basic idea of model performance (tree)
summary(db.tree_cases) 

png(filename = "predict_cases_severity.png", width=1000, height=600)
plot(db.tree_cases)
text(db.tree_cases, pretty = 0)
title("Predicting Severity of Covid-19 Cases")

dev.off()

# Accuracy 
tpredict = predict(db.tree_cases, latest_cases.test, type="class")
tree.res = table(observed = latest_cases.test$target, predicted = tpredict)

paste("Accuracy of Decision Tree:", acc(tree.res), "%")

db.tree_deaths = rpart(target~., data = latest_deaths.train)
# Basic idea of model performance (tree)
summary(db.tree_deaths) 

png(filename = "predict_deaths_severity.png", width=1000, height=600)
plot(db.tree_deaths)
text(db.tree_deaths, pretty = 0)
title("Predicting Severity of Covid-19 Deaths")

dev.off()

# Accuracy
tpredict = predict(db.tree_deaths, latest_deaths.test, type="class")
tree.res = table(observed = latest_deaths.test$target, predicted = tpredict)

paste("Accuracy of Decision Tree:", acc(tree.res), "%")