import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

raw_data = pd.read_csv('forestfires.csv')

raw_data.info()

raw_data.sample(10)

print(raw_data['area'].value_counts())

raw_data.describe()

df = raw_data.drop(columns=['X', 'Y', 'month', 'day', 'FFMC', 'DMC', 'DC', 'ISI', 'RH', 'rain'])

df['area'][df['area'] >= 0.01] = '1'
df['area'][df['area'] == 0] = '0'
print(df.head())

print(df.shape)

X = df.iloc[:,0:2]
print(X)
Y = df.iloc[:,2]
print(Y)

import tensorflow as tf
from tensorflow import keras
from keras.models import Sequential
from keras.layers import Dense

# create model
model = Sequential()
model.add(Dense(20, input_dim=28,  activation='relu')) #1st layer
model.add(Dense(10,  activation='relu')) #2nd layer
model.add(Dense(10,  activation='relu')) #3nd layer
model.add(Dense(1, activation='sigmoid')) #4rd layer or output layer

# Compile model
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

model.summary()

# Fit the model
history = model.fit(X, Y, validation_split=0.33, epochs=250, batch_size=10)

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


