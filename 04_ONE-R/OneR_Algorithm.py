#!/usr/bin/env python
# coding: utf-8

# # One Rule (OneR) Algorithm

# ## Define Libraries

# In[1]:


import pandas as pd
import numpy as np

from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn import metrics
from sklearn.metrics import classification_report

from mlxtend.classifier import OneRClassifier

import matplotlib.pyplot as plt
import seaborn as sns

import warnings
warnings.filterwarnings('ignore')


# ## Data Import

# In[2]:


veri = pd.read_csv('Churn_Data.csv')
veri


# ## Data Preprocessing

# In[3]:


veri = veri.set_index('customer_id')
display(veri)


# In[4]:


veri.drop(['country', 'estimated_salary', 'balance'], axis=1, inplace=True)


# In[5]:


veri.info()
veri.isna().sum()


# In[6]:


lencoders = {}
for col in veri.select_dtypes(include=['object']).columns:
    lencoders[col] = LabelEncoder()
    veri[col] = lencoders[col].fit_transform(veri[col])


# In[7]:


veri['churn'] = veri['churn'].map({0: 'NonChurn', 1: 'Churn'})


# In[8]:


sns.set(font_scale=1.2) 
sns.countplot(data=veri, x='churn',
              order = veri['churn'].value_counts().index).set(title='Veri Seti Hedef Değişken Dağılımı\n',
                                                              ylim=(0, 10000))
veri.churn.value_counts()


# In[9]:


veri.describe()


# In[10]:


display(veri)


# ## Correlation

# In[11]:


features = veri.drop(['churn'], axis=1)

display(features.corr())
  
sns.set(font_scale=1.1) 
plt.subplots(figsize=(12, 7))

dataplot = sns.heatmap(features.corr().round(2), vmin=-1, vmax=1, cmap="YlGnBu", annot=True,
                      fmt=".2f",
            annot_kws={'fontsize': 12, 
                       'fontweight': 'bold',
                       'fontfamily': 'serif'})

plt.title('Pearson Correlation Coefficient', fontsize=15)
plt.show()


# ## Data Partition

# In[12]:


X = veri.iloc[:, 0:7].to_numpy()   #öznitelikler
y = veri.iloc[:, -1].to_numpy()    #hedef değişken


# In[13]:


X_eğitim, X_test, y_eğitim, y_test = train_test_split(X, y,  test_size = 0.20, random_state=0, stratify=y)


# In[14]:


eğitim_df = pd.concat([pd.DataFrame(X_eğitim),
                      pd.DataFrame(y_eğitim)], axis=1)

eğitim_df.columns = ['credit_score', 'gender', 'age', 'tenure', 'products_number',
                    'credit_card', 'active_member', 'churn']

sns.set(font_scale=1.2) 
sns.countplot(data=eğitim_df, x='churn').set(title='Eğitim Veri Seti Hedef Değişken Dağılımı\n', ylim=(0, 7000))
eğitim_df.churn.value_counts()


# In[15]:


test_df = pd.concat([pd.DataFrame(X_test),
                     pd.DataFrame(y_test)], axis=1)

test_df.columns = ['credit_score', 'gender', 'age', 'tenure', 'products_number',
                    'credit_card', 'active_member', 'churn']

sns.set(font_scale=1.2) 
sns.countplot(data=test_df, x='churn').set(title='Test Veri Seti Hedef Değişken Dağılımı\n', ylim=(0, 2000))
test_df.churn.value_counts()


# In[16]:


y_eğitim = np.vectorize({'NonChurn' : 0, 'Churn': 1}.get)(y_eğitim).astype('int64')
y_test = np.vectorize({'NonChurn' : 0, 'Churn': 1}.get)(y_test).astype('int64')


# ## OneR Model

# In[17]:


oner = OneRClassifier()

oner.fit(X_eğitim, y_eğitim)


# In[18]:


oner.feature_idx_


# In[19]:


pd.DataFrame(X_eğitim)


# In[20]:


oner.prediction_dict_


# In[21]:


print("Eğitim verisi tahminleri: ", oner.predict(X_eğitim))


# In[22]:


Eğitim_KM = metrics.confusion_matrix(y_eğitim, oner.predict(X_eğitim))

Eğitim_KM_Label = pd.DataFrame(Eğitim_KM)
Eğitim_KM_Label.columns = ['Tahminde NonChurn',
                           'Tahminde Churn']
Eğitim_KM_Label = Eğitim_KM_Label.rename(index ={0: 'Gerçekte NonChurn',
                                                 1: 'Gerçekte Churn'})

print('\033[1m' + "Eğitim Verisine Ait Karışıklık Matrisi" + '\033[0m')
Eğitim_KM_Label


# In[23]:


plt.subplots(figsize=(7, 5))

Eğitim_KM_Prc = sns.heatmap(Eğitim_KM/np.sum(Eğitim_KM),
                            annot=True,
                            fmt='.2%',
                            cmap='Blues')

Eğitim_KM_Prc.set_xlabel('\nTahmin Değerler\n')
Eğitim_KM_Prc.set_ylabel('\nGerçek Değerler')

Eğitim_KM_Prc.xaxis.set_ticklabels(['NonChurn','Churn'])
Eğitim_KM_Prc.yaxis.set_ticklabels(['NonChurn','Churn'])

plt.title('\nEğitim Verisine Ait Karışıklık Matrisinin Yüzdesel Gösterimi\n',
          fontsize=15)
plt.show()


# In[24]:


train_acc = oner.score(X_eğitim, y_eğitim)
print(f'Eğitim için doğruluk oranı: {train_acc*100:.2f}%')


# ## TEST

# In[25]:


print("Test verisi tahminleri: ",oner.predict(X_test))


# In[26]:


Test_KM = metrics.confusion_matrix(y_test, oner.predict(X_test))

Test_KM_Label = pd.DataFrame(Test_KM)
Test_KM_Label.columns = ['Tahminde NonChurn',
                         'Tahminde Churn']
Test_KM_Label = Test_KM_Label.rename(index ={0: 'Gerçekte NonChurn',
                                             1: 'Gerçekte Churn'})

print('\033[1m' + "Test Verisine Ait Karışıklık Matrisi" + '\033[0m')
Test_KM_Label


# In[27]:


plt.subplots(figsize=(7, 5))
Test_KM_Prc = sns.heatmap(Test_KM/np.sum(Test_KM),
                          annot=True,
                          fmt='.2%',
                          cmap='Blues')

Test_KM_Prc.set_xlabel('\nTahmin Değerler\n')
Test_KM_Prc.set_ylabel('\nGerçek Değerler')

Test_KM_Prc.xaxis.set_ticklabels(['NonChurn','Churn'])
Test_KM_Prc.yaxis.set_ticklabels(['NonChurn','Churn'])

plt.title('\nTest Verisine Ait Karışıklık Matrisinin Yüzdesel Gösterimi\n', fontsize=15)
plt.show()


# In[28]:


test_acc = oner.score(X_test, y_test)
print(f'Test için doğruluk oranı: {test_acc*100:.2f}%')


# In[29]:


Sınıflar = ['NonChurn', 'Churn']
print(classification_report(y_test,
                            oner.predict(X_test),
                            target_names=Sınıflar))

