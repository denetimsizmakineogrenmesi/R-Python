
# https://prutor.ai/optics-clustering-implementing-using-sklearn/
# https://bobrupakroy.medium.com/optics-clustering-intro-76dcdaf94bde
#https://www.kaggle.com/code/majdikarim/customer-segmentation-using-optics-algorithm


#Adım 1: OPTICS Algoritması İçin Gerekli Kütüphanerin Yüklenmesi:
#####################################################################################
import numpy as np
import pandas as pd
from sklearn.preprocessing import normalize 
from sklearn.cluster import OPTICS
import matplotlib.pyplot as plt
from sklearn.preprocessing import StandardScaler

#Adım 2: Veri Setinin Yüklenmesi:
#####################################################################################

X = pd.read_csv('online_shoppers_intention.csv',sep=",")
#X = pd.read_csv('C:/Users/pc/Documents/online_shoppers_intention.csv',sep=",")
veri=X.copy()

veri.shape

veri.dtypes

#Adım 3: Kümeleme Modeli Kurmadan Önce Veri Üzerinde Ön İşlemler Gerçekleştirilmesi:
#####################################################################################

veri['VisitorType'].replace(["New_Visitor","Other","Returning_Visitor"],
                        [0,1,2], inplace=True)
veri['Month'].replace(["Jan","Feb","Mar","Apr","May","June","Jul","Aug","Sep","Oct","Nov","Dec"],
                        [0,1,2,3,4,5,6,7,8,9,10,11], inplace=True)
veri['Weekend'].replace(["FALSE","TRUE"],
                        [0,1], inplace=True)
veri['Revenue'].replace(["FALSE","TRUE"],
                        [0,1], inplace=True)


veri.dtypes


# Modeldeki  Öznitelikleri Karşılaştırılabilir Bir Düzeye getirmek İçin Değerlerini Standart Olarak Ölçeklendirme:
scaler = StandardScaler()
zscores = scaler.fit_transform(veri)
zscores

veri=pd.DataFrame(zscores)
veri.head()

#Adım 4: Kümeleme Modeli Kurma:
#####################################################################################
epsilon = 4.0
minPts = 30
cluster_method = 'xi'
metric = 'euclidean'

#model = OPTICS(max_eps=epsilon, min_samples=minPts, cluster_method=cluster_method, metric=metric).fit(X)
model = OPTICS(min_samples=minPts,metric=metric) 
model.fit(veri)

# Her gözlemin küme isimlerinin elde edilmesi: 
model.labels_

# Küme seti elde edilmesi
kumeler=set(model.labels_)
kumeler

# Her gözlem için cekirdek_uzaklıkların elde edilmesi: 

cekirdek_uzaklık = model.core_distances_
cekirdek_uzaklık

# Her gözlem için erişilebilirlik uzaklıklarının elde edilmesi: 
erişilebilirlik_uzakligi=model.reachability_
erişilebilirlik_uzakligi


#Adım 5: Erişilebilirlik Uzaklıklarının Görselleştirilmesi:
#####################################################################################
model.reachability_

reachability = model.reachability_[model.ordering_]
plt.plot(reachability)
plt.title('Erişilebilirlik Grafiği')
plt.show() 

#Çekirdek uzaklıklarına göre belirlenen bir eşik değerinden büyük anormal değerleri gösteren küme grafiği:
##########################################################################################################

#eşik değeri hesaplama

cekirdek_uzaklık = model.core_distances_
cekirdek_uzaklık

#eşik değeri hesaplama
from numpy import quantile, where, random
eşik_deger = quantile(cekirdek_uzaklık, .98)
print(eşik_deger) 

#Anormal değerlere (outlier) sahip olan gözlemlerin veri setindeki indeks numaralarını  bulma
indeks = where(cekirdek_uzaklık >= eşik_deger)
indeks

# indeks değerlerine göre verisetindeki kayıtları ele almak için dataframe Numpy array formuna dönüştürüldü
veri_yeni = veri.to_numpy()

outlier = veri_yeni[indeks]
print(outlier)

plt.scatter(veri_yeni[:,0], veri_yeni[:,1])
plt.scatter(outlier[:,0],outlier[:,1], color='r')
plt.legend(("normal", "anomal"), loc="best", fancybox=True, shadow=True)
plt.grid(True)
plt.show()