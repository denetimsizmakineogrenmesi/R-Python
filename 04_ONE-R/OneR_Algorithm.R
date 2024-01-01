

#           One Rule (OneR) Algorithm



#Kutuphanelerin Yuklenmesi ve Tanimlanmasi
#-----------------------------------------------------
install.packages(c("caret", "tidyverse", "psych", "OneR"))

library(caret)
library(tidyverse)
library(psych)
library(OneR)



#Veri Okuma
#-----------------------------------------------------
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
veri <- read.csv("Churn_Data.csv")

head(veri)


#Veri Hazirlama
#-----------------------------------------------------

veri <- column_to_rownames(veri, var = "customer_id")
head(veri)

veri <- select(veri, -c(country, estimated_salary, balance))
head(veri)

str(veri)

apply(is.na(veri), 2, sum)


veri$gender <- case_when(veri$gender == "Female" ~ 0,
                         veri$gender == "Male" ~ 1)

veri$churn <- case_when(veri$churn == 1 ~ "Churn",
                        veri$churn == 0 ~ "NonChurn")


veri %>% count(churn)
ggplot(as.data.frame(with(veri, table(churn))), aes(factor(churn), Freq, fill = churn)) + 
  geom_col(position = 'dodge') + ggtitle("Veri Seti Hedef DeDiEken DaDilimi")


summary(veri)



kor_kat <- cor(select (veri,-c(churn)), method="pearson")
kor_kat
corPlot(kor_kat,
        main = "Pearson Correlation Coefficient", 
        cex = 1,
        gr = colorRampPalette(c("#FEFFD9", "#41B7C4", "#26456E")))



set.seed(123)
veri_prt <- createDataPartition(veri$churn, p=.8, list = FALSE, times = 1)
egitim <- veri[veri_prt,]
test <- veri[-veri_prt,]


egitim %>% count(churn)
ggplot(as.data.frame(with(egitim, table(churn))), aes(factor(churn), Freq, fill = churn)) + 
  geom_col(position = 'dodge') + ggtitle("Egitim Veri Seti Hedef Degisken Dagilimi")

test %>% count(churn)
ggplot(as.data.frame(with(test, table(churn))), aes(factor(churn), Freq, fill = churn)) + 
  geom_col(position = 'dodge') + ggtitle("Test Veri Seti Hedef Degisken Dagilimi")



#Modelleme
#-----------------------------------------------------
OneR_Model <- OneR(churn~., data = egitim, verbose = TRUE)

summary(OneR_Model)

plot(OneR_Model)



tahmin <- predict(OneR_Model, test)
eval_model(tahmin, test)


confusionMatrix(as.factor(cbind(tahmin,test[,8])[,1]),
                as.factor(case_when(as.factor(cbind(tahmin,test[,8])[,2]) == "Churn" ~ 1,
                                    as.factor(cbind(tahmin,test[,8])[,2]) == "NonChurn" ~ 2)),
                mode="everything",positive="1")



