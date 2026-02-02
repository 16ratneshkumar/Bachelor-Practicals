import pandas as pd
import numpy as np

# ================================
# CONFIGURATION
# ================================

summary_file = "regression_summary.csv"

start_year = int(input("Starting Year of Prediction: "))
end_year = int(input("End Year of Prediction: "))
output_file = f"crop_predictions_{start_year}_{end_year}.csv"

future_years = np.arange(start_year, end_year + 1)

# ================================
# LOAD REGRESSION SUMMARY
# ================================

summary_df = pd.read_csv(summary_file)

countries = summary_df["Country"].unique()

# ================================
# INPUT HARVESTED AREA
# ================================

area_harvested = {}

for country in countries:
    print(f"\nEnter harvested area for {country}")
    for year in future_years:
        value = float(input(f"  Harvested Area in {year}: "))
        area_harvested[(country, year)] = value

# ================================
# GENERATE PREDICTIONS
# ================================

predictions = []

for _, row in summary_df.iterrows():
    country = row["Country"]
    crop = row["Crop"]
    coef_year = row["Coef_Year"]
    coef_area = row["Coef_AreaHarvested"]
    intercept = row["Intercept"]
    r2 = row["R2_Score"]

    for year in future_years:
        area = area_harvested[(country, year)]

        predicted_value = (
            coef_year * year
            + coef_area * area
            + intercept
        )

        predictions.append({
            "Country": country,
            "Crop": crop,
            "Year": year,
            "Harvested_Area": area,
            "Predicted_Value": predicted_value,
            "R2_Score": r2
        })

# ================================
# SAVE PREDICTIONS
# ================================

prediction_df = pd.DataFrame(predictions)
prediction_df.to_csv(output_file, index=False)

print("Prediction Complete")
