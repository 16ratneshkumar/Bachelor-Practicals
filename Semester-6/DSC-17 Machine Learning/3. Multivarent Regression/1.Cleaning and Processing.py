import pandas as pd
import numpy as np

# ================================
# DATA LOADING & CLEANING
# ================================

# File path
csv_file = 'crop_data.csv'  # Update if needed

# Column names
country_col = 'Area'
crop_col = 'Item'
year_col = 'Year'
Element_col = 'Element'
value_col = 'Value'

# Read CSV
df = pd.read_csv(csv_file)

# Basic cleaning
df = df[[country_col, crop_col, year_col, value_col,Element_col]]
df_wide = df.pivot(
    index=["Area", "Item", "Year"],
    columns="Element",
    values="Value"
).reset_index()
df_wide[year_col] = pd.to_numeric(df_wide[year_col], errors='coerce')
df_wide["Area harvested"] = pd.to_numeric(df_wide["Area harvested"], errors='coerce')
df_wide["Yield"] = pd.to_numeric(df_wide["Yield"], errors='coerce')

# Drop rows with missing essential values
df_clean = df_wide.dropna(subset=[country_col, crop_col, year_col, "Area harvested","Yield"])

print("Data Loaded & Cleaned Successfully")

import os

# ================================
# DATA PROCESSING
# ================================

countries = df_clean[country_col].unique()
crops = df_clean[crop_col].unique()

print(f"Countries: {len(countries)}")
print(f"Crops: {len(crops)}")

# Create directory for country-wise data
os.makedirs('country_data', exist_ok=True)

country_crop_data = {}

for country in countries:
    country_data = df_clean[df_clean[country_col] == country].copy()
    
    # Save country-wise CSV
    filename = f"country_data/{country.replace(' ', '_')}_data.csv"
    country_data.to_csv(filename, index=False)
    
    country_crop_data[country] = {}
    
    for crop in crops:
        crop_data = country_data[country_data[crop_col] == crop]
        
        if len(crop_data) > 1:
            country_crop_data[country][crop] = crop_data

print("Country & Crop-wise Processing Complete")

