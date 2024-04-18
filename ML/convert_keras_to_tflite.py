import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow import keras

# read input data that had been stored in a csv file 
# (this is just an illustration; the IOS forest fire prediction app will likely pass the input data in a different manner)
df = pd.read_csv('input_from_IOS_app.csv')
monthnum_season_mapping = {1: 0, 2: 0, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 3, 10: 3, 11: 3, 12: 0}
df['month'] = df['month'].map(monthnum_season_mapping)
X = df.iloc[:,0:4]

# load the trained keras NN model
model = keras.models.load_model('NN_model.keras')

# Convert a tf.Keras model to a TensorFlow Lite model and save it in a file
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model_1 = converter.convert()
with open('NN_model.tflite', 'wb') as o_:
    o_.write(tflite_model_1)
