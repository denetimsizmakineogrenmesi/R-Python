


#K-medoids için gerekli paketler yüklendi ve kütüphaneden çaðýrýldý.#
install.packages("factoextra")
install.packages("cluster")
install.packages("tibble")
install.packages("tidyverse")

library(factoextra)
library(cluster)
library(tibble)
library(tidyverse)

#Kaggle Platformunda World Happiniess 2021 verisi çekildikten sonra#
veri<-world_happiness_report_2021
veri$`Regional indicator`<- NULL
veri$`Ladder score`<- NULL
veri$`Standard error of ladder score`<- NULL
veri$upperwhisker<- NULL
veri$lowerwhisker<-NULL
veri$`Ladder score in Dystopia`<-NULL
veri$`Explained by: Log GDP per capita`<-NULL
veri$`Explained by: Social support`<-NULL
veri$`Explained by: Healthy life expectancy`<-NULL
veri$`Explained by: Freedom to make life choices`<-NULL
veri$`Explained by: Generosity`<-NULL
veri$`Explained by: Perceptions of corruption`<-NULL
veri$`Dystopia + residual`<-NULL

#Ülke adlarýný satýr ismi olarak deðiþtirdik#
veri<-column_to_rownames(veri, var = "Country name")
head(veri)

#özet istatistiklerin elde edilmesi#
str(veri)
summary(veri)
#verileri normalize etmek için#
veri<- scale(veri)


#optimal küme sayýsýnýn silhouette ile belirlenmesi için;#

fviz_nbclust(veri, pam, method = "silhouette")+
  theme_classic()

#optimal küme sayýsýnýn elboww yöntemi ve gap istatistiði ile belirlenmesi için;#
fviz_nbclust(veri, pam, method = "wss")
gap_stat <- clusGap(veri,
                    FUN = pam,
                    K.max = 10, #max clusters to consider
                    B = 50) #total bootstrapped iterations
fviz_gap_stat(gap_stat)

#PAM algoritmasý ile K medoid Kümeleme#

kmed <- pam(veri, k = 3)
print (kmed)

#kümeleme sonuçlarýný orjinal verilere eklemek için#

dd <- cbind(veri, cluster = kmed$cluster)
head(dd, n = 3)


#pam() fonksiyonunun sonuçlarýna eriþmek için#
#küme medoidlerini görmek için#
kmed$medoids

#küme üyeliklerini görmek için#
head(kmed$clustering)
print(kmed$clustering)
print(kmed$clusinfo)


#Kümeleme sonuçlarýný görselleþtirmek için#

fviz_cluster(kmed, data = veri)

