#Kutuphaneler#

install.packages("readxl")
install.packages("ggplot2")
install.packages("modelr")
install.packages("gridExtra")

library(readxl)
library(ggplot2)
library(modelr)
library(gridExtra)

#Excel Veri Dosyasini R'a Yuklemek#
veri <- read_excel("./student_performance.xlsx")



#Kategorilerin Sayisal Degerlere Cevrilmesi#

veri$gender <- as.numeric(factor(veri$gender))
veri$ethnicity <- as.numeric(factor(veri$ethnicity))
veri$`parental_level_of_education` <- as.numeric(factor(veri$`parental_level_of_education`))
veri$lunch <- as.numeric(factor(veri$lunch))
veri$`test_preparation_course` <- as.numeric(factor(veri$`test_preparation_course`))



#Degisken Turleri ve Betimsel Istatistikler#

str(veri)
summary(veri)



#Olceklendirme#

s_veri <- apply(veri, 2, scale)
head(s_veri)



##Ozdegerler ve ozdeger Vektorlerinin Olusturulmasi##

cov_veri <- cov(s_veri)
cov_veri

ei_veri <- eigen(cov_veri)
ei_veri

str(ei_veri)
ei_veri$vectors[,1:2]

ozdegervektoru <- ei_veri$vectors[,1:2]
ozdegervektoru <- -ozdegervektoru
ozdegervektoru

row.names(ozdegervektoru) <- c("gender","ethnicity","parental_level_of_education","lunch","test_preparation_course","math_score","reading_score","writing_score")
colnames(ozdegervektoru) <- c("TB1","TB2")
ozdegervektoru

tba <- prcomp(veri, scale = TRUE)
tba$rotation <- -tba$rotation
tba$x <- -tba$x
biplot(tba, scale = 0)



##Temel Bilesen Skorlarinin Olculmesi##

TB_BIR <- as.matrix(s_veri) %*% ozdegervektoru[,1]
TB_IKI <- as.matrix(s_veri) %*% ozdegervektoru[,2]
TB <- data.frame(Ogrenciler = row.names(veri), TB_BIR, TB_IKI)



##Temel Bilesenlerin Gorsellestirilmesi##

ggplot(TB, aes(TB_BIR, TB_IKI)) +
  modelr::geom_ref_line(h = 0) +
  modelr::geom_ref_line(v = 0) +
  geom_text(aes(label = Ogrenciler), size = 3) +
  xlab("Birinci Temel Bilesen") +
  ylab("Ikinci Temel Bilesen")



##Bilesen Sayilarinin Belirlenmesi##

varyansorani <- ei_veri$values / sum(ei_veri$values)
round(varyansorani, 3)

varyansoranigrafigi <- qplot(c(1:8), varyansorani) + 
  geom_line() + 
  xlab("Temel Bilesenler") + 
  ylab("Aciklanan Varyans Orani") +
  ggtitle("Yamac Grafigi") +
  ylim(0, 1)

kumulatifvaryansoranigrafigi <- qplot(c(1:8), cumsum(varyansorani)) + 
  geom_line() + 
  xlab("Temel Bilesenler") +
  ylab("Toplam Aciklanan Varyans Orani") +
  ggtitle("Kumulatif Yamac Grafigi") +
  ylim(0,1)

grid.arrange(varyansoranigrafigi, kumulatifvaryansoranigrafigi, ncol = 2)



