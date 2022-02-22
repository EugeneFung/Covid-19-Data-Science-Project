import pandas as pd
import wget

# Download datasets
url = 'https://raw.githubusercontent.com/M3IT/COVID-19_Data/master/Data/COVID19_Data_Hub.csv'
wget.download(url)

dataset = pd.read_csv('COVID19_Data_Hub.csv')
dataset = dataset.drop('administrative_area_level', axis=1)
dataset = dataset.drop('administrative_area_level_1', axis=1)
dataset = dataset.drop('administrative_area_level_3', axis=1)
dataset = dataset.drop('population', axis=1)
dataset = dataset.drop('id', axis=1)
dataset['active'] = dataset['confirmed'] - dataset['deaths'] - dataset['recovered']
dataset = dataset.rename({'administrative_area_level_2' : 'state'}, axis=1)
dataset = dataset[['date', 'confirmed', 'deaths', 'recovered', 'active', 'tests', 'positives', 'hosp', 'icu', 'vent', 'vaccines', 'state']]

# Australia 
aus = dataset.iloc[0:555, 0:11]

aus.to_csv('C:.../aus_full.csv', index=False)

# Victoria
vic = dataset.loc[dataset['state'] == 'Victoria']

# New South Wales
nsw = dataset.loc[dataset['state'] == 'New South Wales']

# Western Australia
wa = dataset.loc[dataset['state'] == 'Western Australia']

# South Australia
sa = dataset.loc[dataset['state'] == 'South Australia']

# Northern Territory
nt = dataset.loc[dataset['state'] == 'Northen Territory']

# Queensland
qld = dataset.loc[dataset['state'] == 'Queensland']

# Tasmania
tas = dataset.loc[dataset['state'] == 'Tasmania']
