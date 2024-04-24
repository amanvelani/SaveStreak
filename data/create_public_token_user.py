import json
import os
import requests
from pymongo import MongoClient
import dotenv

dotenv.load_dotenv()

mongo_client_url = os.getenv("MONGO_CLIENT_URL")
plaid_client_id = os.getenv("PLAID_CLIENT_ID")
plaid_client_secret = os.getenv("PLAID_CLIENT_SECRET")
plaid_institution_id = os.getenv("PLAID_INSTITUTION_ID")


# Connection to MongoDB
client = MongoClient(mongo_client_url)
db = client['save_streak']
collection = db['custom_data_users_public_token']

base_url = "https://sandbox.plaid.com/sandbox/public_token/create"
headers = {
    "Content-Type": "application/json"
}

def read_and_process_files():
    for i in range(0, 50):
        file_name = f"./custom_user_data/custom_user_data_{i}.json"
        if os.path.exists(file_name):
            with open(file_name, 'r') as file:
                data = json.load(file)
                payload = {
                    "client_id": plaid_client_id,
                    "secret": plaid_client_secret,
                    "institution_id": plaid_institution_id,
                    "initial_products": ["transactions"],
                    "options": {
                        "override_username": "user_custom",
                        "override_password": json.dumps(data)
                    }
                }
                response = make_api_request(payload)
                save_to_database(i, response.json())

def make_api_request(payload):
    response = requests.post(base_url, headers=headers, json=payload)
    if response.status_code != 200:
        raise Exception(f"Failed to create public token: {response.text}")
    return response

def save_to_database(id, data):
    # Save as key = custom_user_data_{user_id}, value = public_token
    user_id = f"custom_user_data_{id}"
    public_token = data['public_token']
    collection.insert_one({user_id: public_token})

read_and_process_files()
