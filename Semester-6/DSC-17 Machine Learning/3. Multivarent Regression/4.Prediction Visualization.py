import pandas as pd
import matplotlib.pyplot as plt
import os

# ================================
# CONFIGURATION
# ================================

data_dir = "."
country_col = "Country"
os.makedirs('Prediction Visualization', exist_ok=True)

# ================================
# LOAD DATA & APPLY VISUALIZATION
# ================================

for file in os.listdir(data_dir):
    if not (file.startswith("crop_predictions_") and file.endswith(".csv")):
        continue
    file_path = os.path.join(data_dir, file)
    df = pd.read_csv(file_path)

    for country in df[country_col].unique():
        country_data = df[df["Country"] == country]

        for crop in country_data["Crop"].unique():
            crop_data = country_data[country_data["Crop"] == crop]
            plt.figure()
            plt.bar(crop_data["Year"],crop_data["Predicted_Value"])
            for year, prod in zip(crop_data["Year"],crop_data["Predicted_Value"]):
                plt.text(
                    year,
                    prod/2,
                    prod,
                    ha='center',
                    va='center',
                    rotation=90
                )
            plt.title(f"{country}-{crop} Production Prediction")
            plt.xlabel("Year")
            plt.ylabel("Production")
            plt.xticks(rotation=45)

            plot_name = f"Prediction Visualization/{country.replace(' ', '_')}_{crop}_prediction.png"
            plt.savefig(plot_name, dpi=300)
            plt.close()
print("Prediction Visualization Complete")