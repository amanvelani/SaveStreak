from flask import current_app as app
import random

def get_custom_location_data():
    try:
       result = app.db.custom_location_data.find({}, {"_id": 0})
       result = list(result)
       return random.choice(result)
    except Exception as e:
        print(e)
        return []
    
def get_custom_category_data():
    try:
        result = app.db.categories.find({}, {"_id": 0})
        result = list(result)
        data = random.choice(result)
        return data['hierarchy'], data['category_id']
    except Exception as e:
        print(e)
        return []
    
def save_user_info(user_id, access_token, item_id):
    try:
        app.db.user_info.update_one( {"user_id": user_id} , {
            "$push": {
                "accounts": {
                    "access_token": access_token,
                    "item_id": item_id
                }
            }
        }, upsert=True)
    except Exception as e:
        print(e)
        return []
    
def get_user_access_token(user_id):
    try:
        result = app.db.user_info.find_one({"user_id": user_id})
        access_token = result['accounts'][0]['access_token']
        return access_token
    except Exception as e:
        print(e)
        return []
            
def is_user_transaction_data_available(user_id):
    try:
        result = app.db.transaction_data.find_one({"user_id": user_id})
        if result is None:
            return ''
        else:
            return result['cursor']
    except Exception as e:
        print(e)
        return False
    
def save_user_transaction_data(user_id, transactions, cursor):
    try:
        if transactions == []:
            app.db.transaction_data.update_one({"user_id": user_id}, {
                "$set": {
                    "cursor": cursor
                }
            }, upsert=True)
        elif app.db.transaction_data.find_one({"user_id": user_id}) is not None:
            app.db.transaction_data.update_one({"user_id": user_id}, {
                "$push": {
                    "transactions": transactions
                },
                "$set": {
                    "cursor": cursor
                }
            }, upsert=True)
        else:
            app.db.transaction_data.insert_one({"user_id": user_id, "transactions": transactions, "cursor": cursor})
    except Exception as e:
        print(e)
        return []