# Created on 2023
# @author: Doc. Dr. Elif Kartal
# @title: Balanced Iterative Reducing and Clustering using Hierarchies (BIRCH) Algoritmasi
# Veri Seti: UCI Machine Learning Data Repository, Facebook Live Sellers in Thailand
# https://archive.ics.uci.edu/dataset/488/facebook+live+sellers+in+thailand

# R Kutuphanelerinin Hazirligi

# install.packages("ggplot2")
# install.packages("clusterSim")
# install.packages("corrplot")
# install.packages("plotly")
# install.packages("fpc")
library(ggplot2)
library(clusterSim)
library(corrplot)
library(plotly)
library(fpc)

# BIRCH fonksiyonu icin https://github.com/rohitkata/BIRCH-Clustering-R-package/blob/master/Birch%20Code%20Version%20-%207.R adresindeki kod dosyasi indirilmeli ve asagidaki kod yardimi ile cagirilmalidir.
source("Birch Code Version - 7.R")

# Veriyi Okuma
# Bilgisayarda yer alan veri seti okunur
veri <- read.table(file = "Live_20210128.csv", header = TRUE, sep = ",", stringsAsFactors = T)
veri <- veri[,4:12]

# Veri On-isleme
# Veri seti Ozeti incelenir
summary(veri)
str(veri)

# Veri Onisleme
# z-Score yontemi kullanilarak veri normalizasyonu
veri <- clusterSim::data.Normalization(veri, type="n1", normalization = "column")
summary(veri)

# Modelleme
# BIRCH kumeleme algoritmasinin uygulanmasi - CF Agacinin olusturulmasi
CF_Tree = BirchCF(x = veri, Type == "df", threshold = 1.5)

# k-Ortalamalar algoritmasi kullanilarak kumelerin elde edilmesi
sonuclar = Fit("kmeans", CF_Tree, nClusters = 3, nStart = 10)

# Kume etiketlerinin elde edilmesi
clusterLabels = sonuclar[,2]
table(clusterLabels)

# Kumelerin PCA kullanilarak gorsellestirilmesi
prin_comp <- princomp(veri)
components <- data.frame(prin_comp$scores[,1:2 ])
components <- cbind(components, clusterLabels)
colnames(components)[1:2] <- c("PCA1","PCA2")

pca_graf <- plot_ly(components, x = ~PCA1, y = ~PCA2, color = ~clusterLabels, colors = c("#636EFA","#EF553B","#00CC96"), type = 'scatter', mode = "markers")%>%
  layout(
    legend=list(title=list(text="color")),
    plot_bgcolor="#e5ecf6",
    xaxis = list(
      title = "Temel Bilesen 1",
      zerolinecolor = "#ffff",
      zerolinewidth = 2,
      gridcolor="#FFFFFF"),
    yaxis = list(
      title = "Temel Bilesen 2",
      zerolinecolor = "#FFFFFF",
      zerolinewidth = 2,
      gridcolor="#FFFFFF"))
pca_graf

# Kumeleme performansinin degerlendirilmesi
silh <- cluster::silhouette(clusterLabels, dist(veri, method = "euclidean"))
sil_deg <- mean(silh[,c("sil_width")])
calhar_deg = fpc::calinhara(veri, clusterLabels)
davbou_deg = clusterSim::index.DB(veri, clusterLabels, centrotypes="centroids")$DB

print(paste0("Silhouette Indeks=", round(sil_deg,3)))
print(paste0("Calinski-Harabasz Indeks=", round(calhar_deg,3)))
print(paste0("Davies-Bouldin Indeks=", round(davbou_deg,3)))

# Farkli kume sayilari kullanilarak kumeleme performansinin degerlendirilmesi

kdegerleri <- 2:20
sil_degerleri <- 0
calhar_degerleri <- 0
davbou_degerleri <- 0

for(i in kdegerleri){
  set.seed(1)
  sonuclar = Fit("kmeans", CF_Tree, nClusters = i, nStart = 10)
  
  # Kume etiketlerinin elde edilmesi
  clusterLabels = sonuclar[,2]
  silh <- cluster::silhouette(clusterLabels, dist(veri, method = "euclidean"))
  sil_degerleri[i-1] <- round(mean(silh[,c("sil_width")]),3)
  calhar_deg[i-1] = round(calinhara(veri, clusterLabels),3)
  davbou_deg[i-1] = round(index.DB(veri, clusterLabels, centrotypes="centroids")$DB,3)

}


sonuc_Kumeleme <- data.frame(kumeler=2:20, silhouette=sil_degerleri, calhar=calhar_deg, davbou=davbou_deg)

###### Sihouette Indeks degerleri icin cizgi grafigi
ggplot(data = sonuc_Kumeleme, aes(x = kumeler)) +
  geom_line(data = sonuc_Kumeleme, aes(x = kumeler, y = silhouette), linetype = "dashed")+
  geom_text(data = sonuc_Kumeleme, aes(y = silhouette, label = silhouette), vjust = -0)+
  xlab("Kume Sayisi") + 
  ylab("Silhouette Indeks Degerleri")+
  geom_point(aes(x = kumeler, y = silhouette), color="black", size=2, shape=18)+
  scale_x_continuous(breaks=seq(2,20,1))

###### Calinski Harabaz Indeks degerleri icin cizgi grafigi
ggplot(data = sonuc_Kumeleme, aes(x = kumeler)) +
  geom_line(data = sonuc_Kumeleme, aes(x = kumeler, y = calhar_deg), linetype = "dashed")+
  geom_text(data = sonuc_Kumeleme, aes(y = calhar_deg, label = calhar_deg), vjust = -0)+
  xlab("Kume Sayisi") + 
  ylab("Calinski Harabaz Indeks Degerleri")+
  geom_point(aes(x = kumeler, y = calhar_deg), color="black", size=2, shape=18)+
  scale_x_continuous(breaks=seq(2,20,1))

###### Davies Bouldin Indeks degerleri icin cizgi grafigi
ggplot(data = sonuc_Kumeleme, aes(x = kumeler)) +
  geom_line(data = sonuc_Kumeleme, aes(x = kumeler, y = davbou_deg), linetype = "dashed")+
  geom_text(data = sonuc_Kumeleme, aes(y = davbou_deg, label = davbou_deg), vjust = -0)+
  xlab("Kume Sayisi") + 
  ylab("Davies Bouldin Indeks Degerleri")+
  geom_point(aes(x = kumeler, y = davbou_deg), color="black", size=2, shape=18)+
  scale_x_continuous(breaks=seq(2,20,1))