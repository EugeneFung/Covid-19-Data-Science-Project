# Ting Han Gan
# 20/09/21

# Function: USED TO UPDATE EMPTY SHEET
import pandas as pd
from geopy.geocoders import Nominatim
import gspread
import re
import time
import hashlib

start = time.time()
print("Computing base exposure site Code ...")
df = pd.read_csv("https://drive.google.com/uc?export=download&id=1hULHQeuuMQwndvKy1_ScqObgX0NRUv1A")

df.dropna(subset=["Site_postcode"], inplace=True)
df.dropna(subset=["Site_streetaddress"], inplace=True)

# change 'Site_postcode' to be int
df["Site_postcode"] = df["Site_postcode"].astype(int)

df["full_address"] = df["Site_streetaddress"] + ', ' + df["Suburb"] + ', ' + df["Site_state"] + ', ' + df[
    "Site_postcode"].astype(str)

uid = []
for i in range(len(df)):
    current = df.iloc[i]['full_address']
    uid.append(int(hashlib.sha1(current.encode("utf-8")).hexdigest(), 16) % (10 ** 8))

df['dhid'] = [str(x) for x in uid]

geolocator = Nominatim(user_agent="my_user_agent")

addressRegex = re.compile(r'([1-9][0-9]*[a-z]?)?(( \w+)|([a-z]\w+-\w+))*,( \w+)+,( \w+), [0-9]{4}')

lat = []
long = []
last_address = ""
flag = False

for i in df["full_address"]:
    current_address = i
    if (current_address == last_address) & flag:
        lat.append(loc.latitude)
        long.append(loc.longitude)
    else:
        try:
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

df["latitude"] = lat
df["longitude"] = long

# sort by postcode
df = df.sort_values(by=['Site_postcode'], ascending=True)

df = df.fillna('')

# ___________ Updating Google Sheets (Sheet1) _________
print("Updating 'exposure_site' Google Sheets ...")
gc = gspread.service_account(filename='credentials.json')

# open the google spreadsheet
sh = gc.open_by_key('1MG6_S_tZLFPQiVjZJYK7J6MoeOPYIHb-F7r7kPCK6Vo')

# select the first sheet
wks1 = sh.get_worksheet(0)

# update the first sheet with current_change
if df.shape[0] > 0:
    wks1.clear()
    wks1.update([df.columns.values.tolist()] + df.values.tolist(),
                value_input_option='USER_ENTERED')
    print("Successfully updated sheet")
else:
    print("No data found")

end = time.time()
print("Completed Computing")
print("Time Taken:", time.strftime("%M:%S", time.gmtime(end - start)), "minutes")
print("______________________________")