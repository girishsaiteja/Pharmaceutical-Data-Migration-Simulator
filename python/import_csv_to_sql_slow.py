import pandas as pd
import pyodbc
import time

# ============================================
# Start Timer
# ============================================
start_time = time.time()

# ============================================
# Read CSV
# ============================================
print("Reading CSV...")

df = pd.read_csv(
    r"C:\Users\giris\Desktop\Pharmaceutical-Data-Migration-Simulator\data\Pharmaciesss.csv",
    dtype=str,
    keep_default_na=False,
    encoding="cp1252"
)

print("CSV Loaded Successfully!")
print(f"Total Rows    : {len(df)}")
print(f"Total Columns : {len(df.columns)}")

# ============================================
# Connect SQL Server
# ============================================
print("\nConnecting to SQL Server...")

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=GIRISH\\SQLEXPRESS;"
    "DATABASE=PharmaLegacy;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

cursor = conn.cursor()

print("Connected Successfully!")

# ============================================
# Build Dynamic INSERT Statement
# ============================================
columns = list(df.columns)

column_names = ",".join(f"[{col}]" for col in columns)
placeholders = ",".join("?" for _ in columns)

sql = f"""
INSERT INTO raw_pharmacy_data
({column_names})
VALUES ({placeholders})
"""

# ============================================
# Convert DataFrame to List
# ============================================
rows = [tuple(row) for row in df.values]

# ============================================
# Batch Insert
# ============================================
batch_size = 1000

print("\nStarting Data Import...\n")

inserted = 0

try:

    for start in range(0, len(rows), batch_size):

        batch = rows[start:start + batch_size]

        cursor.executemany(sql, batch)

        conn.commit()

        inserted += len(batch)

        print(f"Inserted {inserted} / {len(rows)} rows")

except Exception as e:

    print("\n===================================")
    print("IMPORT FAILED")
    print("===================================")
    print(e)
    print(f"Failed after inserting {inserted} rows")

finally:

    cursor.close()
    conn.close()

end_time = time.time()

print("\n===================================")
print("IMPORT FINISHED")
print("===================================")
print(f"Rows Imported : {inserted}")
print(f"Time Taken    : {end_time-start_time:.2f} seconds")