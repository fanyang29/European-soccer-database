import os
import shutil
import kagglehub

# 1. Download the dataset using kagglehub
cache_path = kagglehub.dataset_download("hugomathien/soccer")
print("Downloaded to cache folder:", cache_path)

# 2. Look for the database file inside the downloaded folder
source_file = os.path.join(cache_path, "database.sqlite")

# 3. Copy it directly into your current working directory as 'soccer.db'
destination_file = "soccer.db"
if os.path.exists(source_file):
    shutil.copy(source_file, destination_file)
    print(f"Success! Database copied to your project folder as: {os.path.abspath(destination_file)}")
else:
    print("Could not find database.sqlite in the downloaded folder.")
