import pandas as pd

# Read the original dataset using the correct encoding
df = pd.read_csv(
    "data/Pharmaciesss.csv",
    encoding="cp1252",
    low_memory=False
)

# Take the first 50 rows
sample = df.head(50)

# Save the sample
sample.to_csv(
    "data/sample_pharmacies.csv",
    index=False,
    encoding="utf-8"
)

print("✅ Sample dataset created successfully!")