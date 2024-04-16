import sqlite3
import numpy as np
import pandas as pd

conn = sqlite3.connect('FPA_FOD_20170508.sqlite')


# bounding box of colorado
bbox_ll = [36.992426, -109.060253]
bbox_ur = [41.003444, -102.041524] 

#select large (> 1 acre) forest fires in colorado
df = pd.read_sql_query("SELECT latitude, longitude, fire_size, fire_year, discovery_doy FROM fires WHERE latitude > 36.992426 AND latitude < 41.003444 AND longitude > -109.060253 AND longitude < -102.041524 AND fire_size > 1;"
                       , conn)

lats = df['LATITUDE']
lons = df['LONGITUDE']
firesize = df['FIRE_SIZE']
year = df['FIRE_YEAR']
doy = df['DISCOVERY_DOY']

# convert to date and add to df
from datetime import datetime
date = []
for index, row in df.iterrows():
    resdate = datetime.strptime(str(int(row['FIRE_YEAR'])) + "-" + str(int(row['DISCOVERY_DOY'])), "%Y-%j").strftime("%Y-%m-%d")
    date.append(resdate)
    # printing result
    #print("Resolved date : " + str(resdate))
    #print("Latitude : " + str(row['LATITUDE']))
    #print("Longitude : " + str(row['LONGITUDE']))

df['DATE'] = date
df = df.drop(columns=['FIRE_YEAR', 'DISCOVERY_DOY', 'FIRE_SIZE'])

df.to_csv('colorado_wildfires.csv', index=False)
