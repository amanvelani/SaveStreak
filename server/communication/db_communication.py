from collections import defaultdict
from datetime import datetime
import traceback
from flask import current_app as app
import random


def get_custom_location_data():
    try:
        result = app.db.custom_location_data.find({}, {"_id": 0})
        result = list(result)
        selected_location = random.choice(result)
        merchant = selected_location['merchant']
        selected_location.pop('merchant')
        return selected_location, merchant
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


def save_user_info(user_id, access_token, item_id, bank_information):
    try:
        app.db.user_info.update_one({"user_id": user_id}, {
            "$push": {
                "accounts": {
                    "access_token": access_token,
                    "item_id": item_id,
                    "bank_information": bank_information
                }
            }
        }, upsert=True)
    except Exception as e:
        print(e)
        return []


def get_user_access_token(user_id):
    try:
        result = app.db.user_info.find_one({"user_id": user_id})
        accounts = result['accounts']
        result = []
        for account in accounts:
            result.append(
                {"access_token": account['access_token'], "item_id": account['item_id']})

        return result
    except Exception as e:
        print(e)
        return []


# [
#     user_id,
#     transactions:
#         item_id:
#             all_transactions
#             cursor

# ]

def is_user_transaction_data_available(user_id, item_id):
    try:
        result = app.db.transaction_data.find_one({"user_id": user_id})
        transactions = result['all_transactions']
        if item_id in transactions:
            return transactions[item_id]['cursor']
        else:
            return ''
    except Exception as e:
        print(e)
        return ''


def save_user_transaction_data(user_id, transactions, cursor, item_id):
    try:
        if transactions == []:
            app.db.transaction_data.update_one({"user_id": user_id}, {
                "$set": {
                    "all_transactions." + item_id + ".cursor": cursor,
                }
            }, upsert=True)
        elif app.db.transaction_data.find_one({"user_id": user_id}) is not None:
            app.db.transaction_data.update_one({"user_id": user_id}, {
                "$push": {
                    "all_transactions." + item_id + ".transactions": {
                        "$each": transactions
                    }
                },
                "$set": {
                    "all_transactions." + item_id + ".cursor": cursor
                }
            }, upsert=True)
        else:
            app.db.transaction_data.insert_one({
                "user_id": user_id,
                "all_transactions": {
                    item_id: {
                        "transactions": transactions,
                        "cursor": cursor
                    }
                }})
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        return []


def get_recent_transactions(user_id):
    try:
        latest_transactions = list(app.db.transaction_data.find(
            {"user_id": user_id},
            {"_id": 0, "all_transactions": 1}
        ))
        accounts = latest_transactions[0].get('all_transactions')
        all_transactions = []
        total_expenses = 0
        for each_account in accounts.values():
            for each_transaction in each_account.get('transactions', []):
                all_transactions.append(each_transaction)
                total_expenses += each_transaction.get('amount', 0)
        sorted_transactions = sorted(all_transactions, key=lambda d: d['date'])

        return sorted_transactions, total_expenses

        # return latest_transactions[0].get('transactions')
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
        start_of_month = datetime(
            datetime.today().year, datetime.today().month, 1)
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
    # pipeline = [
    #     {"$match": {"user_id": user_id}},
    #     {"$unwind": "$transactions"},
    #     {"$group": {
    #         "_id": "$transactions.location",
    #         "transactions": {
    #             "$push": {
    #                 "name": "$transactions.name",
    #                 "amount": "$transactions.amount"
    #             }
    #         }
    #     }},
    #     {"$project": {
    #         "location": "$_id",
    #         "transactions": {
    #             "$map": {
    #                 "input": {
    #                     "$slice": [
    #                         {"$sortArray": {
    #                             "input": "$transactions",
    #                             "sortBy": {"amount": -1}
    #                         }},
    #                         5
    #                     ]
    #                 },
    #                 "as": "transaction",
    #                 "in": {
    #                     "name": "$$transaction.name",
    #                     "amount": "$$transaction.amount"
    #                 }
    #             }
    #         }
    #     }},
    #     {"$sort": {"transactions.amount": -1}}
    # ]

    # result = list(app.db.transaction_data.aggregate(pipeline))
    # return result

    document = app.db.transaction_data.find_one({"user_id": user_id})
    if document and "all_transactions" in document:
        # Flatten the transaction data
        transactions = flatten_transactions(document["all_transactions"])

        # # Sort transactions by the amount, descending
        # transactions_sorted = sorted(transactions, key=lambda x: x['amount'], reverse=True)

        # Optionally, limit to the top 5 transactions
        # top_transactions = transactions_sorted[:5]

    location_groups = defaultdict(list)
    location_sums = defaultdict(float)
    location_name = defaultdict(str)

    # Group transactions by location and sum the amounts
    for transaction in transactions:
        # Creating a tuple of city, country, region
        location_key = tuple(transaction['location'].values())
        location_groups[location_key].append(transaction)
        location_sums[location_key] += transaction['amount']
        location_name[location_key] += transaction['merchant_name']

    # Sort locations by total summed amount in descending order and select top 5
    top_locations = sorted(location_sums.items(),
                           key=lambda x: x[1], reverse=True)[:5]

    result = []
    app.logger.debug(location_groups)
    for location, total_amount in top_locations:
        # app.logger.debug(location_name[])
        result.append({
            "lat": location[3],
            "lon": location[4],
            "amount": total_amount,
            "name": "name"
        })

    return result


def get_user_linked_accounts(user_id):
    try:
        result = app.db.user_info.find_one(
            {"user_id": user_id}, {"_id": 0, "accounts": 1})
        accounts = result.get('accounts', [])
        for each in accounts:
            each['name'] = each.get('name', "Test")
        return accounts
    except Exception as e:
        app.logger.debug(traceback.format_exc())
        return []


def flatten_transactions(user_transactions):
    all_transactions = []
    for transaction_entry in user_transactions.values():
        if 'transactions' in transaction_entry:
            for transaction in transaction_entry['transactions']:
                all_transactions.append(transaction)
    return all_transactions
