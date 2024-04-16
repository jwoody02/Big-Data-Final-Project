import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

raw_data = pd.read_csv('forestfires.csv')

raw_data.info()

raw_data.sample(10)

print(raw_data['area'].value_counts())

raw_data.describe()

df = raw_data.drop(columns=['X', 'Y', 'day', 'FFMC', 'DMC', 'DC', 'ISI', 'RH', 'rain'])

df['area'][df['area'] >= 0.01] = 1
df['area'][df['area'] == 0] = 0
month_season_mapping = {'jan': 0, 'feb': 0, 'mar': 1, 'apr': 1, 'may': 1, 'jun': 2, 'jul': 2, 'aug': 2, 'sep': 3, 'oct': 3, 'nov': 3, 'dec': 0}
df['month'] = df['month'].map(month_season_mapping)

print(df.head())

print(df.shape)

X = df.iloc[:,0:3]
print(X)
Y = df.iloc[:,3]
print(Y)

import tensorflow as tf
from tensorflow import keras
from keras.models import Sequential
from keras.layers import Dense

# create model
model = Sequential()
model.add(Dense(20, input_dim=3,  activation='relu')) #1st layer
model.add(Dense(10,  activation='relu')) #2nd layer
model.add(Dense(10,  activation='relu')) #3nd layer
model.add(Dense(1, activation='sigmoid')) #4rd layer or output layer

# Compile model
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

model.summary()

# Fit the model
history = model.fit(X, Y, validation_split=0.33, epochs=100, batch_size=10)

# evaluate the model
scores = model.evaluate(X, Y)
print("%s: %.2f%%" % (model.metrics_names[1], scores[1]*100))

history.history.keys()

# summarize history for accuracy
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('model accuracy')
plt.ylabel('accuracy')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()

# summarize history for loss
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()


#confusion matrix
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import sklearn as sk
import seaborn as sns

p = model.predict(X)
print(p)
print(p.shape)
y=np.where(p > 0.5, 1, 0)
print(y)
print(y.shape)
print(sk.metrics.accuracy_score(Y, y))
data = sk.metrics.confusion_matrix(Y, y)
df_cm = pd.DataFrame(data, columns=np.unique(Y), index = np.unique(Y))
df_cm.index.name = 'Actual'
df_cm.columns.name = 'Predicted'


f, ax = plt.subplots(figsize=(10, 10))
cmap = sns.cubehelix_palette(light=1, as_cmap=True)

sns.heatmap(df_cm, cbar=False, annot=True, cmap=cmap, square=True, fmt='.0f',
            annot_kws={'size': 8})
ax.set_xlabel('True labels') 
ax.set_ylabel('Predicted labels')
ax.set_title('Confusion Matrix') 
ax.xaxis.set_ticklabels(['No risk', 'Fire risk'],rotation=90, fontsize = 8)
ax.yaxis.set_ticklabels(['No risk', 'Fire risk'],rotation=0, fontsize = 8)
plt.show() 

print("Done!")


