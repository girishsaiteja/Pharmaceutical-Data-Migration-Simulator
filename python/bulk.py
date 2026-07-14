import pyodbc
import time

# ======================================
# Start Timer
# ======================================
start_time = time.time()

print("Connecting to SQL Server...")

# ======================================
# Connect to SQL Server
# ======================================
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=GIRISH\\SQLEXPRESS;"
    "DATABASE=PharmaLegacy;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

cursor = conn.cursor()

print("Connected Successfully!")

# ======================================
# CSV File Path
# ======================================
csv_path = r"C:\Users\giris\Desktop\Pharmaceutical-Data-Migration-Simulator\data\Pharmaciesss.csv"

# SQL Server prefers forward slashes
csv_path = csv_path.replace("\\", "/")

# ======================================
# BULK INSERT Command
# ======================================
bulk_sql = f"""
BULK INSERT raw_data
FROM '{csv_path}'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK,
    KEEPNULLS,
    CODEPAGE = 'ACP'
);
"""

print("\nStarting BULK INSERT...\n")

cursor.execute(bulk_sql)

conn.commit()

print("BULK INSERT Completed Successfully!")

# ======================================
# Verify Import
# ======================================
cursor.execute("SELECT COUNT(*) FROM raw_data")

row_count = cursor.fetchone()[0]

print(f"Rows Imported : {row_count}")

# ======================================
# Close Connection
# ======================================
cursor.close()
conn.close()

end_time = time.time()

print("\n====================================")
print("BULK IMPORT FINISHED")
print("====================================")
print(f"Total Rows : {row_count}")
print(f"Time Taken : {end_time-start_time:.2f} seconds")