#!/usr/bin/env python

# Ting Han Gan
# 09/11/21

import pandas as pd
import gspread
import time
import warnings

warnings.filterwarnings('ignore')

############################################################################################################
# ____________________ Region Movement _____________
############################################################################################################

start = time.time()
print("Computing Region Movement Code ...")
glb = pd.read_csv('https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv', engine='python')

# checking the datatypes within the dataframe
# print(glb.dtypes)

# using necessary columns
glb.drop(glb.columns[[0, 2, 3, 4, 5, 6, 7]], axis=1, inplace=True)

glb.head()

glb.columns = ['Country', 'Date', 'RR', 'GP', 'P', 'TS', 'W', 'R']
glb.head()

# ____________________ Daily Results after aggregating in each country and date _____________
flag = False
res_df = pd.DataFrame(columns=['Country', 'Date', 'RR', 'GP', 'P', 'TS', 'W', 'R'], dtype=object)

countries = glb['Country'].unique()

# combining all sub regions within a region into one
for i in countries:
    cur_country = glb[glb['Country'] == i]
    # if there is only one instance per day recorded, i.e., no need to aggregate
    if cur_country.shape[0] > 600:
        # if there exists NAs within a country, then replace with 0
        if cur_country.isnull().values.all():
            cur_country.fillna(0)
        country_mean = cur_country.groupby(['Country', 'Date'], as_index=False).mean()
    else:
        country_mean = cur_country
    if flag == False:
        res_df = country_mean
        flag = True
    else:
        res_df = pd.concat([res_df, country_mean])

# Changing to string and filling na to '' (required to update google sheets)
res_df['Date'] = pd.to_datetime(res_df['Date'])
res_df['Date'] = res_df['Date'].dt.strftime("%Y-%m-%d")
res_df = res_df.fillna('')

# _________ Latest Change for Each Coutry __________________
# current date of each region
current_change = pd.DataFrame(columns=['Country', 'Date', 'RR', 'GP', 'P', 'TS', 'W', 'R'], dtype=object)

for i in countries:
    cur_country = res_df[res_df['Country'] == i]
    current_change = current_change.append(cur_country.iloc[-1])

end = time.time()
print("Completed Computing")
print("Time Taken:", time.strftime("%M:%S", time.gmtime(end - start)), "minutes")
print("______________________________")

# ___________ Updating Google Sheets (current_region_change) _________
print("Updating 'covid-19-live' Google Sheets ...")
gc = gspread.service_account(filename='/Users/tinghan_g/PycharmProjects/covidLive/credentials.json')

# open the google spreadsheet
sh = gc.open_by_key('18MywcUi5qIMGCOuugF3COioX3pwLJJFKfnc1heJuBC4')

# select the first sheet
wks1 = sh.get_worksheet(0)

# update the first sheet with current_change
if current_change.shape[0] > 0:
    wks1.clear()
    wks1.update([current_change.columns.values.tolist()] + current_change.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated 'current_region_change' sheet")
else:
    print("No data found")
# ___________ Updating Google Sheets (daily_region_change) _________
# select the first sheet
wks2 = sh.get_worksheet(1)

# update the second sheet with res_df
if res_df.shape[0] > 0:
    wks2.clear()
    wks2.update([res_df.columns.values.tolist()] + res_df.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'daily_region_change' sheet")
else:
    print("No data found")

print("Completed Updating")
print("______________________________")

############################################################################################################
# ____________________ General Statistics _____________
############################################################################################################

start = time.time()
print("Computing General Statistics Code ...")

world = pd.read_csv('https://covid.ourworldindata.org/data/owid-covid-data.csv', engine='python')

# converting to time (in Google sheets format)
world['date'] = pd.to_datetime(world['date'])
world['date'] = world['date'].dt.strftime("%Y-%m-%d")

# creating new dataframes for each one
world_case = world[['location', 'date', 'total_cases', 'new_cases']]
world_case_mil = world[['location', 'date', 'total_cases_per_million', 'new_cases_per_million']]

world_test = world[['location', 'date', 'total_tests', 'new_tests']]
world_test_thou = world[['location', 'date', 'total_tests_per_thousand', 'new_tests_per_thousand']]

world_deaths = world[['location', 'date', 'total_deaths', 'new_deaths']]
world_deaths_mil = world[['location', 'date', 'total_deaths_per_million', 'new_deaths_per_million']]

world_vac = world[['location', 'date', 'total_vaccinations', 'new_vaccinations']]
world_vac_hundred = world[['location', 'date', 'people_vaccinated_per_hundred', 'people_fully_vaccinated_per_hundred']]

world_string = world[['location', 'date', 'stringency_index']]

# renaming columns
world_case.columns = ['Country', 'Date', 'Total Cases', 'New Cases']
world_case_mil.columns = ['Country', 'Date', 'Total Cases per Million', 'New Cases per Million']

world_test.columns = ['Country', 'Date', 'Total Tests', 'New Tests']
world_test_thou.columns = ['Country', 'Date', 'Total Tests per Thousand', 'New Tests per Thousand']

world_deaths.columns = ['Country', 'Date', 'Total Deaths', 'New Deaths']
world_deaths_mil.columns = ['Country', 'Date', 'Total Deaths per Million', 'New Deaths per Million']

world_vac.columns = ['Country', 'Date', 'Total Vaccinations', 'New Vaccinations']
world_vac_hundred.columns = ['Country', 'Date', 'People Vaccinated per Hundred', 'People Fully Vaccinated per Hundred']

world_string.columns = ['Country', 'Date', 'stringency_index']

# unique countries
countries = world_case['Country'].unique()

# dropping na's and resetting index
world_case = world_case.dropna()
world_case_mil = world_case_mil.dropna()

world_test = world_test.dropna()
world_test_thou = world_test_thou.dropna()

world_deaths = world_deaths.dropna()
world_deaths_mil = world_deaths_mil.dropna()

world_vac = world_vac.dropna()
world_vac_hundred = world_vac_hundred.dropna()

world_string = world_string.dropna()

# resetting index
world_case = world_case.reset_index(drop=True)
world_case_mil = world_case_mil.reset_index(drop=True)

world_test = world_test.reset_index(drop=True)
world_test_thou = world_test_thou.reset_index(drop=True)

world_deaths = world_deaths.reset_index(drop=True)
world_deaths_mil = world_deaths_mil.reset_index(drop=True)

world_vac = world_vac.reset_index(drop=True)
world_vac_hundred = world_vac_hundred.reset_index(drop=True)

world_string = world_string.reset_index(drop=True)

# case new dataframe
case_df = pd.DataFrame(columns=['Country', 'Date', 'Total Cases', 'New Cases'], dtype=object)
cases_df_mil = pd.DataFrame(columns=['Country', 'Date', 'Total Cases per Million', 'New Cases per Million'], dtype=object)

# test new dataframe
test_df = pd.DataFrame(columns=['Country', 'Date', 'Total Tests', 'New Tests'], dtype=object)
test_df_thou = pd.DataFrame(columns=['Country', 'Date', 'Total Tests per Thousand', 'New Tests per Thousand'], dtype=object)

# deaths new dataframe
deaths_df = pd.DataFrame(columns=['Country', 'Date', 'Total Deaths', 'New Deaths'], dtype=object)
death_df_mil = pd.DataFrame(columns=['Country', 'Date', 'Total Deaths per Million', 'New Deaths per Million'], dtype=object)

# vacs new dataframe
vac_df = pd.DataFrame(columns=['Country', 'Date', 'Total Vaccinations', 'New Vaccinations'], dtype=object)
vac_df_hundred = pd.DataFrame(
    columns=['Country', 'Date', 'People Vaccinated per Hundred', 'People Fully Vaccinated per Hundred'], dtype=object)

# stringency_index new dataframe
stringency_df = pd.DataFrame(columns=['Country', 'Date', 'stringency_index'], dtype=object)

new_dfs = [case_df, cases_df_mil, test_df, test_df_thou, deaths_df, death_df_mil, vac_df, vac_df_hundred]
world_dfs = [world_case, world_case_mil, world_test, world_test_thou, world_deaths, world_deaths_mil, world_vac,
             world_vac_hundred]

df_length = len(new_dfs)
# loops through all dfs and append corresponding value for each country
for c in countries:
    for i in range(df_length):
        cur_country = world_dfs[i][world_dfs[i]['Country'] == c]
        if cur_country.shape[0] > 1:
            # identifies the latest non-negative real data
            if (cur_country.iloc[-2][-1] > 10) and (cur_country.iloc[-1][-1] == 0) or (cur_country.iloc[-1][-1] < 0):
                new_dfs[i] = new_dfs[i].append(cur_country.iloc[-2])
            else:
                new_dfs[i] = new_dfs[i].append(cur_country.iloc[-1])

for c in countries:
    cur_country = world_string[world_string['Country'] == c]
    if cur_country.shape[0] > 0:
        stringency_df = stringency_df.append(cur_country.iloc[-1])

# fill na's with '', required for Google Sheets
case_df = new_dfs[0].fillna('')
cases_df_mil = new_dfs[1].fillna('')
test_df = new_dfs[2].fillna('')
test_df_thou = new_dfs[3].fillna('')
deaths_df = new_dfs[4].fillna('')
death_df_mil = new_dfs[5].fillna('')
vac_df = new_dfs[6].fillna('')
vac_df_hundred = new_dfs[7].fillna('')

# removing continents from dataframes (cases and deaths)
remove = ['Asia', 'Europe', 'North America', 'South America', 'Africa', 'Oceania', 'International', 'World']

for i in remove:
    case_df.drop(case_df[case_df.Country == i].index, inplace=True)
    cases_df_mil.drop(cases_df_mil[cases_df_mil.Country == i].index, inplace=True)
    deaths_df.drop(deaths_df[deaths_df.Country == i].index, inplace=True)
    death_df_mil.drop(deaths_df[deaths_df.Country == i].index, inplace=True)
    vac_df.drop(vac_df[vac_df.Country == i].index, inplace=True)
    vac_df_hundred.drop(vac_df_hundred[vac_df_hundred.Country == i].index, inplace=True)

case_df = pd.melt(frame=case_df, id_vars=['Country', 'Date'], var_name='Type', value_name='cases')
cases_df_mil = pd.melt(frame=cases_df_mil, id_vars=['Country', 'Date'], var_name='Type', value_name='casesMil')
test_df = pd.melt(frame=test_df, id_vars=['Country', 'Date'], var_name='Type', value_name='tests')
test_df_thou = pd.melt(frame=test_df_thou, id_vars=['Country', 'Date'], var_name='Type', value_name='testsThou')
deaths_df = pd.melt(frame=deaths_df, id_vars=['Country', 'Date'], var_name='Type', value_name='deaths')
death_df_mil = pd.melt(frame=death_df_mil, id_vars=['Country', 'Date'], var_name='Type', value_name='deathsMil')
vac_df = pd.melt(frame=vac_df, id_vars=['Country', 'Date'], var_name='Type', value_name='vacs')
vac_df_hundred = pd.melt(frame=vac_df_hundred, id_vars=['Country', 'Date'], var_name='Type', value_name='vacsHund')

end = time.time()
print("Completed Computing")
print("Time Taken:", time.strftime("%M:%S", time.gmtime(end - start)), "seconds")
print("______________________________")

# ___________ Updating Google Sheets (cases) _________
print("Updating 'covid-19-general-live' Google Sheets ...")

# open the google spreadsheet
sh = gc.open_by_key('1xijs9caUj9UaTcF4M7sxk9Jtu3RL_a3zuefaZGst1Os')

# select the first sheet (cases)
wks1 = sh.get_worksheet(0)

# update the first sheet with case_df
if case_df.shape[0] > 0:
    wks1.clear()
    wks1.update([case_df.columns.values.tolist()] + case_df.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'cases' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (cases_mil) _________
# select the second sheet (cases_mil)
wks2 = sh.get_worksheet(1)

# update the second sheet with cases_df_mil
if cases_df_mil.shape[0] > 0:
    wks2.clear()
    wks2.update([cases_df_mil.columns.values.tolist()] + cases_df_mil.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated 'cases_mil' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (tests) _________
# select the third sheet (tests)
wks3 = sh.get_worksheet(2)

# update the third sheet with test_df
if test_df.shape[0] > 0:
    wks3.clear()
    wks3.update([test_df.columns.values.tolist()] + test_df.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'tests' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (tests_thou) _________
# select the fourth sheet (tests_thou)
wks4 = sh.get_worksheet(3)

# update the fourth sheet with test_df_thou
if test_df_thou.shape[0] > 0:
    wks4.clear()
    wks4.update([test_df_thou.columns.values.tolist()] + test_df_thou.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated 'tests_thou' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (deaths) _________
# select the fifth sheet (deaths)
wks5 = sh.get_worksheet(4)

# update the fifth sheet with deaths_df
if deaths_df.shape[0] > 0:
    wks5.clear()
    wks5.update([deaths_df.columns.values.tolist()] + deaths_df.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'deaths' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (death_df_mil) _________
# select the sixth sheet (deaths_mil)
wks6 = sh.get_worksheet(5)

# update the sixth sheet with death_df_mil
if death_df_mil.shape[0] > 0:
    wks6.clear()
    wks6.update([death_df_mil.columns.values.tolist()] + death_df_mil.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated 'deaths_mil' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (vacs) _________
# select the seventh sheet (vacs)
wks7 = sh.get_worksheet(6)

# update the seventh sheet with vac_df
if vac_df.shape[0] > 0:
    wks7.clear()
    wks7.update([vac_df.columns.values.tolist()] + vac_df.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'vacs' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (vac_df_hundred) _________
# select the eight sheet (vacs_hundred)
wks8 = sh.get_worksheet(7)

# update the eight sheet with vac_df_hundred
if vac_df_hundred.shape[0] > 0:
    wks8.clear()
    wks8.update([vac_df_hundred.columns.values.tolist()] + vac_df_hundred.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated 'vacs_hundred' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (stringency) _________
# select the ninth sheet (stringency)
wks9 = sh.get_worksheet(8)

# update the ninth sheet with stringency_df
if stringency_df.shape[0] > 0:
    wks9.clear()
    wks9.update([stringency_df.columns.values.tolist()] + stringency_df.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated 'stringency' sheet")
else:
    print("No data found")

print("Completed Updating")
print("______________________________")

############################################################################################################
# ____________________ General Statistics (AUSTRALIA) _____________
############################################################################################################

start = time.time()
print("Computing General Statistics (AUS) Code ...")

au_cumulative = pd.read_csv(
    'https://raw.githubusercontent.com/M3IT/COVID-19_Data/master/Data/COVID_AU_state_cumulative.csv', engine='python')
# converting to time (in Google sheets format)
au_cumulative['date'] = pd.to_datetime(au_cumulative['date'])
au_cumulative['date'] = au_cumulative['date'].dt.strftime("%Y-%m-%d")

au_cumulative_df = au_cumulative[['state', 'date', 'confirmed', 'tests']]
au_cumulative_df.columns = ['State', 'Date', 'Total Cases', 'Total Tests']
au_cumulative_df = au_cumulative_df.tail(8)
au_cumulative_df = pd.melt(frame=au_cumulative_df, id_vars=['State', 'Date'], var_name='Type', value_name='totalCount')

au_daily = pd.read_csv(
    'https://raw.githubusercontent.com/M3IT/COVID-19_Data/master/Data/COVID_AU_state_daily_change.csv', engine='python')

# converting to time (in Google sheets format)
au_daily['date'] = pd.to_datetime(au_daily['date'])
au_daily['date'] = au_daily['date'].dt.strftime("%Y-%m-%d")

au_daily_df = au_daily[['state', 'date', 'confirmed', 'tests']]
au_daily_df.columns = ['State', 'Date', 'New Cases', 'New Tests']
au_daily_df = au_daily_df.tail(8)
au_daily_df = pd.melt(frame=au_daily_df, id_vars=['State', 'Date'], var_name='Type', value_name='dailyCount')

au_vacs = pd.concat([au_cumulative[['state', 'date', 'vaccines']], au_daily['vaccines']], axis=1)
au_vacs.columns = ['State', 'Date', 'Total Vaccines Given', 'New Vaccines Given']
au_vacs = au_vacs.tail(8)
au_vacs = pd.melt(frame=au_vacs, id_vars=['State', 'Date'], var_name='Type', value_name='vacsGiven')

end = time.time()
print("Completed Computing")
print("Time Taken:", end - start, "seconds")
print("______________________________")

# ___________ Updating Google Sheets (au_cumulative) _________
sh = gc.open_by_key('1xijs9caUj9UaTcF4M7sxk9Jtu3RL_a3zuefaZGst1Os')
print("Updating 'covid-19-general-live' Google Sheets ...")

# select the tenth sheet (au_cumulative)
wks10 = sh.get_worksheet(9)

# update the tenth sheet with au_cumulative_df
if au_cumulative_df.shape[0] > 0:
    wks10.clear()
    wks10.update([au_cumulative_df.columns.values.tolist()] + au_cumulative_df.values.tolist(),
                 value_input_option='USER_ENTERED')
    print("Successfully updated 'au_cumulative' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (au_daily) _________
# select the tenth sheet (au_daily)
wks11 = sh.get_worksheet(10)

# update the tenth sheet with au_daily_df
if au_daily_df.shape[0] > 0:
    wks11.clear()
    wks11.update([au_daily_df.columns.values.tolist()] + au_daily_df.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'au_daily' sheet")
else:
    print("No data found")

# ___________ Updating Google Sheets (au_vacs) _________
# select the tenth sheet (au_vacs)
wks12 = sh.get_worksheet(11)

# update the tenth sheet with au_vacs
if au_vacs.shape[0] > 0:
    wks12.clear()
    wks12.update([au_vacs.columns.values.tolist()] + au_vacs.values.tolist(), value_input_option='USER_ENTERED')
    print("Successfully updated 'au_vacs' sheet")
else:
    print("No data found")

print("Completed Updating")
print("______________________________")