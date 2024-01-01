# gerekli paketler kuruluyor
# install.packages("readr", "clusterSim", "kohonen", "ggplot2", "rnaturalearth", "rnaturalearthdata")

# gerekli paketler calisma ortamina yukleniyor
library(readr)
library(clusterSim)
library(kohonen)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)


# R dosyasinin oldugu klasor calisma klasoru olarak ayarlaniyor
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# veri seti okunuyor
df <- read.csv("whr2023.csv")

# kayip veri kontrolu yapiliyor
which(is.na(df))
# kac adet kayip veri oldugu bulunuyor
sum(is.na(df))
# kayip veri olan satir veri setinden siliniyor
df <- na.omit(df)

# tekrar kayip veri kontrolu yapiliyor
which(is.na(df))

# nitelik isimleri ekrana ciktilaniyor
colnames(df)
# kumelemede kullanilacak nitelikler seciliyor
df_scaled <- df[, c(8, 9, 10, 11, 12, 13 )]

# veri setinin ozeti ekrana ciktilaniyor
summary(df_scaled)
# ilk alti satir ekrana ciktilaniyor
head(df_scaled)


# nitelikler Z-Score yontemine gore olcekleniyor
df_scaled<-data.Normalization (df_scaled, type="n0",normalization="column")

# veri seti algoritmada kullanmak icin matris formuna cevriliyor
df_scaled <- as.matrix(df_scaled)





# SOM topolojisi belirleniyor
som_grid <- somgrid(xdim = 1,
                    ydim = 3, 
                    topo = "rectangular",
                    neighbourhood.fct = "gaussian"
)


# SOM modeli kuruluyor
set.seed(100)
som_model <- som(df_scaled,
                 som_grid,
                 rlen = 1000,
                 alpha=0.5,
                 radius = 0.5,
                 keep.data = TRUE,
                 dist.fcts = "euclidean")

# modelin ozeti ekrana ciktilaniyor
summary(som_model)
# kume sayisi ekrana ciktilaniyor
# nunits(som_model)
# model bilesenleri ciktilaniyor
# str(som_model)

# her bir satirin hangi kumede oldugu ekrana ciktilaniyor
som_model$unit.classif

# hangi kumede kac eleman oldugu elde ediliyor
table(som_model$unit.classif)


# kume bilgisi veri setine kaydediliyor
df$cluster <- som_model$unit.classif

# rnaturalearth paketinden ulke bilgileri elde ediliyor
world <- ne_countries(scale = "medium", returnclass = "sf")
# ulke kodlarini tutan nitelik ismi degistiriliyor
names(world)[names(world) == "iso_a3"] <- "iso.alpha"

# ulke bilgilerini saklayan veri seti ile
# Dunya Mutluluk Raporu 2023 veri seti
# iso.alpha sutununa gore birlestiriliyor
df_merge <- merge(x = world, 
                  y = df, 
                  by = "iso.alpha",
                  all.y = TRUE)

# kume verisi faktorize ediliyor
df_merge$cluster <- as.factor(df_merge$cluster)

# SOM algoritmasinin ulkeleri mutluluk raporuna gore
# 3 kumeye ayirmisti. Bu kumeler ve ulkeler
# dunya haritasinda gosteriliyor
choromap <- ggplot(data = df_merge) +
  geom_sf(aes(fill = cluster)) +
  scale_fill_manual(values = c("yellow", "maroon", "darkblue")) +
  labs(fill = "Kume Gruplari") +
  ggtitle("Dunya Mutluluk Raporu 2023 - SOM Algoritmasi")

choromap


for (i in 1:3){
 print(paste(i, ". Kumeye ait Ulkeler:"))
 print( df[which(df$cluster==i), "Country.name"])
}







## kumeler belirleniyor
som_cluster <- cutree(hclust(dist(som_model$codes[[1]])), 3)
som_cluster
# ulkelerin hangi kumede oldugu belirleniyor
cluster_index <- som_cluster[som_model$unit.classif]
cluster_index

plot(som_model, type="mapping", bgcol = rainbow(3)[som_cluster], main = "Clusters") 
add.cluster.boundaries(som_model, som_cluster)

plot(som_model, type = "codes", main = "Codes Plot", palette.name = rainbow)

plot(som_model, type = "counts")

plot(som_model, type="dist.neighbours")

plot(som_model, type = "changes")

plot(som_model, type="codes", bgcol=rainbow(3)[som_cluster], main = "Clusters") 
add.cluster.boundaries(som_model, som_cluster)



