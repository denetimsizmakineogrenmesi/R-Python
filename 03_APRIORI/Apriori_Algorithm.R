###### 31.05.2023 Apriori with R #######
###### Assignment_1_Data.csv     #######
install.packages("RColorBrewer")

### Install Libraries :
options(warn=-1)

library(arules) #Provides the infrastructure for representing
library(arulesViz) #Extends package 'arules' with various visualization.
library(tidyverse) #The tidyverse is an opinionated collection of  R packages designed for data science.
library(readxl) #Read Excel Files in R.
library(knitr) #Dynamic Report generation in R
library(ggplot2) #A system for 'declaratively' creating graphics, 
library(plyr) #Tools for Splitting, Applying and Combining Data.
library(magrittr) #Provides a mechanism for chaining commands with a new forward-pipe operator, %>%. 
library(dplyr) #A fast, consistent tool for working with data frame like objects, both in memory and out of memory.
library(tidyverse) #This package is designed to make it easy to install and load multiple 'tidyverse' packages in a single step.


#Load excel in R dataframe i named it itemslist


itemslist <- read_excel("C:/Users/gkara/Desktop/Nobel Kitap-2/data_assign.csv")
str(itemslist)
itemslist <- Assignment_1_Data

summary(itemslist)

#veri setinde kayip deger olup olmadigi kontrol ediliyor
sum(is.na(itemslist))

#Her bir nitelikteki eksik veri satirlari listelenmektedir 
bs=colnames(itemslist)[colSums(is.na(itemslist))>0]
colSums(is.na(df[,bs]))

sapply(itemslist[,bs],class)
bs_index=which(names(df)%in%bs)

#complete.cases(data) removing rows with missing values in any column of data frame
itemslist <- itemslist[complete.cases(itemslist), ]

#ddply(dataframe, variables_to_split_dataframe, function)
transaxtionData <- ddply(itemslist,c("BillNo","Date"), 
                         function(df1)paste(df1$Itemname, 
                                            collapse = ","))

transaxtionData$BillNo <- NULL
transaxtionData$Date <- NULL

#will gave the name to column "item"
colnames(transaxtionData) <- c("items")

#transactionData: Data to be written
#"D:/Documents/market_basket.csv": location of file with file name to be written to
#quote: If TRUE it will surround character or factor column with double quotes. If FALSE nothing will be quoted
#row.names: either a logical value indicating whether the row names of x are to be written along with x, or a character vector of row names to be written.
write.csv(transaxtionData, "assigment1_itemslist.csv", quote = FALSE, row.names = FALSE)


transactions <- read.transactions('./assigment1_itemslist.csv', 
                                  format = 'basket', sep=',')

summary(transactions)

if (!require("RColorBrewer")) {install.packages("RColorBrewer")
  library(RColorBrewer)
}

itemFrequencyPlot(transactions,topN=20,type="absolute",
                  col=brewer.pal(8,'Pastel2'), main="Absolute Item Frequency Plot")


generated.rules <- apriori(transactions, parameter = list(supp=0.001, conf=0.8,maxlen=10))
generated.rules <- sort(generated.rules, by='confidence', decreasing = TRUE)
summary(generated.rules)

inspect(generated.rules[1:10])



Rules<-generated.rules[quality(generated.rules)$confidence>0.6]

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
