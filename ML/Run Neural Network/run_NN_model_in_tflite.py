import pandas as pd
import numpy as np
import tensorflow as tf

# read input data that had been stored in a csv file 
# (this is just an illustration; the IOS forest fire prediction app will likely pass the input data in a different manner)
df = pd.read_csv('input_from_IOS_app.csv')
monthnum_season_mapping = {1: 0, 2: 0, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 3, 10: 3, 11: 3, 12: 0}
df['month'] = df['month'].map(monthnum_season_mapping)
X = df.iloc[:,0:4]

# test read the saved TF Lite model
with open('NN_model.tflite', 'rb') as fid:
    tflite_model = fid.read()

# Load the TFLite model and allocate tensors
interpreter = tf.lite.Interpreter(model_content=tflite_model)
interpreter.allocate_tensors()

# Get input and output tensors
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# run the TFLite model to predict the fire risk (0: No risk; 1: Fire risk)
input_shape = input_details[0]['shape']
input_data = X.to_numpy()
input_data = np.float32(input_data)
print(input_data)
interpreter.set_tensor(input_details[0]['index'], input_data)
interpreter.invoke()
p = interpreter.get_tensor(output_details[0]['index'])
print(p)
y=np.where(p > 0.5, 1, 0)
print(y)
