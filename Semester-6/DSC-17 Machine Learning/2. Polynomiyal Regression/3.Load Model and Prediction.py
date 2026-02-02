import pandas as pd
import numpy as np
from sklearn.preprocessing import PolynomialFeatures
import matplotlib.pyplot as plt
import os

# ================================
# CONFIGURATION
# ================================

summary_file = "regression_summary.csv"

start_year=int(input("Prediction Starting Year..."))
end_year=int(input("Prediction End Year..."))
output_file = f"crop_predictions_{start_year}_{end_year}.csv"

future_years = np.arange(start_year, end_year + 1).reshape(-1,1)
poly = PolynomialFeatures(degree=2)
future_years_transform = poly.fit_transform(future_years)


# ================================
# LOAD REGRESSION SUMMARY
# ================================

summary_df = pd.read_csv(summary_file)

predictions = []

# ================================
# GENERATE PREDICTIONS
# ================================

for _, row in summary_df.iterrows():
    country = row["Country"]
    crop = row["Crop"]
    slope1 = row["Slope1"]
    slope2 = row["Slope2"]
    intercept = row["Intercept"]
    
    
    for year in future_years_transform:
        predicted_value = slope1 * year[1] + slope2 * (year[1])**2 + intercept
        
        predictions.append({
            "Country": country,
            "Crop": crop,
            "Year": year,
            "Predicted_Value": predicted_value,
        })

# ================================
# SAVE PREDICTIONS
# ================================

prediction_df = pd.DataFrame(predictions)
prediction_df.to_csv(output_file, index=False)

print("Prediction Complete")
