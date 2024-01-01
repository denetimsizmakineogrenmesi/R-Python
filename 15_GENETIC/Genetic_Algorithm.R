
#           Genetic Algorithm



#Install and Load Libraries
#-----------------------------------------------------
# install.packages("GA")

library(GA)

veri <- data.frame(
            Malzeme = c('İsviçre Çakısı',
                        'El Feneri',
                        'Pusula',
                        'Su Arıtma Cihazı',
                        'Paracord',
                        'İlk Yardım Kiti',
                        'Uyku Tulumu',
                        'Çadır',
                        'Harita',
                        'Çakmak'),
            Ağırlık = c(0.2, 0.3, 0.1, 0.5, 0.4, 0.3, 1.5, 2.0, 0.2, 0.05),
            Hacim = c(0.5, 0.2, 0.1, 1.0, 0.3, 0.4, 2.0, 3.0, 0.3, 0.1),
            Önem_Seviyesi = c(5, 4, 3, 5, 2, 4, 4, 5, 3, 1))

# Kısıtlar
ağırlık_kısıtı <- 3
hacim_kısıtı <- 5


# Kromozonların anlamını çözen fonksiyon
en_iyi_malzemeler <- function(x) {
                            malzemeler <- veri$Malzeme[x == 1]
                            return(malzemeler)}


# Hayatta kalma puanını hesaplayan fonksiyon
uygunluk <- function(x) {
  ağırlık_toplamı <- sum(x * veri$Ağırlık)
  hacim_toplamı <- sum(x * veri$Hacim)
  önem_toplamı <- sum(x * veri$Önem_Seviyesi)
  
  uygunluk_skoru <- hacim_toplamı + önem_toplamı
  
  if (ağırlık_toplamı > ağırlık_kısıtı | hacim_toplamı > hacim_kısıtı) {
    uygunluk_skoru <- 0
  }
  return(uygunluk_skoru)
}



# Genetik Algoritma Parametreleri
popülasyon_boyutu <- 50
jenerasyon_sayısı <- 100

# Genetik Algoritma Uygulaması
genetik_algoritma <- ga(type = "binary",
                fitness = uygunluk,
                nBits = nrow(veri),
                popSize = popülasyon_boyutu,
                maxiter = jenerasyon_sayısı)

# Algoritma Özet Tablosu
summary(genetik_algoritma)

# En iyi bireyin indeksi
en_iyi_birey_indeks <- which.max(genetik_algoritma@fitness)

# En iyi malzemeler
en_iyi_malzemeler <- veri$Malzeme[genetik_algoritma@population[en_iyi_birey_indeks, ] == 1]

# En iyi fitness değeri
en_iyi_uygunluk_değeri <- genetik_algoritma@fitness[en_iyi_birey_indeks]

# Sonuçları yazdırma
cat("En İyi Malzemeler:\n")
print(en_iyi_malzemeler)
cat("En İyi Uygunluk Skoru:", en_iyi_uygunluk_değeri)

# Jenerasyon Grafiği
plot(genetik_algoritma)
