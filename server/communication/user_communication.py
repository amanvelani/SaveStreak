import os
import json
import time
from datetime import date, timedelta
import communication.db_communication as db
from dotenv import load_dotenv
from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for, jsonify, current_app as app
)

user_bp = Blueprint('user', __name__, url_prefix='/user')

@user_bp.route('/get-transaction', methods=['POST'])
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

@user_bp.route('/get-transaction-by-location', methods=['POST'])
def transactions_by_location():
    user_id = request.json['user_id']
    response = {
        "transactions": db.get_user_transactions_by_location(user_id)
    }
    return jsonify(response)


@user_bp.route('/get-user-accounts', methods=['POST'])
def get_user_linked_accounts():
    user_id = request.json.get('user_id', None)
    response = {
        "accounts": db.get_user_linked_accounts(user_id)
    }
    return jsonify(response)
    