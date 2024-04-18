import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from tensorflow import keras
from keras.models import Sequential
from keras.layers import Dense

# read input data that had been stored in a csv file 
# (this is just an illustration; the IOS forest fire prediction app will likely pass the input data in a different manner)
df = pd.read_csv('input_weather.csv')
monthnum_season_mapping = {1: 0, 2: 0, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 3, 10: 3, 11: 3, 12: 0}
df['month'] = df['month'].map(monthnum_season_mapping)
X = df.iloc[:,0:4]

# load the trained NN model
model = keras.models.load_model('NN_model.keras')

# run the model to predict the fire risk (0: No risk; 1: Fire risk)
p = model.predict(X)
y=np.where(p > 0.5, 1, 0)
print(y)
