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


@user_bp.route("/get-transaction", methods=["POST"])
def get_transaction():
    user_id = request.json["user_id"]
    response = {
        "latest_transactions": db.get_recent_transactions(user_id),
        "top_categories": db.get_category_wise_spend(user_id),
        "total_spend_this_month": db.get_current_month_spend(user_id),
    }

    return jsonify(response)


@user_bp.route("/get-transaction-by-location", methods=["POST"])
def transactions_by_location():
    user_id = request.json["user_id"]
    response = {"transactions": db.get_user_transactions_by_location(user_id)}
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
