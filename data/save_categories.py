import json
from pymongo import MongoClient
import dotenv
import os

# Load environment variables
dotenv.load_dotenv()
mongo_client_url = os.getenv("MONGO_CLIENT_URL")

# Connection to MongoDB
client = MongoClient(mongo_client_url)
db = client['save_streak']
collection = db['categories']

# Read categories from the JSON file
with open('categories.json', 'r') as file:
    data = json.load(file)
    categories = data['categories']  # Adjust according to your JSON structure


print(categories)
# Insert the categories into the MongoDB collection
result = collection.insert_many(categories)

# Output the result of the insertion
print(f"Inserted {len(result.inserted_ids)} categories into the database.")
