import pandas as pd
data = pd.read_csv("duygusalDurumTahmini.csv")
data.head()

kategorize_edilmiş_hareketlilik_durumu = []
for adım_sayısı in data["step_count"]:
    if adım_sayısı < 2000:
        kategorize_edilmiş_hareketlilik_durumu.append("Az Hareketli")
    elif adım_sayısı >= 2000 and adım_sayısı < 4000:
        kategorize_edilmiş_hareketlilik_durumu.append("Orta")
    elif adım_sayısı >= 4000:
        kategorize_edilmiş_hareketlilik_durumu.append("Çok Hareketli")
data["kategorize_edilmiş_hareketlilik_durumu"] = kategorize_edilmiş_hareketlilik_durumu

kategorize_edilmiş_duygusal_durum = []
for duygusal_durum in data["mood"]:
    if duygusal_durum == 300:
        kategorize_edilmiş_duygusal_durum.append("Mutlu")
    elif duygusal_durum == 200:
        kategorize_edilmiş_duygusal_durum.append("Normal")
    elif duygusal_durum == 100:
        kategorize_edilmiş_duygusal_durum.append("Üzgün")

data["kategorize_edilmiş_duygusal_durum"] = kategorize_edilmiş_duygusal_durum


class SaklıDurum:
    def __init__(self, durum):
        self.durum = durum
        self.gözlem_olasılığı = 0
        self.başlangıç_olasılığı = 0
        self.maks_gerçekleşme_olasılığı = 0

    def gerçekleşmeOlasılığınıAyarla(self, olasılık):
        if self.maks_gerçekleşme_olasılığı < olasılık:
            self.maks_gerçekleşme_olasılığı = olasılık
        return self.maks_gerçekleşme_olasılığı

    def gerçekleşmeOlasılığınıGetir(self):
        return self.gerçekleşme_olasılığını_ayarla


def başlangıçOlasılıklarınıHesapla(veri_seti, saklı_durum_etiketi):
    saklı_durum_verileri = veri_seti[saklı_durum_etiketi]

    durumlar = []
    durum_olasılıkları = saklı_durum_verileri.value_counts(normalize=True)
    for i in durum_olasılıkları.index:
        durumlar.append(i)

    olasılıklar = []
    for i in durum_olasılıkları:
        olasılıklar.append(i)

    başlangıç_olasılık_tablosu = pd.DataFrame()
    başlangıç_olasılık_tablosu["Durum"] = durumlar
    başlangıç_olasılık_tablosu["Olasılık"] = olasılıklar

    return başlangıç_olasılık_tablosu

başlangıç_olasılık_tablosu = başlangıçOlasılıklarınıHesapla(data,"kategorize_edilmiş_duygusal_durum")
başlangıç_olasılık_tablosu


def geçişOlasılıklarınıHesapla(veri_seti, saklı_durum_etiketi):
    saklı_durum_verileri = veri_seti[saklı_durum_etiketi]

    durumlar_arası_geçiş_sözlüğü = {}

    for başlangıç_durumu in saklı_durum_verileri.unique():
        for bitiş_durumu in saklı_durum_verileri.unique():
            durumlar_arası_geçiş_sözlüğü["{}-{}".format(başlangıç_durumu, bitiş_durumu)] = 0

    başlangıç_durumu = ""
    for bitiş_durumu in saklı_durum_verileri:

        if başlangıç_durumu == "":
            başlangıç_durumu = bitiş_durumu

        else:
            geçiş = "{}-{}".format(başlangıç_durumu, bitiş_durumu)
            durumlar_arası_geçiş_sözlüğü[geçiş] += 1

        başlangıç_durumu = bitiş_durumu

    başlangıç_durumları_listesi = []
    bitiş_durumları_listesi = []
    oluşma_sayısı_listesi = []

    for geçiş in durumlar_arası_geçiş_sözlüğü.keys():
        başlangıç_durumları_listesi.append(geçiş.split("-")[0])
        bitiş_durumları_listesi.append(geçiş.split("-")[1])
        oluşma_sayısı_listesi.append(durumlar_arası_geçiş_sözlüğü[geçiş])

    geçiş_olasılıkları_tablosu = pd.DataFrame()
    geçiş_olasılıkları_tablosu["Başlangıç Durumu"] = başlangıç_durumları_listesi
    geçiş_olasılıkları_tablosu["Bitiş Durumu"] = bitiş_durumları_listesi
    geçiş_olasılıkları_tablosu["Oluşma Sayısı"] = oluşma_sayısı_listesi

    oluşma_olasılıkları_listesi = []
    saklı_durum_kategorileri = saklı_durum_verileri.unique()
    for durum in saklı_durum_kategorileri:
        durumun_toplam_oluşma_sayısı = \
        geçiş_olasılıkları_tablosu[geçiş_olasılıkları_tablosu["Başlangıç Durumu"] == durum]["Oluşma Sayısı"].sum()

        for durum_oluşma_sayısı in geçiş_olasılıkları_tablosu[geçiş_olasılıkları_tablosu["Başlangıç Durumu"] == durum][
            "Oluşma Sayısı"]:
            oluşma_olasılıkları_listesi.append(durum_oluşma_sayısı / durumun_toplam_oluşma_sayısı)

    geçiş_olasılıkları_tablosu["Oluşma Olasılığı"] = oluşma_olasılıkları_listesi
    return geçiş_olasılıkları_tablosu

geçiş_olasılıkları_tablosu = geçişOlasılıklarınıHesapla(data,"kategorize_edilmiş_duygusal_durum")
geçiş_olasılıkları_tablosu


def gözlemOlasılıklarınıHesapla(veri_seti, saklı_durum_etiketi, gözlemlenebilir_durum_etiketi):
    saklı_durum_verileri = veri_seti[saklı_durum_etiketi]
    gözlemlenebilir_durum_verileri = veri_seti[gözlemlenebilir_durum_etiketi]

    saklı_durum_listesi = []
    gözlemlenebilir_durum_listesi = []
    oluşma_sayısı_listesi = []

    saklı_durum_kategorileri = saklı_durum_verileri.unique()
    gözlemlenebilir_durum_kategorileri = gözlemlenebilir_durum_verileri.unique()

    veri_seti = pd.concat([saklı_durum_verileri, gözlemlenebilir_durum_verileri], axis=1)

    for saklı_durum in saklı_durum_kategorileri:
        for gözlemlenebilir_durum in gözlemlenebilir_durum_kategorileri:
            koşul_1 = veri_seti[saklı_durum_etiketi] == saklı_durum
            koşul_2 = veri_seti[gözlemlenebilir_durum_etiketi] == gözlemlenebilir_durum

            oluşma_sayısı = veri_seti[(koşul_1) & (koşul_2)][gözlemlenebilir_durum_etiketi].count()

            saklı_durum_listesi.append(saklı_durum)
            gözlemlenebilir_durum_listesi.append(gözlemlenebilir_durum)
            oluşma_sayısı_listesi.append(oluşma_sayısı)

    gözlem_olasılıkları_tablosu = pd.DataFrame()
    gözlem_olasılıkları_tablosu["Saklı Durum"] = saklı_durum_listesi
    gözlem_olasılıkları_tablosu["Gözlemlenebilir Durum"] = gözlemlenebilir_durum_listesi
    gözlem_olasılıkları_tablosu["Oluşma Sayısı"] = oluşma_sayısı_listesi

    oluşma_olasılıkları_listesi = []
    for saklı_durum in saklı_durum_kategorileri:
        durumun_toplam_oluşma_sayısı = \
        gözlem_olasılıkları_tablosu[gözlem_olasılıkları_tablosu["Saklı Durum"] == saklı_durum]["Oluşma Sayısı"].sum()

        for oluşma_sayısı in gözlem_olasılıkları_tablosu[gözlem_olasılıkları_tablosu["Saklı Durum"] == saklı_durum][
            "Oluşma Sayısı"]:
            oluşma_olasılıkları_listesi.append(oluşma_sayısı / durumun_toplam_oluşma_sayısı)

    gözlem_olasılıkları_tablosu["Oluşma Olasılığı"] = oluşma_olasılıkları_listesi

    return gözlem_olasılıkları_tablosu

gözlem_olasılıkları_tablosu = gözlemOlasılıklarınıHesapla(data,"kategorize_edilmiş_duygusal_durum","kategorize_edilmiş_hareketlilik_durumu")
gözlem_olasılıkları_tablosu


class VieribiAlgoritması:
    def __init__(self, saklı_durum_verileri, gözlemlenebilir_durum_verileri, başlangıç_olasılıkları_tablosu,
                 geçiş_olasılıkları_tablosu, gözlem_olasılıkları_tablosu):
        self.saklı_durum_verileri = saklı_durum_verileri
        self.gözlemlenebilir_durum_verileri = gözlemlenebilir_durum_verileri
        self.başlangıç_olasılıkları_tablosu = başlangıç_olasılıkları_tablosu
        self.geçiş_olasılıkları_tablosu = geçiş_olasılıkları_tablosu
        self.gözlem_olasılıkları_tablosu = gözlem_olasılıkları_tablosu

        self.saklı_durum_kategorileri = saklı_durum_verileri.unique()
        self.gözlemlenebilir_durum_kategorileri = gözlemlenebilir_durum_verileri.unique()

    def başlangıçOlasılığınıGetir(self, saklı_durum):
        return self.başlangıç_olasılıkları_tablosu[self.başlangıç_olasılıkları_tablosu["Durum"] == saklı_durum][
            "Olasılık"].values[0]

    def durumlarArasıGeçişOLasılığınıGetir(self, başlangıç_durumu, bitiş_durumu):
        koşul_1 = self.geçiş_olasılıkları_tablosu["Başlangıç Durumu"] == başlangıç_durumu
        koşul_2 = self.geçiş_olasılıkları_tablosu["Bitiş Durumu"] == bitiş_durumu
        return float(self.geçiş_olasılıkları_tablosu[(koşul_1) & (koşul_2)]["Oluşma Olasılığı"])

    def gözlemOlasılığınıGetir(self, saklı_durum, gözlenebilir_durum):
        koşul_1 = self.gözlem_olasılıkları_tablosu["Saklı Durum"] == saklı_durum
        koşul_2 = self.gözlem_olasılıkları_tablosu["Gözlemlenebilir Durum"] == gözlenebilir_durum
        return float(self.gözlem_olasılıkları_tablosu[(koşul_1) & (koşul_2)]["Oluşma Olasılığı"])

    def tahminle(self, tahminlenecek_durumlar):
        zaman_serisi = []
        for gözlemlenebilir_durum_etiketi in tahminlenecek_durumlar:
            zaman = []
            for saklı_durum_etiketi in self.saklı_durum_kategorileri:

                saklı_durum = SaklıDurum(saklı_durum_etiketi)
                saklı_durum.gözlem_olasılığı = self.gözlemOlasılığınıGetir(saklı_durum_etiketi,
                                                                           gözlemlenebilir_durum_etiketi)

                if len(zaman_serisi) < 1:
                    saklı_durum.başlangıç_olasılığı = self.başlangıçOlasılığınıGetir(saklı_durum_etiketi)
                    saklı_durum.gerçekleşmeOlasılığınıAyarla(
                        saklı_durum.başlangıç_olasılığı * saklı_durum.gözlem_olasılığı)

                else:
                    for bir_önceki_saklı_durum in zaman_serisi[len(zaman_serisi) - 1]:
                        geçiş_ihtimali = self.durumlarArasıGeçişOLasılığınıGetir(bir_önceki_saklı_durum.durum,
                                                                                 saklı_durum_etiketi)
                        gerçekleşme_olasılığı = bir_önceki_saklı_durum.maks_gerçekleşme_olasılığı * saklı_durum.gözlem_olasılığı * geçiş_ihtimali
                        saklı_durum.gerçekleşmeOlasılığınıAyarla(gerçekleşme_olasılığı)
                zaman.append(saklı_durum)
            zaman_serisi.append(zaman)

        sonuç = []
        for zaman in zaman_serisi:
            maks_olasılıklı_durum = SaklıDurum("")
            for durum in zaman:
                if maks_olasılıklı_durum.maks_gerçekleşme_olasılığı <= durum.maks_gerçekleşme_olasılığı:
                    maks_olasılıklı_durum = durum
            sonuç.append(maks_olasılıklı_durum.durum)
        return sonuç

viteribi = VieribiAlgoritması(
    saklı_durum_verileri=data["kategorize_edilmiş_duygusal_durum"],
    gözlemlenebilir_durum_verileri= data["kategorize_edilmiş_hareketlilik_durumu"],
    başlangıç_olasılıkları_tablosu= başlangıç_olasılık_tablosu,
    geçiş_olasılıkları_tablosu= geçiş_olasılıkları_tablosu,
    gözlem_olasılıkları_tablosu= gözlem_olasılıkları_tablosu
)

tahmin_edilecek_degerler = ["Çok Hareketli", "Orta", "Çok Hareketli", "Az Hareketli", "Orta", "Orta", "Orta"]
gerçek_değerler = ["Mutlu", "Mutlu", "Mutlu", "Mutlu", "Üzgün", "Normal", "Normal"]

viterbi = viteribi.tahminle(tahmin_edilecek_degerler)


def hesaplaDoğrulukOranı(gercek_degerler, tahmin_degerler):
    dogru_tahmin_sayisi = 0
    for i in range(len(tahmin_degerler)):
        if (gercek_degerler[i] == tahmin_degerler[i]):
            dogru_tahmin_sayisi += 1

    return dogru_tahmin_sayisi / len(tahmin_degerler)


print(hesaplaDoğrulukOranı(gerçek_değerler, viterbi))
