###### Birliktelik Kurallari : Apriori Algoritmasi #######

install.packages("RColorBrewer")

### Kutuphaneler yuklenir.
options(warn=-1)

library(arules) 
library(arulesViz) 
library(tidyverse) 
library(readxl)
library(knitr) 
library(ggplot2)  
library(plyr) 
library(magrittr) 
library(dplyr) 
library(tidyverse) 

#veri seti tanitilir.

itemslist <- read_excel("data_assign.csv")
str(itemslist)
itemslist <- Assignment_1_Data

summary(itemslist)

#veri setinde kayip deger olup olmadigi kontrol edilir.
sum(is.na(itemslist))

#Her bir nitelikteki eksik veri satirlari listelenir.
bs=colnames(itemslist)[colSums(is.na(itemslist))>0]
colSums(is.na(df[,bs]))

sapply(itemslist[,bs],class)
bs_index=which(names(df)%in%bs)

#complete.cases(data) data frame'in herhangi bir sütununda eksik degerlere sahip satirlari kaldiririr.
itemslist <- itemslist[complete.cases(itemslist), ]

#ddply(dataframe, variables_to_split_dataframe, function)
transaxtionData <- ddply(itemslist,c("BillNo","Date"), 
                         function(df1)paste(df1$Itemname, 
                                            collapse = ","))

transaxtionData$BillNo <- NULL
transaxtionData$Date <- NULL

#"item" sütununa isim verilir
colnames(transaxtionData) <- c("items")


write.csv(transaxtionData, "assigment1_itemslist.csv", quote = FALSE, row.names = FALSE)


transactions <- read.transactions('./assigment1_itemslist.csv', 
                                  format = 'basket', sep=',')

summary(transactions)

if (!require("RColorBrewer")) {install.packages("RColorBrewer")
  library(RColorBrewer)
}

itemFrequencyPlot(transactions,topN=20,type="absolute",
                  col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")

#apriori algoritmasi cagrilir.
#support ve confidence degerleri belirlenir.
generated.rules <- apriori(transactions, parameter = list(supp=0.001, conf=0.8,maxlen=10))
generated.rules <- sort(generated.rules, by='confidence', decreasing = TRUE)
summary(generated.rules)

inspect(generated.rules[1:10])


#gosterilecek kurallar için confidence>0.6 olma sarti getirilir.

Rules<-generated.rules[quality(generated.rules)$confidence>0.6]

#kurallarin grafiksel gösterimi
#Plot Rules
plot(Rules)
top10Rules <- head(generated.rules, n = 10, by = "confidence")
plot(top10Rules)


plot(Rules, engine = "plotly")
plot(top10Rules, engine = "plotly")
plot(top10Rules, method = "graph")
plot(top10Rules, method = "grouped")
subRules2<-head(Rules, n=20, by="lift")
plot(subRules2, method="paracoord")
