library(forecast)
library(tidyr)
library(xts)
library(anytime)

covid = read.csv('COVID_AU_national.csv')
covid = covid[374:571,c(1,19)]
covid$vaccines_cum = covid$vaccines_cum / 25360000
covid$date = as.Date(covid$date, format="%Y-%m-%d")
covid$date = format(covid$date, format='%d-%m')

model = auto.arima(covid[,2])
cforecast = forecast(model, level=c(95), h=10*4)

dates = seq(as.Date('2021-8-18'), by='days', length.out=45)
dates = format(dates, format='%d-%m')
dates = as.data.frame(dates)
colnames(dates) = 'date'
dates$vaccines_cum = 0
covid = rbind(covid, dates)

# reattach forecasting prediction into the dataset
covid$vaccines_cum[as.numeric(tail(which(covid$vaccines_cum!=0),1)+1):nrow(covid)] = cforecast$mean

png(filename = "vaccinations_pred.png")

plot(cforecast, xlab='Date (Day-Month)', ylab='Vaccination Percentage', main='Percentage of AUS Population Vaccinated (First Dose)', xaxt='n')
axis(1, at=1:nrow(covid), labels=covid[,1], las=2)

# first value that is >= 0.8
abline(v = head(which(covid$vaccines_cum >= 0.8),1), col="red", lwd=1, lty=2)
# 80% vaccinated
abline(h = 0.8, col="red", lwd=1, lty=2)

res = covid[head(which(covid$vaccines_cum >= 0.8),1),] 
pred_date = as.Date(res$date, "%d-%m")
pred_date = format(pred_date, "%b-%y")  

legend(1, 1.12, legend=c(paste("Date: ", pred_date), paste("Population Vaccinated (First Dose): ", paste(round(res$vaccines_cum,3), "%"))),
       lty=0:0, cex=0.8)

dev.off()
