#!/usr/bin/env python

# Ting Han Gan
# 20/09/21
# Used to update new and expired exposure sites
import datetime as datetime
import pandas as pd
from geopy.geocoders import Nominatim
import gspread
import re
import time
import warnings
from datetime import datetime
import hashlib

warnings.filterwarnings('ignore')

start = time.time()
print("Computing exposure site Code ...")

df_current = pd.read_csv(
    "https://docs.google.com/spreadsheets/d/1MG6_S_tZLFPQiVjZJYK7J6MoeOPYIHb-F7r7kPCK6Vo/gviz/tq?tqx=out:csv&sheet=Sheet1",
    engine='python')
df_new = pd.read_csv("https://drive.google.com/uc?export=download&id=1hULHQeuuMQwndvKy1_ScqObgX0NRUv1A",
                     engine='python')

# drop null values in Site_postcode and Site_streetaddress from both datasets
df_current = df_current[df_current['Site_postcode'].notna()]
df_current = df_current[df_current['Site_streetaddress'].notna()]

df_new = df_new[df_new['Site_postcode'].notna()]
df_new = df_new[df_new['Site_streetaddress'].notna()]


# change 'Site_postcode' to be int
df_current["Site_postcode"] = df_current["Site_postcode"].astype(int)
df_new["Site_postcode"] = df_new["Site_postcode"].astype(int)

df_new["full_address"] = df_new["Site_streetaddress"] + ', ' + df_new["Suburb"] + ', ' + \
                                df_new["Site_state"] + ', ' + df_new[
                                    "Site_postcode"].astype(str)

# creates unique identifier for the df_new
uid = []
for i in range(len(df_new)):
    current = df_new.iloc[i]['full_address']
    uid.append(int(hashlib.sha1(current.encode("utf-8")).hexdigest(), 16) % (10 ** 8))

df_new['dhid'] = uid
df_new['dhid'] = df_new['dhid'].astype(str)

# find the unique locations of combined both datasets based on 'dhid'
# result: new exposure sites, expired exposure sites
df_current['dhid'] = df_current['dhid'].astype(str)
unique_locations = list(set(df_current['dhid'].unique()).symmetric_difference(set(df_new['dhid'].unique())))

# checks if there are any expired or new locations
if len(unique_locations) > 0:
    # retrieve the rows of new exposure sites and expired exposure sites
    unique_locations = [x for x in unique_locations if str(x) != 'nan']
    unique_locations = [str(x) for x in unique_locations]

    new_locations = pd.DataFrame()
    for i in unique_locations:
        if len(df_new[df_new['dhid'].str.contains(i)]) >= 1:
            new_locations = new_locations.append(df_new[df_new['dhid'].str.contains(i)])
        if len(df_current[df_current['dhid'].str.contains(i)]) >= 1:
            new_locations = new_locations.append(df_current[df_current['dhid'].str.contains(i)])

    # subsetting the dataframe to new and expired
    if new_locations.shape[0] > 0:
        new_exposures = new_locations.loc[(new_locations['Added_date'] == (str(datetime.today().strftime('%d/%m/%Y'))))]
        expired_exposures = new_locations.loc[
            (new_locations['Added_date'] != (str(datetime.today().strftime('%d/%m/%Y'))))]


        # remove expired exposures from current dataframe (google sheets)
        df_current = pd.concat([df_current, expired_exposures])
        df_current = df_current.drop_duplicates(keep=False)

        # perform geocoding on new exposure sites
        geolocator = Nominatim(user_agent="my_user_agent")

        # regular expression for a typical address
        addressRegex = re.compile(r'([1-9][0-9]*[a-z]?)?(( \w+)|([a-z]\w+-\w+))*,( \w+)+,( \w+), [0-9]{4}')

        lat = []
        long = []
        last_address = ""
        flag = False

        for i in new_exposures["full_address"]:
            current_address = i
            if (current_address == last_address) & flag:
                lat.append(loc.latitude)
                long.append(loc.longitude)
            else:
                try:
                    # perform geocode on the regular expression address
                    loc = geolocator.geocode(addressRegex.search(i).group())
                except AttributeError:
                    print("Error:", i)
                if loc is not None:
                    lat.append(loc.latitude)
                    long.append(loc.longitude)
                    flag = True
                else:
                    lat.append('')
                    long.append('')
                    flag = False
            last_address = i

        new_exposures["latitude"] = lat
        new_exposures["longitude"] = long
        new_exposures["Site_postcode"] = new_exposures["Site_postcode"].astype(int)

        # combining new exposure sites with current dataframe
        df_current = pd.concat([df_current, new_exposures])
        df_current = df_current.fillna('')
        df_current["Site_postcode"] = df_current["Site_postcode"].astype(int)

        # sort by post code
        df_current = df_current[['Suburb', 'Site_title', 'Site_streetaddress', 'Site_state', 'Site_postcode', 'Exposure_date_dtm',
                                 'Exposure_date', 'Exposure_time', 'Notes', 'Added_date_dtm', 'Added_date', 'Added_time',
                                 'Advice_title', 'Advice_instruction', 'Exposure_time_start_24', 'Exposure_time_end_24',
                                 'dhid', 'full_address', 'latitude', 'longitude']]
        df_current.sort_values(['Site_postcode'], inplace=True, ascending=True)

        # ___________ Updating Google Sheets (Sheet1) _________

        print("Updating 'exposure_site' Google Sheets ...")
        gc = gspread.service_account(filename='/Users/tinghan_g/PycharmProjects/exposureSites/credentials.json')

        # open the google spreadsheet
        sh = gc.open_by_key('1MG6_S_tZLFPQiVjZJYK7J6MoeOPYIHb-F7r7kPCK6Vo')

        # select the first sheet
        wks1 = sh.get_worksheet(0)

        # update the first sheet
        if df_current.shape[0] > 0:
            wks1.clear()
            wks1.update([df_current.columns.values.tolist()] + df_current.values.tolist(),
                        value_input_option='USER_ENTERED')
            print("Successfully updated sheet.")
        else:
            print("No data found.")

        # NEW EXPOSURES
        # select the second sheet
        wks2 = sh.get_worksheet(1)

        vals = pd.DataFrame(wks2.get_all_values())
        new_header = vals.iloc[0]
        vals = vals[1:]
        vals.columns = new_header

        # if same date, then 'append' new exposure sites
        if new_exposures.shape[0] > 0:
            if vals.at[1, "Added_date"] == str(datetime.today().strftime('%d/%m/%Y')):
                vals = pd.concat([vals, new_exposures])
                vals = vals[
                ['Suburb', 'Site_title', 'Site_streetaddress', 'Site_state', 'Site_postcode', 'Exposure_date_dtm',
                 'Exposure_date', 'Exposure_time', 'Notes', 'Added_date_dtm', 'Added_date', 'Added_time',
                 'Advice_title', 'Advice_instruction', 'Exposure_time_start_24', 'Exposure_time_end_24',
                 'dhid', 'full_address', 'latitude', 'longitude']]
                wks2.clear()
                wks2.update([vals.columns.values.tolist()] + vals.values.tolist(),
                            value_input_option='USER_ENTERED')
            # else if on a new day, then clear and append new dates exposure sites
            else:
                wks2.clear()
                new_exposures = new_exposures[
                    ['Suburb', 'Site_title', 'Site_streetaddress', 'Site_state', 'Site_postcode', 'Exposure_date_dtm',
                     'Exposure_date', 'Exposure_time', 'Notes', 'Added_date_dtm', 'Added_date', 'Added_time',
                     'Advice_title', 'Advice_instruction', 'Exposure_time_start_24', 'Exposure_time_end_24',
                     'dhid', 'full_address', 'latitude', 'longitude']]
                wks2.update([new_exposures.columns.values.tolist()] + new_exposures.values.tolist(),
                            value_input_option='USER_ENTERED')

        end = time.time()
        print("Completed Computing.")
        print("Time Taken:", time.strftime("%S", time.gmtime(end - start)), "seconds")
        print("______________________________")
    else:
        print("No new exposure sites.")
        print("Completed Computing.")
else:
    print("No new exposure sites.")
    print("Completed Computing.")