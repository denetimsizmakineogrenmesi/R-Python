# -*- coding: utf-8 -*-
"""
Created on 2023
@author: Doç. Dr. Elif Kartal
@title: Balanced Iterative Reducing and Clustering using Hierarchies (BIRCH) Algoritması
Veri Seti: UCI Machine Learning Data Repository, Facebook Live Sellers in Thailand
https://archive.ics.uci.edu/dataset/488/facebook+live+sellers+in+thailand
"""

# 3.1.1. Python Kütüphanelerinin Hazırlığı
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import Birch
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
from sklearn.metrics import silhouette_score
from sklearn.metrics import calinski_harabasz_score
from sklearn.metrics import davies_bouldin_score


# 3.1.2. Veriyi Okuma
# Bilgisayarda yer alan veri seti okunur

veri = pd.read_csv("Live_20210128.csv", header=0, delimiter=",", usecols=range(3,12))

# 3.1.3. Veri Ön-işleme
# Veri seti özeti incelenir
veri.dtypes
veri.describe()

# z-Score yontemi kullanilarak veri normalizasyonu
sclr = StandardScaler()
veri = sclr.fit_transform(veri)


# 3.1.4. Modelleme

# BIRCH kümeleme modelinin oluşturulması
birch_modeli = Birch(branching_factor = 50, n_clusters = 3, threshold = 1.5)
birch_modeli.fit(veri)

# Küme etiketlerinin elde edilmesi
birch_modeli.labels_
unique, counts = np.unique(birch_modeli.labels_, return_counts=True)


# 3.1.5. Kümelerin PCA kullanılarak görselleştirilmesi
pca = PCA()
veri_pca = pca.fit_transform(veri)

plt.scatter(veri_pca[:, 0], veri_pca[:, 1], c = birch_modeli.labels_, cmap = 'rainbow', alpha = 0.7)
plt.xlabel("Temel Bileşen 1")
plt.ylabel("Temel Bileşen 2")
plt.show()


# 3.1.6. Kümeleme performansının değerlendirilmesi
sil_deg = silhouette_score(veri, birch_modeli.labels_)
calhar_deg = calinski_harabasz_score(veri, birch_modeli.labels_)
davbou_deg = davies_bouldin_score(veri, birch_modeli.labels_)

print("Silhouette Indeks=", np.around(sil_deg,3))
print("Calinski-Harabasz Indeks=", np.around(calhar_deg,3))
print("Davies-Bouldin Indeks=", np.around(davbou_deg,3))

# 3.1.7. Farklı küme sayıları kullanılarak kümeleme performansının değerlendirilmesi

sil_degerleri = []
calhar_degerleri = []
davbou_degerleri = []

for i in np.arange(2,21,1):
    birch_modeli = Birch(branching_factor = 50, n_clusters = i, threshold = 0.5)
    birch_modeli.fit(veri)
    sil_degerleri.append(silhouette_score(veri, birch_modeli.labels_))
    calhar_degerleri.append(calinski_harabasz_score(veri, birch_modeli.labels_))
    davbou_degerleri.append(davies_bouldin_score(veri, birch_modeli.labels_))


###### Sihouette Indeks değerleri için çizgi grafiği
x_values = np.arange(2,21,1)
y_values = np.array(sil_degerleri)

plt.plot(x_values,y_values,marker="D", mfc="pink", mec="darkblue",ms="7")


for x,y in zip(x_values,y_values):
    label = "{:.3f}".format(y)
    plt.annotate(label,
                 (x,y),
                 textcoords="offset points",
                 xytext=(0,10),
                 ha="center",
                 arrowprops=dict(arrowstyle="->", color="hotpink"))
plt.xticks(x_values, x_values)
plt.xlabel("Küme Sayısı")
plt.ylabel("Silhouette Indeks Değerleri")
plt.show()

###### Calinski Harabaz Indeks değerleri için çizgi grafiği
x_values = np.arange(2,21,1)
y_values = np.array(calhar_degerleri)

plt.plot(x_values,y_values,marker="D", mfc="pink", mec="darkblue",ms="7")

for x,y in zip(x_values,y_values):
    label = "{:.3f}".format(y)
    plt.annotate(label,
                 (x,y),
                 textcoords="offset points",
                 xytext=(0,10),
                 ha="center",
                 arrowprops=dict(arrowstyle="->", color="hotpink"))
plt.xticks(x_values, x_values)
plt.xlabel("Küme Sayısı")
plt.ylabel("Calinski Harabaz Indeks Değerleri")
plt.show()

###### Davies Bouldin Indeks değerleri için çizgi grafiği
x_values = np.arange(2,21,1)
y_values = np.array(davbou_degerleri)

plt.plot(x_values,y_values,marker="D", mfc="pink", mec="darkblue",ms="7")

for x,y in zip(x_values,y_values):
    label = "{:.3f}".format(y)
    plt.annotate(label,
                 (x,y),
                 textcoords="offset points",
                 xytext=(0,10),
                 ha="center",
                 arrowprops=dict(arrowstyle="->", color='hotpink'))
plt.xticks(x_values, x_values)
plt.xlabel("Küme Sayısı")
plt.ylabel("Davies Bouldin Indeks Değerleri")
plt.show()