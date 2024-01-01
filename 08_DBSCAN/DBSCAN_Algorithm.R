

install.packages("dbscan")
library(dbscan)


Country_data = read.csv('Country_data.csv')

str(Country_data)
summary(Country_data)

veri <- Country_data[2:4]

kNNdistplot(veri, k = 5)

abline(h = 0.14, col = "red", lty = 5)

sonuc <- dbscan(veri, eps = 0.14, minPts = 5)
sonuc

sonuc <- dbscan(veri, eps = 0.14, minPts = 8)
sonuc

hullplot(veri, sonuc)

country <- Country_data$country
cluster <- predict(sonuc, veri[1:167,], data = veri)
tablo <- data.frame(country, cluster)  
head(tablo, 10)
