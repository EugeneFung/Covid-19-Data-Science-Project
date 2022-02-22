# Ting Han Gan 
# 09/08/21

library(data.table)

# reading csv from online and storing it in glb variable 
glb = fread("https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv")

# converting date attribute to as.Date
glb$date = as.Date(glb$date)
glb = glb[,c(2,9:15)]

# RR = Retail and recreation 
# GP = Grocery and pharmacy 
# P = Parks 
# TS = Transit stations 
# W = Workplaces
# R = Residentia

colnames(glb)[3] = "RR"
colnames(glb)[4] = "GP"
colnames(glb)[5] = "P"
colnames(glb)[6] = "TS"
colnames(glb)[7] = "W"
colnames(glb)[8] = "R"

res.df <- data.frame(Date=as.Date(character()), 
                 RR=numeric(), 
                 GP=numeric(), 
                 P=numeric(), 
                 TS=numeric(), 
                 W=numeric(), 
                 R=numeric(), 
                 stringsAsFactors=FALSE) 

countries = unique(glb$country_region)

# combining all sub regions within a region into one
for(i in countries){
  cur_country = glb[glb$country_region == i,]
  ## if there is only one instance per day recorded, i.e., no need to aggregate
  if (nrow(cur_country) > 600){
    row_count = nrow(cur_country)
    na_sums = colSums(is.na(cur_country))
    # if there exists a column with all NAs within a country, then replace with 0
    if (length(which(na_sums == row_count) > 0)){
       empty_col = which(na_sums == row_count)
       cur_country[empty_col] = 0
    }
    country_mean = aggregate(.~date, cur_country, FUN = function(x) mean(as.numeric(as.character(x))))
  } else country_mean = cur_country
  country_mean$country_region = i
  res.df = rbind(res.df, country_mean)
}
# swapping column 2 and 1
res.df = res.df[, c(2, 1, 3, 4, 5, 6, 7, 8)]

min.max <- data.frame(Country = character(),
                     Date=as.Date(character()), 
                     RR=numeric(), 
                     GP=numeric(), 
                     P=numeric(), 
                     TS=numeric(), 
                     W=numeric(), 
                     R=numeric(), 
                     stringsAsFactors=FALSE) 

# first and current date of each region to compare change before and after the pandemic  
for(i in countries){
  cur_country = res.df[res.df$country_region == i,]
  min.max = rbind(min.max, cur_country[which.min(cur_country$date),], use.names = FALSE)
  min.max = rbind(min.max, cur_country[which.max(cur_country$date),], use.names = FALSE)
}

current.change <- data.frame(Country = character(),
                      Date=as.Date(character()), 
                      RR=numeric(), 
                      GP=numeric(), 
                      P=numeric(), 
                      TS=numeric(), 
                      W=numeric(), 
                      R=numeric(), 
                      stringsAsFactors=FALSE) 
# current date of each region (for tableau)
for(i in countries){
  cur_country = res.df[res.df$country_region == i,]
  current.change = rbind(current.change, cur_country[which.max(cur_country$date),], use.names = FALSE)
}

# writing both files to csv 
## (change working directory if you want csv files to be saved in a specific folder)
write.csv(res.df, file="daily_region_change.csv", row.names=FALSE)
write.csv(min.max, file="compare_region_change.csv", row.names=FALSE)
write.csv(current.change, file="current_region_change.csv", row.names=FALSE)

