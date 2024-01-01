#K-MEDOIDS CLUSTERING ALGORITHM

##Define Libraries

import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn_extra.cluster import KMedoids
from yellowbrick.cluster import KElbowVisualizer
from sklearn.mixture import GaussianMixture
from sklearn.metrics import silhouette_score
import matplotlib.pyplot as plt
import plotly.express as px
import seaborn as sns
import scipy.cluster.hierarchy as shc
import geopandas as gpd
import warnings
warnings.filterwarnings('ignore')

##Data Import

veri = pd.read_csv("C:/Users/topra/Desktop/Unsupervised_Learning/Data/world-happiness-report-2021.csv")

##Data Preprocessing
#veri.drop(['Regional indicator', 'Ladder score', 'Standard error of ladder score', 'upperwhisker', 'lowerwhisker',
# 'Ladder score in Dystopia', 'Explained by: Log GDP per capita', 'Explained by: Social support',
# 'Explained by: Healthy life expectancy', 'Explained by: Freedom to make life choices',
# 'Explained by: Generosity', 'Explained by: Perceptions of corruption','Dystopia + residual'], axis=1, inplace=True)

veri = veri[['Country name', 'Logged GDP per capita',
 'Social support','Healthy life expectancy',
 'Freedom to make life choices','Generosity',
 'Perceptions of corruption']]

veri.info()
veri.isna().sum()


veri.columns = [c.replace(' ', '_') for c in veri.columns]


veri = veri.set_index('Country_name')
display(veri)

veri.describe()

##Standardization of Data
scaled_veri = StandardScaler().fit_transform(veri)
scaled_veri_df = pd.DataFrame(scaled_veri, columns=[
 'Logged_GDP_per_capita', 'Social_support',
 'Healthy_life_expectancy', 'Freedom_to_make_life_choices',
 'Generosity', 'Perceptions_of_corruption'])


##Finding the Optimal Number of Clusters

### Silhouette Method
visualizer = KElbowVisualizer(KMedoids(), k=(2,10),metric='silhouette', timings= True)
visualizer.fit(scaled_veri)
visualizer.show()

### Elbow Method
visualizer = KElbowVisualizer(KMedoids(), k=(2,10), timings= True)
visualizer.fit(scaled_veri)
visualizer.show()


### Calinski Harabasz Method
visualizer = KElbowVisualizer(KMedoids(), k=(2,10), metric='calinski_harabasz', timings= True)
visualizer.fit(scaled_veri)
visualizer.show()

### AIC and BIC Method
aic_score = {}
bic_score = {}
for i in range(1,11):
 gmm = GaussianMixture(n_components=i, random_state=0).fit(scaled_veri)
 aic_score[i] = gmm.aic(scaled_veri)
 bic_score[i] = gmm.bic(scaled_veri)
plt.plot(list(aic_score.keys()),list(aic_score.values()), label='AIC')
plt.plot(list(bic_score.keys()),list(bic_score.values()), label='BIC')
plt.legend(loc='best')
plt.title('AIC and BIC from GMM')
plt.xlabel('Number of Clusters')
plt.ylabel('AIC and BIC values')
plt.show()

### Dendogram for Heirarchical Clustering
plt.figure(figsize=(10, 7)) 
plt.title("Dendogram for Heirarchical Clustering") 
dend = shc.dendrogram(shc.linkage(scaled_veri, method='ward'))


##APPLICATION
KMedoids = KMedoids(n_clusters=3, random_state=0, method='pam')
KMedoids = KMedoids.fit(scaled_veri)

print('Küme Sonuçları:', KMedoids.labels_)

print('Küme Medoidleri: ', KMedoids.cluster_centers_)

print('Medoid indeksleri:', KMedoids.medoid_indices_)

print(f'Silhouette Score: {silhouette_score(scaled_veri, KMedoids.labels_)}')

# "Country_name"’in dataframe de indeksten çıkarılması
veri.reset_index(inplace=True)
scaled_veri_df.insert(0, 'Country_name', veri.Country_name)
#kümelerin dataya eklenmesi
küme_veri = scaled_veri_df
küme_veri.insert(0, 'KMedoids_Cluster_Labels', KMedoids.labels_)

sns.countplot(data=küme_veri, x='KMedoids_Cluster_Labels')
küme_veri.KMedoids_Cluster_Labels.value_counts()

print(küme_veri)

## K-Medoids Cluster Plot
fig = px.scatter(küme_veri,
 x=scaled_veri[:,0],
 y=scaled_veri[:,1],
 text="Country_name",
 labels={
 "x": "Dim1",
 "y": "Dim2",
 "KMedoids_Cluster_Labels": "K-Medoids Cluster Label"
},
 color="KMedoids_Cluster_Labels")
fig.update_traces(textposition='top center', marker=dict(size=10))
fig.update_layout(title_text='K-Medoids Cluster', title_x=0.5)
fig.show()


## K-Medoids Cluster World Map
world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres'))
world['name'] = world['name'].replace({
 'Bosnia and Herz.':'Bosnia and Herzegovina',
'Congo':'Congo (Brazzaville)',
'Czechia':'Czech Republic',
'Dominican Rep.':'Dominican Republic',
'N. Cyprus':'North Cyprus',
'Palestine':'Palestinian Territories',
'eSwatini':'Swaziland',
'Taiwan':'Taiwan Province of China',
'United States of America':'United States'
})
#Dünya Haritası verisini uygulama verisi ile birleştirme
km_worldmap = world.merge(küme_veri[['KMedoids_Cluster_Labels','Country_name']],
 left_on='name', right_on='Country_name', how='left')

### K-medoids Cluster World Map - v1
fig = px.choropleth(km_worldmap,
 locations="iso_a3",
 color="KMedoids_Cluster_Labels",
hover_name="name",)
fig.show()

### K-medoids Cluster World Map - v2
km_worldmap.plot('KMedoids_Cluster_Labels', cmap='brg', legend=True, figsize=(17,10))

### K-medoids Cluster World Map - v3
km_worldmap.explore(column='KMedoids_Cluster_Labels',cmap='brg')
