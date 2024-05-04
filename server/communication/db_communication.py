from collections import defaultdict
import copy
from datetime import date, datetime, timedelta
import traceback
from flask import current_app as app
import random


def register_user(user_id, email, name, age, sex, profileImageURL):
    try:
        app.db.user_info.insert_one(
            {
                "user_id": user_id,
                "email": email,
                "name": name,
                "age": age,
                "sex": sex,
                "profileImageURL": profileImageURL,
            }
        )
    except Exception as e:
        print(e)
        return []
    
def get_user_data(user_id):
    try:
        result = app.db.user_info.find_one({"user_id": user_id}, {"_id": 0})
        result = {
            "email": result["email"],
            "name": result["name"],
            "age": result["age"],
            "sex": result["sex"]
        }
        print(result)
        return result
    except Exception as e:
        print(e)
        return []
    
def get_custom_location_data():
    try:
        result = app.db.custom_location_data.find({}, {"_id": 0})
        result = list(result)
        selected_location = random.choice(result)
        merchant = selected_location["merchant"]
        selected_location.pop("merchant")
        return selected_location, merchant
    except Exception as e:
        print(e)
        return []


def get_custom_category_data():
    try:
        result = app.db.categories.find({}, {"_id": 0})
        result = list(result)
        data = random.choice(result)
        return data["hierarchy"], data["category_id"]
    except Exception as e:
        print(e)
        return []


def save_user_info(user_id, access_token, item_id, bank_information):
    try:
        app.db.user_info.update_one(
            {"user_id": user_id},
            {
                "$push": {
                    "accounts": {
                        "access_token": access_token,
                        "item_id": item_id,
                        "bank_information": bank_information,
                    }
                }
            },
            upsert=True,
        )
    except Exception as e:
        print(e)
        return []


def get_user_access_token(user_id):
    try:
        result = app.db.user_info.find_one({"user_id": user_id})
        accounts = result["accounts"]
        result = []
        for account in accounts:
            result.append(
                {"access_token": account["access_token"], "item_id": account["item_id"]}
            )

        return result
    except Exception as e:
        print(e)
        return []


# [
#     user_id,
#     all_transaction:
#         item_id:
#             transactions
#             cursor

# ]


def is_user_transaction_data_available(user_id, item_id):
    try:
        result = app.db.transaction_data.find_one({"user_id": user_id})
        transactions = result["all_transactions"]
        if item_id in transactions:
            return transactions[item_id]["cursor"]
        else:
            return ""
    except Exception as e:
        print(e)
        return ""


def save_user_transaction_data(user_id, transactions, cursor, item_id):
    try:
        if transactions == []:
            app.db.transaction_data.update_one(
                {"user_id": user_id},
                {
                    "$set": {
                        "all_transactions." + item_id + ".cursor": cursor,
                    }
                },
                upsert=True,
            )
        elif app.db.transaction_data.find_one({"user_id": user_id}) is not None:
            app.db.transaction_data.update_one(
                {"user_id": user_id},
                {
                    "$push": {
                        "all_transactions."
                        + item_id
                        + ".transactions": {"$each": transactions}
                    },
                    "$set": {"all_transactions." + item_id + ".cursor": cursor},
                },
                upsert=True,
            )
        else:
            app.db.transaction_data.insert_one(
                {
                    "user_id": user_id,
                    "all_transactions": {
                        item_id: {"transactions": transactions, "cursor": cursor}
                    },
                }
            )
    except Exception as e:
        import traceback

        print(traceback.format_exc())
        return []


def get_recent_transactions(user_id):
    try:
        latest_transactions = list(
            app.db.transaction_data.find(
                {"user_id": user_id}, {"_id": 0, "all_transactions": 1}
            )
        )
        accounts = latest_transactions[0].get("all_transactions")
        all_transactions = []
        total_expenses = 0
        for each_account in accounts.values():
            for each_transaction in each_account.get("transactions", []):
                all_transactions.append(each_transaction)
                total_expenses += each_transaction.get("amount", 0)
        sorted_transactions = sorted(all_transactions, key=lambda d: d["date"])
        # Reverse the list to get the latest transactions first
        sorted_transactions = sorted_transactions[::-1]

        return sorted_transactions, total_expenses

        # return latest_transactions[0].get('transactions')
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []


def get_category_wise_spend(user_id, start_date=None, end_date=None):
    try:
        if start_date is None:
            start_date = date.today().replace(day=1)
            start_date = start_date.strftime("%Y-%m-%d")
        if end_date is None:
            end_date = date.today().replace(day=1) + timedelta(days=31)
            end_date = end_date.strftime("%Y-%m-%d")

        pipeline = [
            {
                "$match": {
                    "user_id": user_id,
                }
            },
            {
                "$addFields": {
                    "all_transactions_array": {"$objectToArray": "$all_transactions"}
                }
            },
            {"$unwind": "$all_transactions_array"},
            {"$unwind": "$all_transactions_array.v.transactions"},
            {
                "$match": {
                    "all_transactions_array.v.transactions.date": {
                        "$gte": start_date,
                        "$lte": end_date,
                    }
                }
            },
            {
                "$addFields": {
                    "category": {
                        "$arrayElemAt": [
                            "$all_transactions_array.v.transactions.category",
                            0,
                        ]
                    }
                }
            },
            {
                "$group": {
                    "_id": "$category",
                    "total_expense": {
                        "$sum": "$all_transactions_array.v.transactions.amount"
                    },
                }
            },
            {"$sort": {"total_expense": -1}},
        ]
        result = list(app.db.transaction_data.aggregate(pipeline))
        print("result", result)
        return result

    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []


def get_spending_trend(user_id, start_month=None, end_month=None):
    current_date = datetime.today()
    current_year = current_date.year

    # Default to the last 6 months if both start_month and end_month are None
    if start_month is None and end_month is None:
        end_month = current_date.month
        start_year = current_year if end_month > 6 else current_year - 1
        start_month = end_month - 5 if end_month > 6 else end_month + 7
    else:
        if end_month is None:
            end_month = datetime.today().month
        if start_month is None:
            start_month = 1  # default start_month to January of the current year if only end_month is given

    print("Start Month:", start_month)
    print("End Month:", end_month)
    start_year = current_year if start_month <= end_month else current_year - 1
    end_year = current_year

    start_date = datetime(start_year, start_month, 1)
    end_date = datetime(end_year, end_month, 30)

    print("Start Date:", start_date)
    print("End Date:", end_date)
    start_date = start_date.strftime("%Y-%m-%d")
    end_date = end_date.strftime("%Y-%m-%d")
    try:
        pipeline = [
            {
                "$match": {
                    "user_id": user_id,
                }
            },
            {
                "$addFields": {
                    "all_transactions_array": {"$objectToArray": "$all_transactions"}
                }
            },
            {"$unwind": "$all_transactions_array"},
            {"$unwind": "$all_transactions_array.v.transactions"},
            {
                "$match": {
                    "all_transactions_array.v.transactions.date": {
                        "$gte": start_date,
                        "$lte": end_date,
                    }
                }
            },
            {
                "$project": {
                    "yearMonth": {
                        "$dateToString": {
                            "format": "%Y-%m",
                            "date": {
                                "$dateFromString": {
                                    "dateString": "$all_transactions_array.v.transactions.date",
                                    "format": "%Y-%m-%d",
                                }
                            },
                        }
                    },
                    "amount": "$all_transactions_array.v.transactions.amount",
                }
            },
            {"$group": {"_id": "$yearMonth", "total_spending": {"$sum": "$amount"}}},
            {"$sort": {"_id": 1}},
        ]

        print("Pipeline:", pipeline)
        result = list(app.db.transaction_data.aggregate(pipeline))
        print("Monthly Spending Trend:", result)
        return result
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []


def get_current_month_spend(user_id):
    try:
        start_of_month = datetime(datetime.today().year, datetime.today().month, 1)
        total_spend = app.db.transaction_data.aggregate(
            [
                {
                    "$match": {
                        "user_id": user_id,
                        "transactions.date": {
                            "$gte": start_of_month.strftime("%Y-%m-%d")
                        },
                    }
                },
                {"$unwind": "$transactions"},
                {
                    "$group": {
                        "_id": None,
                        "totalSpend": {"$sum": "$transactions.amount"},
                    }
                },
            ]
        )

        total_spend_amount = list(total_spend)
        if total_spend_amount:
            total_spend_amount = total_spend_amount[0]["totalSpend"]
        else:
            total_spend_amount = 0
        return total_spend_amount
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return 0


def get_user_transactions_by_location(user_id, category, start_date, end_date):
    if category is None:
        category = "All"
        
    if type(start_date) != str:
        start_date = start_date.strftime("%Y-%m-%d")
    
    if type(end_date) != str:
        end_date = end_date.strftime("%Y-%m-%d")
        
    try:
        base_match = {
            "user_id": user_id,
        }
        
        pipeline = [
            {"$match": base_match},
            {
                "$addFields": {
                    "all_transactions_array": {"$objectToArray": "$all_transactions"}
                }
            },
            {"$unwind": "$all_transactions_array"},
            {"$unwind": "$all_transactions_array.v.transactions"},
            {
                "$match": { "all_transactions_array.v.transactions.date": {"$gte": start_date, "$lte": end_date}}
            },
            {
                "$addFields": {
                    "category": {
                        "$arrayElemAt": ["$all_transactions_array.v.transactions.category", 0]
                    }
                }
            },
            {"$match": {
                "category": {"$eq": category} if category != "All" else {"$exists": True}
            }},
            {
                "$group": {
                    "_id": {
                        "lat": "$all_transactions_array.v.transactions.location.lat",
                        "lon": "$all_transactions_array.v.transactions.location.lon",
                        "address": "$all_transactions_array.v.transactions.location.address",
                        "store_number": "$all_transactions_array.v.transactions.location.store_number",
                    },
                    "total_amount": {
                        "$sum": "$all_transactions_array.v.transactions.amount"
                    },
                    "merchant_name": {
                        "$first": "$all_transactions_array.v.transactions.merchant_name"
                    },
                }
            },
            {
                "$project": {
                    "_id": 0,
                    "lat": "$_id.lat",
                    "lon": "$_id.lon",
                    "amount": "$total_amount",
                    "name": "$merchant_name",
                }
            },
            {"$sort": {"amount": -1}},
            {"$limit": 10}
        ]
        
        print("Pipeline:", pipeline)
        result = list(app.db.transaction_data.aggregate(pipeline))
        return result
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []


def get_user_linked_accounts(user_id):
    try:
        result = app.db.user_info.find_one(
            {"user_id": user_id}, {"_id": 0, "accounts": 1}
        )
        accounts = result.get("accounts", [])
        flattened_accounts = [info for account in accounts for info in account['bank_information']]

        print(accounts)
        result = {
            "accounts":
                [
                    {
                        "bank_name": account["account_name"],
                        "account_type": account["account_type"],
                        "account_balance": account["account_balance"],
                    }
                    for account in flattened_accounts 
                ]
        }
        print(result)
        return result
    except Exception as e:
        app.logger.debug(traceback.format_exc())
        return []


def flatten_transactions(user_transactions):
    all_transactions = []
    for transaction_entry in user_transactions.values():
        if "transactions" in transaction_entry:
            for transaction in transaction_entry["transactions"]:
                all_transactions.append(transaction)
    return all_transactions


def set_user_streak_category(user_id, category, target):
    try:
        app.db.user_info.update_one(
            {"user_id": user_id},
            {"$set": {"streak_category": category, "streak_target": target}},
            upsert=True,
        )
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []


def get_user_streak_category(user_id):
    try:
        result = app.db.user_info.find_one({"user_id": user_id})
        return result["streak_category"], result["streak_target"]
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return []


def calculate_streak(user_id, category, streak_target):
    today = datetime.today().date()
    today_str = today.strftime("%Y-%m-%d")
    start_date = today - timedelta(days=180)

    streak_target = int(streak_target)
    try:
        pipeline = [
            {"$match": {"user_id": user_id}},
            {
                "$addFields": {
                    "all_transactions_array": {"$objectToArray": "$all_transactions"}
                }
            },
            {"$unwind": "$all_transactions_array"},
            {"$unwind": "$all_transactions_array.v.transactions"},
            {
                "$addFields": {
                    "transaction_date": {
                        "$dateFromString": {
                            "dateString": "$all_transactions_array.v.transactions.date",
                            "format": "%Y-%m-%d",
                        }
                    }
                }
            },
            {
                "$match": {
                    "all_transactions_array.v.transactions.category": category,
                    "all_transactions_array.v.transactions.date": {"$lte": today_str},
                }
            },
            {
                "$group": {
                    "_id": {
                        "year": {"$year": "$transaction_date"},
                        "month": {"$month": "$transaction_date"},
                        "day": {"$dayOfMonth": "$transaction_date"},
                    },
                    "daily_total": {
                        "$sum": "$all_transactions_array.v.transactions.amount"
                    },
                }
            },
            {"$sort": {"_id": -1}},
        ]
        results = list(app.db.transaction_data.aggregate(pipeline))
        # print("Pipeline:", pipeline)
        date_to_total = {
            datetime(
                result["_id"]["year"], result["_id"]["month"], result["_id"]["day"]
            ).date(): result["daily_total"]
            for result in results
        }
        streak_count = 0
        check_date = today

        while check_date >= start_date:
            if check_date not in date_to_total:
                # No transactions mean spending is effectively zero, which is less than the target
                streak_count += 1
                check_date -= timedelta(days=1)
            elif date_to_total[check_date] < streak_target:
                # print("Date:", check_date, "Total:", date_to_total[check_date])
                # Day with transactions below the target contributes to the streak
                streak_count += 1
                check_date -= timedelta(days=1)
            else:
                # print("Date:", check_date, "Total:", date_to_total[check_date])
                # Day with transactions exceeding the target breaks the streak
                break

        return streak_count
    except Exception as e:
        print(app.logger.error(traceback.format_exc()))
        return 0


def get_comparison_data(user_id):
    end_date = date.today()
    start_date = end_date - timedelta(days=30)
    print("Start Date:", start_date)
    print("End Date:", end_date)
    start_date = start_date.strftime("%Y-%m-%d")
    end_date = end_date.strftime("%Y-%m-%d")
    
    pipeline = [
            {
                "$match": {
                    "user_id": user_id,
                }
            },
            {
                "$addFields": {
                    "all_transactions_array": {"$objectToArray": "$all_transactions"}
                }
            },
            {"$unwind": "$all_transactions_array"},
            {"$unwind": "$all_transactions_array.v.transactions"},
            {
                "$match": {
                    "all_transactions_array.v.transactions.date": {
                        "$gte": start_date,
                        "$lte": end_date,
                    }
                }
            },
            {
                "$project": {
                    "yearMonth": {
                        "$dateToString": {
                            "format": "%Y-%m",
                            "date": {
                                "$dateFromString": {
                                    "dateString": "$all_transactions_array.v.transactions.date",
                                    "format": "%Y-%m-%d",
                                }
                            },
                        }
                    },
                    "amount": "$all_transactions_array.v.transactions.amount",
                }
            },
            {"$group": {"_id": "$yearMonth", "total_spending": {"$sum": "$amount"}}},
            {"$sort": {"_id": 1}},
        ]
    print(type(pipeline))
    spending = list(app.db.transaction_data.aggregate(copy.deepcopy(pipeline)))
    user_spending = 0
    for spending in spending: 
        user_spending += spending["total_spending"]
    print("User Spending:", user_spending)
    
    pipeline.pop(0)
    spending = list(app.db.transaction_data.aggregate(pipeline))
    total_spending = 0
    for spending in spending: 
        total_spending += spending["total_spending"]
    
    total_user_count = app.db.transaction_data.count_documents({})
    average_spending = total_spending / total_user_count
    
    
    result = {
        "user_comparison": average_spending - user_spending,
    }
    
    return result