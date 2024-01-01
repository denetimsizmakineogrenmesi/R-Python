# Algorithm: Self-Organizing Map (SOM)
# Dataset: https://www.kaggle.com/datasets/ajaypalsinghlo/world-happiness-report-2023
# Author: Dr. Zeki OZEN
# Date: August 2023


# gerekli kutuphaneler yukleniyor
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import plotly.graph_objs as go
from minisom import MiniSom
from plotly.offline import init_notebook_mode, plot
from sklearn.preprocessing import StandardScaler

init_notebook_mode(connected=True)

pd.set_option('display.width', 400)
pd.set_option('display.max_columns', 10)

import warnings
warnings.filterwarnings("ignore")


# veri seti okunuyor
df = pd.read_csv('whr2023.csv')

# yalnizca gerekli oznitelikler aliniyor
df = df[['Country name',
         'Happiness score',
         'Logged GDP per capita',
         'Social support',
         'Healthy life expectancy',
         'Freedom to make life choices',
         'Generosity',
         'Perceptions of corruption']]

# nitelik isimlerindeki bosluklar nokta karakteriyle degistiriliyor
df.columns = df.columns.str.replace(' ', '.')
# Ulkemizin adi veri setinde degistiriliyor
df['Country.name'] = df['Country.name'].str.replace('Turkiye', 'Turkey', regex=True)

print(df.info())
# mukerrer veri kontrolu yapiliyor
print(df.loc[df.duplicated()])
# kayip deger kontrolu yapiliyor
print(df.isnull().sum())
# kayip deger olan satirlar veri setinden siliniyor
df = df.dropna()
# tekrar kayip deger kontrolu yapiliyor
print(df.isnull().sum())
# veri setinin satir ve sutun bilgisi aliniyor
print(df.shape)
# veri seti hakkinda istatistik bilgisi elde ediliyor
print(df.describe().T)

# Veri seti Z-Score yontemiyle olcekleniyor
scaling = StandardScaler()
# Yalnizca analizde kullanilacak 6 nitelik olcekleniyor
df_scaled = scaling.fit_transform(df.loc[:, ~df.columns.isin(['Country.name', 'Happiness.score'])])

# SOM algoritmasinin topolojisi kume sayisina gore belirleniyor
som_shape = (1, 3)
# SOM algoritmasinin parametreleri veriliyor
som = MiniSom(x=som_shape[0], y=som_shape[1],
              input_len=df_scaled.shape[1],
              sigma=0.5,
              learning_rate=0.5,
              neighborhood_function='gaussian',
              topology='rectangular',
              activation_distance='euclidean',
              random_seed=123)
# Algoritmaya kullanacagi veri seti veriliyor
som.pca_weights_init(df_scaled)
# SOM algoritmasi egitiliyor
som.train(data=df_scaled,
          num_iteration=1000,
          random_order=True,
          verbose=True)

win_map = som.win_map(df_scaled)

print(som.distance_map())
# hangi kumede kac eleman oldugu elde ediliyor
frequencies = som.activation_response(df_scaled)
print(f'Kume eleman sayilari:\n {np.array(frequencies, np.uint)}')

# her bir satirin hangi kumede oldugu belirleniyor
winner_coordinates = np.array([som.winner(x) for x in df_scaled]).T
cluster_index = np.ravel_multi_index(winner_coordinates, som_shape)
# kume bilgisi veri setine kaydediliyor
df["cluster"] = cluster_index.tolist()
karsilastirma_verisi = df.loc[:, ['Country.name', 'Happiness.score', 'cluster']]
print(karsilastirma_verisi)

# Kume merkezi ve kume elemanlarinin sacilim grafigi cizdiriliyor
plt.figure(figsize=(10, 8))
for c in np.unique(cluster_index):
    plt.scatter(df_scaled[cluster_index == c, 0],
                df_scaled[cluster_index == c, 1], label='cluster=' + str(c), alpha=.7)

for centroid in som.get_weights():
    plt.scatter(centroid[:, 0], centroid[:, 1], marker='x',
                s=10, linewidths=20, color='k')

plt.title("Kume Merkezleri")
plt.legend()
plt.show()

# Ulkeler ve ait olduklari kumelerin dunya haritasinda grafigi cizdiriliyor
data = dict(type='choropleth',
            locations=df['Country.name'],
            locationmode='country names',
            z=df["cluster"],
            text=df['Country.name'],
            colorbar={'title': 'Kume Gruplari'})

layout = dict(title=dict(
    text="Dunya Mutluluk Raporu 2023 - SOM Algoritmasi",
    font=dict(size=24),
    x=0.5,
    xref="paper"
),
    geo=dict(showframe=False,
             projection={'type': 'natural earth'}))

choromap = go.Figure(data=data, layout=layout)
plot(choromap)
