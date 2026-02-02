import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split
import os

# ================================
# CONFIGURATION
# ================================

data_dir = "country_data"
country_col = "Area"
crop_col = "Item"
year_col = "Year"
area_harvested_col = "Area harvested"
value_col = "Yield"

os.makedirs("Analysis", exist_ok=True)
regression_results = []

# ================================
# LOAD DATA & APPLY REGRESSION
# ================================

for file in os.listdir(data_dir):
    if not file.endswith("_data.csv"):
        continue

    df = pd.read_csv(os.path.join(data_dir, file))
    country = df[country_col].iloc[0]

    plt.figure(figsize=(14, 8))

    for crop in df[crop_col].unique():
        crop_data = df[df[crop_col] == crop].copy()

        if len(crop_data) < 5:
            continue

        # ================================
        # FEATURES & TARGET (CORRECT SHAPE)
        # ================================
        X = crop_data[[year_col, area_harvested_col]]
        y = crop_data[value_col]

        # Remove NaNs
        data = pd.concat([X, y], axis=1).dropna()
        X = data[[year_col, area_harvested_col]]
        y = data[value_col]

        if len(X) < 5:
            continue

        # ================================
        # TRAIN / TEST SPLIT
        # ================================
        split_idx = int(len(X) * 0.8)

        X_train, X_test = X.iloc[:split_idx], X.iloc[split_idx:]
        y_train, y_test = y.iloc[:split_idx], y.iloc[split_idx:]

        # ================================
        # TRAIN MODEL
        # ================================
        model = LinearRegression()
        model.fit(X_train, y_train)

        # ================================
        # TEST MODEL
        # ================================
        y_test_pred = model.predict(X_test)
        r2 = r2_score(y_test, y_test_pred)

        regression_results.append({
            "Country": country,
            "Crop": crop,
            "Coef_Year": model.coef_[0],
            "Coef_AreaHarvested": model.coef_[1],
            "Intercept": model.intercept_,
            "R2_Score": r2
        })

        # ================================
        # PLOT
        # ================================
        X_plot = X.sort_values(year_col)
        y_plot_pred = model.predict(X_plot)

        plt.scatter(
            X_plot[year_col],
            y.loc[X_plot.index],
            alpha=0.6,
            label=f"{crop} Actual"
        )

        plt.plot(
            X_plot[year_col],
            y_plot_pred,
            linestyle="--",
            linewidth=2,
            label=f"{crop} Trend (R²={r2:.2f})"
        )

    plt.title(f"{country} - Crop Yield Trend (Multivariate)")
    plt.xlabel("Year")
    plt.ylabel("Yield")
    plt.legend(fontsize=8)
    plt.grid(alpha=0.3)
    plt.tight_layout()

    plt.savefig(f"Analysis/{country.replace(' ', '_')}_crops_analysis.png", dpi=300)
    plt.close()

# ================================
# SAVE REGRESSION SUMMARY
# ================================

summary_df = pd.DataFrame(regression_results)
summary_df.to_csv("regression_summary.csv", index=False)

print("Regression Analysis Complete")
print(summary_df.head())
