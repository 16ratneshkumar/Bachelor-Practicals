import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
import os

# ================================
# CONFIGURATION
# ================================

data_dir = "country_data"
country_col = "Area"
crop_col = "Item"
year_col = "Year"
value_col = "Value"

regression_results = []

os.makedirs("Analysis Visualization", exist_ok=True)

# ================================
# LOAD DATA & APPLY REGRESSION
# ================================

for file in os.listdir(data_dir):
    if not file.endswith("_data.csv"):
        continue

    file_path = os.path.join(data_dir, file)
    df = pd.read_csv(file_path)

    country = df[country_col].iloc[0]

    plt.figure(figsize=(14, 8))

    for crop in df[crop_col].unique():
        crop_data = df[df[crop_col] == crop].copy()


        if len(crop_data) < 3:
            continue

        X = crop_data[year_col].to_numpy().reshape(-1, 1)
        y = crop_data[value_col].to_numpy()

        # Remove NaNs
        mask = ~np.isnan(y)
        X = X[mask]
        y = y[mask]

        if len(X) < 3:
            continue

        # ================================
        # TRAIN / TEST SPLIT
        # ================================
        split_idx = int(len(X) * 0.8)

        X_train = X[:split_idx]
        X_test = X[split_idx:]
        y_train = y[:split_idx]
        y_test = y[split_idx:]

        if len(X_test) < 2:
            continue

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
            "Slope": model.coef_[0],
            "Intercept": model.intercept_,
            "R2_Score": r2
        })

        # Predict full trend for plotting
        y_pred = model.predict(X)

        plt.scatter(X, y, s=30, alpha=0.6, label=f"{crop} Actual")
        plt.plot(
            X, y_pred,
            linestyle="--",
            linewidth=2,
            label=f"{crop} Trend (R²={r2:.2f})"
        )

    plt.title(f"{country} - Crop Trend Analysis")
    plt.xlabel("Year")
    plt.ylabel(value_col)
    plt.legend(fontsize=8)
    plt.grid(alpha=0.3)
    plt.tight_layout()

    plot_name = f"Analysis Visualization/{country.replace(' ', '_')}_crops_analysis.png"
    plt.savefig(plot_name, dpi=300)
    plt.close()

# ================================
# SAVE REGRESSION SUMMARY
# ================================

summary_df = pd.DataFrame(regression_results)
summary_df.to_csv("regression_summary.csv", index=False)

print("Regression Analysis Complete")
