"""Week 2 - Python for Data Analysis: solutions to the 5 practice questions.
Run from the repo root:  python python/practice_solutions.py
"""
import os
import pandas as pd

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
pd.set_option("display.width", 120)

# ---------------------------------------------------------------- Q1
print("=== Q1. Load a CSV with Pandas and display basic info ===")
df = pd.read_csv(f"{ROOT}/data/sales_data.csv", parse_dates=["order_date"])
print(df.head())
print("\nShape (rows, cols):", df.shape)
print("\n.info():")
df.info()
print("\n.describe():")
print(df.describe().round(2))
print("\nMissing values per column:")
print(df.isna().sum())
print("Duplicate rows:", df.duplicated().sum())

# ---------------------------------------------------------------- Q2
print("\n=== Q2. Handle missing values and duplicates ===")
before = len(df)
df = df.drop_duplicates()                                   # exact duplicate rows
print(f"Removed {before - len(df)} duplicate rows ({before} -> {len(df)})")

df["region"] = df["region"].fillna("Unknown")                # categorical -> label
df["quantity"] = df["quantity"].fillna(df["quantity"].median())      # numeric -> median
df["discount_pct"] = df["discount_pct"].fillna(0)            # no discount recorded -> 0
print("Missing values after cleaning:")
print(df.isna().sum())
df["quantity"] = df["quantity"].astype(int)

# ---------------------------------------------------------------- Q3
print("\n=== Q3. Group by category and find total revenue ===")
cat_rev = (df.groupby("category")["revenue"]
             .agg(total_revenue="sum", avg_order="mean", orders="count")
             .round(2)
             .sort_values("total_revenue", ascending=False))
print(cat_rev)

# ---------------------------------------------------------------- Q4
print("\n=== Q4. Sort by multiple columns ===")
sorted_df = df.sort_values(by=["region", "revenue"], ascending=[True, False])
print("Region A-Z, then revenue high -> low (first 8 rows):")
print(sorted_df[["order_id", "region", "category", "revenue"]].head(8).to_string(index=False))

# ---------------------------------------------------------------- Q5
print("\n=== Q5. Correlation matrix of numerical columns ===")
num_cols = ["quantity", "unit_price", "discount_pct", "revenue"]
corr = df[num_cols].corr().round(2)
print(corr)

# Optional heatmap (needs matplotlib):  pip install matplotlib
try:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, ax = plt.subplots(figsize=(5, 4))
    im = ax.imshow(corr, cmap="coolwarm", vmin=-1, vmax=1)
    ax.set_xticks(range(len(num_cols)), num_cols, rotation=45, ha="right")
    ax.set_yticks(range(len(num_cols)), num_cols)
    for i in range(len(num_cols)):
        for j in range(len(num_cols)):
            ax.text(j, i, corr.iloc[i, j], ha="center", va="center", fontsize=9)
    fig.colorbar(im); ax.set_title("Correlation matrix")
    fig.tight_layout(); fig.savefig(f"{ROOT}/correlation_heatmap.png", dpi=150)
    print("\nSaved correlation_heatmap.png")
except ImportError:
    print("\n(matplotlib not installed - skipping heatmap)")

# Save cleaned data
df.to_csv(f"{ROOT}/data/sales_data_clean.csv", index=False)
