Sys.setenv(LANGUAGE="en") 

# veri setinin erişim linki
# https://archive.ics.uci.edu/ml/machine-learning-databases/00468/ 

# GerekliKütüphanelerinin Yüklenmesi ve Aktif Hale Getirilmesi 
#install.packages("Hmisc")
#install.packages("clusterSim")
#install.packages("dbscan")
#install.packages("opticskxi")

# Veri setinin okunması
# Veri setinin dosyası R kodunun kaydedilmiş olduğu dosya ile aynı klasörde bulunmalıdır.

veri<-read.csv("online_shoppers_intention.csv",sep=",")
head(veri)

# the structer of the dataset
str(veri)

summary(veri)


nrow(veri)

head(veri)

# Veri setinde eksik veri olma durumunun kontrol edilmesi: 
anyNA(veri)

# Veri Standartlaştırma
# Kategorik Özniteliklerin Dönüştürülmesi
veri$VisitorType=factor(veri$VisitorType,levels=c("New_Visitor","Other","Returning_Visitor"),labels=c(1,2,3))
veri$Month=factor(veri$Month,levels=c("Jan","Feb","Mar","Apr","May","June","Jul","Aug","Sep","Oct","Nov","Dec"),labels=c(1,2,3,4,5,6,7,8,9,10,11,12))

veri$Weekend=factor(veri$Weekend,levels=c("FALSE","TRUE"),labels=c(1,2))
veri$Revenue=factor(veri$Revenue,levels=c("FALSE","TRUE"),labels=c(1,2))

veri$VisitorType<-as.numeric(veri$VisitorType)
head(veri$VisitorType)

veri$Month <-as.numeric(veri$Month)
head(veri$Month)

veri$Weekend <-as.numeric(veri$Weekend)
head(veri$Weekend)

veri$Revenue <-as.numeric(veri$Revenue)
head(veri$Revenue)

# Sayısal Dönüşüm Gerçekleştirilmis Veri Seti
str(veri)

library(clusterSim)
veri_zscore<-data.Normalization(veri, type="n1", normalization="column")

veri<-veri_zscore
head(veri)

# Kümeleme analizi:
###################

library(dbscan)
#OPTICS_model= optics(veri, eps = 3, minPts = 30)  
OPTICS_model= optics(veri, minPts = 30)
OPTICS_model


# Gözlemlerin Erişilebilirlik Uzaklıkları:

e_uzaklik<-OPTICS_model$reachdist
e_uzaklik

# Modeldeki Gözlemlerin Çekirdek Uzaklıkları:
OPTICS_model$coredist
# OPTICSxi
library('opticskxi')

# Modeldeki Gözlemlerin Sıralanma Bilgisi:
OPTICS_model$order

#n_xi: grafikte gösterilecek küme sayısı

# gözlemlerin ait olduğu kümeler:
kxi_kumeleme <- opticskxi(OPTICS_model, n_xi = 5, pts = 20)
kxi_kumeleme

#Veri kümelerinin görselleştirilmesi: 
ggplot_optics(OPTICS_model, groups = kxi_kumeleme)
