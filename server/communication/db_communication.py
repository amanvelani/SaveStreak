from datetime import datetime
import traceback
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
    

def get_recent_transactions(user_id):
    try:
        latest_transactions = list(app.db.transaction_data.find(
            {"user_id": user_id},
            {"_id": 0, "transactions": 1}
        ).sort("transactions.date", -1))
        
        return latest_transactions[0].get('transactions')
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []
    
def get_category_wise_spend(user_id):
    try:

        pipeline = [
            {"$match": {"user_id": user_id}},  
            {"$unwind": "$transactions"},     
            {"$project": {"_id": 0, "transactions": 1}}, 
            {"$unwind": "$transactions.category"}, 
            {"$group": {
                "_id": "$transactions.category",  
                "total_expense": {"$sum": "$transactions.amount"}  
            }},
            {"$sort": {"total_expense": -1}},     
            # {"$limit": 5}                        
        ]

        result = list(app.db.transaction_data.aggregate(pipeline))

        return result

    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []
    

def get_current_month_spend(user_id):
    try:
        start_of_month = datetime(datetime.today().year, datetime.today().month, 1)
        total_spend = app.db.transaction_data.aggregate([
            {"$match": {
                "user_id": user_id,
                "transactions.date": {"$gte": start_of_month.strftime('%Y-%m-%d')}
            }},
            {"$unwind": "$transactions"},
            {"$group": {
                "_id": None,
                "totalSpend": {"$sum": "$transactions.amount"}
            }}
        ])

        total_spend_amount = list(total_spend)
        if total_spend_amount:
            total_spend_amount = total_spend_amount[0]["totalSpend"]
        else:
            total_spend_amount = 0
        return total_spend_amount
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return 0
    

def get_user_transactions_by_location(user_id):
    pipeline = [
        {"$match": {"user_id": user_id}},
        {"$unwind": "$transactions"},
        {"$group": {
            "_id": "$transactions.location",
            "transactions": {
                "$push": {
                    "name": "$transactions.name",
                    "amount": "$transactions.amount"
                }
            }
        }},
        {"$project": {
            "location": "$_id",
            "transactions": {
                "$map": {
                    "input": {
                        "$slice": [
                            {"$sortArray": {
                                "input": "$transactions",
                                "sortBy": {"amount": -1}
                            }},
                            5 
                        ]
                    },
                    "as": "transaction",
                    "in": {
                        "name": "$$transaction.name",
                        "amount": "$$transaction.amount"
                    }
                }
            }
        }},
        {"$sort": {"transactions.amount": -1}}  
    ]

    result = list(app.db.transaction_data.aggregate(pipeline))
    return result
