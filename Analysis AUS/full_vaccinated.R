library(forecast)

covid = read.csv('aus_full.csv')
covid = covid[486:574,c(3,20)]
covid$people_fully_vaccinated = covid$people_fully_vaccinated / 25360000
covid$date = as.Date(covid$date, format="%Y-%m-%d")
covid$date = format(covid$date, format='%d-%m')

model = auto.arima(covid[,2])
cforecast = forecast(model, level=c(95), h=10*12)

dates = seq(as.Date('2021-8-22'), by='days', length.out=118)
dates = format(dates, format='%d-%m')
dates = as.data.frame(dates)
colnames(dates) = 'date'
dates$people_fully_vaccinated = 0
covid = rbind(covid, dates)

# reattach forecasting prediction into the dataset
covid$people_fully_vaccinated[as.numeric(tail(which(covid$people_fully_vaccinated!=0),1)+1):nrow(covid)] = cforecast$mean

png(filename = "full_vaccinated.png")

plot(cforecast, xlab='Date (Day-Month)', ylab='Vaccination Percentage', main='Percentage of AUS population fully vaccinated', xaxt='n')
axis(1, at=1:nrow(covid), labels=covid[,1], las=2)

# first value that is >= 0.8
abline(v = head(which(covid$people_fully_vaccinated >= 0.8),1), col="red", lwd=1, lty=2)
# 80% vaccinated
abline(h = 0.8, col="red", lwd=1, lty=2)

res = covid[head(which(covid$people_fully_vaccinated >= 0.8),1),] 
pred_date = as.Date(res$date, "%d-%m")
pred_date = format(pred_date, "%b-%y")  

legend(1, 1.2, legend=c(paste("Date: ", pred_date), paste("Population Vaccinated (First Dose): ", paste(round(res$people_fully_vaccinated,3), "%"))),
       lty=0:0, cex=0.8)

dev.off()


