import os
import json
import time
from datetime import date, timedelta
import communication.db_communication as db
from dotenv import load_dotenv
from flask import (
    Blueprint,
    flash,
    g,
    redirect,
    render_template,
    request,
    session,
    url_for,
    jsonify,
    current_app as app,
)

user_bp = Blueprint("user", __name__, url_prefix="/user")

@user_bp.route("/register-user", methods=["POST"])
def register_user():
    # "userId": userId,
    #         "email": email,
    #         "name": name,
    #         "age": age,
    #         "sex": sex,
    #         "profileImageURL":profileImageUrl,

    user_id = request.json["userId"]
    email = request.json["email"]
    name = request.json["name"]
    age = request.json["age"]
    sex = request.json["sex"]
    profileImageURL = "https://firebasestorage.googleapis.com:443/v0/b/savestreak-f2265.appspot.com/o/profile_images/" + user_id + ".jpg"
    
    db.register_user(user_id, email, name, age, sex, profileImageURL)
    
    return {
        "success": True
    }

@user_bp.route("/get-user-data", methods=["POST"])
def get_user_data():
    user_id = request.json["user_id"]
    user_data = db.get_user_data(user_id)
    return jsonify(user_data)

@user_bp.route("/get-transaction", methods=["POST"])
def get_transaction():
    user_id = request.json['user_id']
    transactions, total_expenses = db.get_recent_transactions(user_id)
    app.logger.debug(transactions[0])
    response = {
        "latest_transactions": transactions,
        # "top_categories": db.get_category_wise_spend(user_id),
        "total_spend_this_month": total_expenses
    }

    return jsonify(response)


@user_bp.route("/get-transaction-by-location", methods=["POST"])
def transactions_by_location():
    user_id = request.json["user_id"]
    category = request.json.get("category") or None
    start_date = request.json.get("start_date") or None
    end_date = request.json.get("end_date") or None
    print("Category: ", category)
    print("Start Date: ", start_date)
    print("End Date: ", end_date)
    response = {"transactions": db.get_user_transactions_by_location(user_id, category=category, start_date=start_date, end_date=end_date)}
    return jsonify(response)


@user_bp.route("/get-category-spend-monthly", methods=["POST"])
def get_total_spend_monthly():
    user_id = request.json["user_id"]
    category_wise_spend = db.get_category_wise_spend(user_id)
    response = {
        "category_wise_spend": category_wise_spend,
    }
    return jsonify(response)


@user_bp.route("/get-category-spend-custom-date-range", methods=["POST"])
def get_total_spend_custom_date_range():
    user_id = request.json["user_id"]
    start_date = request.json["start_date"]
    end_date = request.json["end_date"]
    response = {
        "category_wise_spend": db.get_category_wise_spend(user_id, start_date, end_date)
    }
    return jsonify(response)


@user_bp.route("/get-spending-trend", methods=["POST"])
def get_spending_trend():
    user_id = request.json["user_id"]
    response = {"spending_trend": db.get_spending_trend(user_id)}
    return jsonify(response)


@user_bp.route("/get-custom-spending-trend", methods=["POST"])
def get_custom_spending_trend():
    user_id = request.json["user_id"]
    start_month = request.json["start_month"]
    end_month = request.json["end_month"]
    response = {
        "spending_trend": db.get_spending_trend(
            user_id, start_month=start_month, end_month=end_month
        )
    }
    return jsonify(response)


@user_bp.route('/get-user-accounts', methods=['POST'])
def get_user_linked_accounts():
    user_id = request.json.get('user_id', None)
    return jsonify(db.get_user_linked_accounts(user_id))

@user_bp.route("/set-streak-category", methods=["POST"])
def set_streak_category():
    user_id = request.json["user_id"]
    category = request.json["category"]
    target = request.json["target"]
    db.set_user_streak_category(user_id, category, target)
    return jsonify({"status": "success"})


@user_bp.route("/get-streak-data", methods=["POST"])
def get_streak_data():
    user_id = request.json["user_id"]
    category, target = db.get_user_streak_category(user_id)
    response = {"streak_data": db.calculate_streak(user_id, category, target)}
    return jsonify(response)
