library(forecast)

# NEW DEATHS 
covid = read.csv('owid-covid-data.csv')
covid = covid[covid$location == 'World',]
covid = covid[,c(4,9)]
covid$date = as.Date(covid$date, format="%Y-%m-%d")
covid$date = format(covid$date, format='%d-%m')

model = auto.arima(covid[,2])
cforecast = forecast(model, level=c(95), h=10*7)

dates = seq(as.Date('2021-8-21'), by='days', length.out=65)
dates = format(dates, format='%d-%m')
dates = as.data.frame(dates)
colnames(dates) = 'date'
dates$new_deaths = 0
covid = rbind(covid, dates)

png(filename = "world_new_deaths.png", width=1200, height=600)
plot(cforecast, xlab='Date (Day-Month)', ylab='New deaths', main='Forecast of worldwide new deaths', xaxt='n')
axis(1, at=1:nrow(covid), labels=covid[,1], las=2)
dev.off()
# NEW CASES
covid = read.csv('owid-covid-data.csv')
covid = covid[covid$location == 'World',]
covid = covid[,c(4,6)]
covid$date = as.Date(covid$date, format="%Y-%m-%d")
covid$date = format(covid$date, format='%d-%m')

model = auto.arima(covid[,2])
cforecast = forecast(model, level=c(95), h=10*7)

dates = seq(as.Date('2021-8-21'), by='days', length.out=65)
dates = format(dates, format='%d-%m')
dates = as.data.frame(dates)
colnames(dates) = 'date'
dates$new_cases = 0
covid = rbind(covid, dates)

png(filename = "world_new_cases.png", width=1200, height=600)
plot(cforecast, xlab='Date (Day-Month)', ylab='New cases', main='Forecast of worldwide new cases', xaxt='n')
axis(1, at=1:nrow(covid), labels=covid[,1], las=2)
dev.off()
