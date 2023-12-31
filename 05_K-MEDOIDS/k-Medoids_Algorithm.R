


#K-medoids i�in gerekli paketler y�klendi ve k�t�phaneden �a��r�ld�.#
install.packages("factoextra")
install.packages("cluster")
install.packages("tibble")
install.packages("tidyverse")

library(factoextra)
library(cluster)
library(tibble)
library(tidyverse)

#Kaggle Platformunda World Happiniess 2021 verisi �ekildikten sonra#
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

#�lke adlar�n� sat�r ismi olarak de�i�tirdik#
veri<-column_to_rownames(veri, var = "Country name")
head(veri)

#�zet istatistiklerin elde edilmesi#
str(veri)
summary(veri)
#verileri normalize etmek i�in#
veri<- scale(veri)


#optimal k�me say�s�n�n silhouette ile belirlenmesi i�in;#

fviz_nbclust(veri, pam, method = "silhouette")+
  theme_classic()

#optimal k�me say�s�n�n elboww y�ntemi ve gap istatisti�i ile belirlenmesi i�in;#
fviz_nbclust(veri, pam, method = "wss")
gap_stat <- clusGap(veri,
                    FUN = pam,
                    K.max = 10, #max clusters to consider
                    B = 50) #total bootstrapped iterations
fviz_gap_stat(gap_stat)

#PAM algoritmas� ile K medoid K�meleme#

kmed <- pam(veri, k = 3)
print (kmed)

#k�meleme sonu�lar�n� orjinal verilere eklemek i�in#

dd <- cbind(veri, cluster = kmed$cluster)
head(dd, n = 3)


#pam() fonksiyonunun sonu�lar�na eri�mek i�in#
#k�me medoidlerini g�rmek i�in#
kmed$medoids

#k�me �yeliklerini g�rmek i�in#
head(kmed$clustering)
print(kmed$clustering)
print(kmed$clusinfo)


#K�meleme sonu�lar�n� g�rselle�tirmek i�in#

fviz_cluster(kmed, data = veri)

