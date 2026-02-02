import pandas as pd
import numpy as np

# ================================
# DATA LOADING & CLEANING
# ================================

csv_file = 'crop_data.csv'  

country_col = 'Area'
crop_col = 'Item'
year_col = 'Year'
value_col = 'Value'

df = pd.read_csv(csv_file)

df = df[[country_col, crop_col, year_col, value_col]]
df[year_col] = pd.to_numeric(df[year_col], errors='coerce')
df[value_col] = pd.to_numeric(df[value_col], errors='coerce')

df_clean = df.dropna(subset=[country_col, crop_col, year_col, value_col])

print("Data Loaded & Cleaned Successfully")
print(df_clean.head())

import os

# ================================
# DATA PROCESSING
# ================================

countries = df_clean[country_col].unique()
crops = df_clean[crop_col].unique()

print(f"Countries: {len(countries)}")
print(f"Crops: {len(crops)}")

os.makedirs('country_data', exist_ok=True)

country_crop_data = {}

for country in countries:
    country_data = df_clean[df_clean[country_col] == country].copy()
    
    filename = f"country_data/{country.replace(' ', '_')}_data.csv"
    country_data.to_csv(filename, index=False)
    
    country_crop_data[country] = {}
    
    for crop in crops:
        crop_data = country_data[country_data[crop_col] == crop]
        
        if len(crop_data) > 1:
            country_crop_data[country][crop] = crop_data

print("Country & Crop-wise Processing Complete")

