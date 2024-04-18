import pandas as pd
import math
import datetime
from datetime import timedelta
import urllib.request
import json

inputdata=pd.read_csv('colorado_wildfires.csv')
file = open("Weather_API_Key.txt", "r")
weather_api_key = file.readline()
print(weather_api_key)
file.close()

records=[]
labels = ['month', 'temp' ,'RH', 'wind', 'area'] 
maxRowsToProcess = 6000
area=1 #active fire

for i, row in inputdata.iterrows(): 
    #check maximum rows to process and stop if necessary
    if maxRowsToProcess>0 and i>maxRowsToProcess:
        print("Maximum rows processed. Ending: {}/{}".format(maxRowsToProcess, len(inputdata.index)))
        break
    #print a status update every row
    if (i%100==0):
        print("Processing row {}/{}. records size={}".format(i+1,len(inputdata.index), len(records)))

    #read the latitude, longitude and date from the source data
    latitude=row['LATITUDE']
    longitude=row['LONGITUDE']
    datetimeStr=row['DATE']
    newdatetimeStr=datetimeStr+'T13:00:00'

    #check that the date_time are valid. skip row if necessary
    try:
        date_time=datetime.datetime.strptime(datetimeStr, '%Y-%m-%d')
        month = date_time.month
    except ValueError:
        print("Bad date format {}".format(datetimeStr))
        continue

    #Request data using Timeline Weather API specific time request.
    #See https://www.visualcrossing.com/resources/documentation/weather-api/timeline-weather-api/ "Specific Time Request Example" for more information. 

    weatherApiQuery = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/{},{}/{}?key={}&include=current'
    weatherApiQuery=weatherApiQuery.format(latitude,longitude,newdatetimeStr,weather_api_key)

    try:
        response = urllib.request.urlopen(weatherApiQuery)
        data = response.read()
    except urllib.error.HTTPError  as e:
        ErrorInfo= e.read().decode() 
        print('Error code: ', e.code, ErrorInfo)
        continue
    except  urllib.error.URLError as e:
        ErrorInfo= e.read().decode() 
        print('Error code: ', e.code,ErrorInfo)
        continue

    #parse the response JSON
    weatherDataJson = json.loads(data.decode('utf-8'))

    #read exact time weather data from the 'currentConditions' JSON property
    weatherData=weatherDataJson["currentConditions"]

    #create an output row using the crash and weather data
    if weatherData["temp"] == None or weatherData["windspeed"] == None:
        continue
    temp = (weatherData["temp"] - 32.0)/9.0*5.0 #convert to celcius
    windspeed = weatherData["windspeed"]*1.609344 #convert to kmph
    records.append((month, temp, weatherData["humidity"], windspeed, area))

output_df = pd.DataFrame.from_records(records, columns=labels)
output_df.to_csv('output_weather.csv', index=False) 
print('done')