data <- read.csv("duygusalDurumTahmini.csv")

kategorize_edilmiş_hareketlilik_durumu <- character()
for (adım_sayısı in data$step_count) {
  if (adım_sayısı < 2000) {
    kategorize_edilmiş_hareketlilik_durumu <- c(
        kategorize_edilmiş_hareketlilik_durumu,
        "Az Hareketli")
  } else if (adım_sayısı >= 2000 && adım_sayısı < 4000) {
    kategorize_edilmiş_hareketlilik_durumu <- c(
        kategorize_edilmiş_hareketlilik_durumu,
        "Orta")
  } else if (adım_sayısı >= 4000) {
    kategorize_edilmiş_hareketlilik_durumu <- c(
        kategorize_edilmiş_hareketlilik_durumu,
        "Çok Hareketli")
  }
}
data$kategorize_edilmiş_hareketlilik_durumu <- kategorize_edilmiş_hareketlilik_durumu

kategorize_edilmiş_duygusal_durum <- character()
for (duygusal_durum in data$mood) {
  if (duygusal_durum == 300) {
    kategorize_edilmiş_duygusal_durum <- c(
        kategorize_edilmiş_duygusal_durum,
        "Mutlu")
  } else if (duygusal_durum == 200) {
    kategorize_edilmiş_duygusal_durum <- c(
        kategorize_edilmiş_duygusal_durum,
        "Normal")
  } else if (duygusal_durum == 100) {
    kategorize_edilmiş_duygusal_durum <- c(
        kategorize_edilmiş_duygusal_durum,
        "Üzgün")
  }
}
data$kategorize_edilmiş_duygusal_durum <- kategorize_edilmiş_duygusal_durum

data = data[,c("kategorize_edilmiş_hareketlilik_durumu","kategorize_edilmiş_duygusal_durum")]

install.packages("HMM")
library(HMM)

baslangıçOlasılıklarınıHesapla <- function(veri_seti) {
  # Başlangıç durumlarını sayma
  baslangic_durumlari <- table(veri_seti$kategorize_edilmiş_duygusal_durum)

  # Başlangıç durumlarının yüzdesel olasılıklarını hesaplama
  baslangic_olasiliklari <- prop.table(baslangic_durumlari) * 100

  # Sonuçları vektör olarak döndürme
  return(baslangic_olasiliklari)
}
başlangıç_olasılıkları_tablosu = baslangıçOlasılıklarınıHesapla(data)


geçişOlasılıklarınıHesapla <- function(veri_seti) {
  # Durum geçişlerini sayma
  durum_gecisleri <- table(veri_seti$kategorize_edilmiş_duygusal_durum[-length(veri_seti$kategorize_edilmiş_duygusal_durum)],
                           veri_seti$kategorize_edilmiş_duygusal_durum[-1])

  # Durum geçişlerinin yüzdesel olasılıklarını hesaplama
  transProbs <- prop.table(durum_gecisleri, margin = 1) * 100

  # Sonuçları matris olarak döndürme
  return(transProbs)
}
geçiş_olasılıkları_tablosu = geçişOlasılıklarınıHesapla(data)

gözlemOlasılıklarınıHesapla <- function(veri_seti) {
  # Durum ve gözlem eşleşmelerini sayma
  durum_gozlem_eşleşmeleri <- table(veri_seti$kategorize_edilmiş_duygusal_durum, veri_seti$kategorize_edilmiş_hareketlilik_durumu)

  # Gözlem durumlarının yüzdesel olasılıklarını hesaplama
  emissionProbs <- prop.table(durum_gozlem_eşleşmeleri, margin = 1) * 100

  # Sonuçları matris olarak döndürme
  return(emissionProbs)
}

gözlem_olasılıkları_tablosu = gözlemOlasılıklarınıHesapla(data)
gözlem_olasılıkları_tablosu


# HMM modelinin Tanımlanması
model <- initHMM(c("Mutlu", "Normal", "Üzgün"),c("Az Hareketli", "Çok Hareketli", "Orta"),
                 startProbs=başlangıç_olasılıkları_tablosu,
                transProbs=geçiş_olasılıkları_tablosu,
                emissionProbs=gözlem_olasılıkları_tablosu )

print(model)

# Tahmin Edilecek Durum Dizisi
tahmin_edilecek_degerler = c("Çok Hareketli","Orta","Çok Hareketli","Az Hareketli","Orta","Orta","Orta")

# Gerçek Durumlar
gercek_degerler = c("Mutlu","Mutlu","Mutlu","Mutlu","Üzgün","Normal","Normal")

# Tahminleme İşleme
viterbi = viterbi(model,tahmin_edilecek_degerler)

hesaplaDoğrulukOranı <- function(gercek_degerler, tahmin_degerler) {
  # İki vektörün uzunluğunu kontrol etme
  if (length(gercek_degerler) != length(tahmin_degerler)) {
    stop("Vektörlerin uzunluğu eşit olmalıdır.")
  }

  # Doğru tahmin sayısını hesaplama
  dogru_tahmin_sayisi <- sum(gercek_degerler == tahmin_degerler)

  # Toplam veri sayısına bölerek doğruluk oranını hesaplama
  dogruluk_orani <- dogru_tahmin_sayisi / length(gercek_degerler)

  # Sonucu döndürme
  return(dogruluk_orani)
}
print(hesaplaDoğrulukOranı(gercek_degerler,viterbi))

