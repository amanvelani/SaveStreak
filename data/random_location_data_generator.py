from faker import Faker
import random
from pymongo import MongoClient
import dotenv
import os

fake = Faker()


dotenv.load_dotenv()
mongo_client_url = os.getenv("MONGO_CLIENT_URL")

# Connection to MongoDB
client = MongoClient(mongo_client_url)
db = client['save_streak']
collection = db['custom_location_data']


def generate_random_location_data():
    center_lat = 43.0481
    center_lon = -76.1474
    lat_variation = random.uniform(-0.05, 0.05)
    lon_variation = random.uniform(-0.05, 0.05)

    location_data = {
        "address": fake.street_address(),
        "city": "Syracuse",
        "country": "United States",
        "lat": center_lat + lat_variation,
        "lon": center_lon + lon_variation,
        "postal_code": fake.postcode_in_state(state_abbr="NY"),
        "region": "NY",
        "store_number": fake.building_number()
    }
    return location_data

def save_location_data():
    location_entries = []
    for _ in range(0, 50):
        location_data = generate_random_location_data()
        location_entries.append(location_data)
        
    collection.insert_many(location_entries)
    
save_location_data()