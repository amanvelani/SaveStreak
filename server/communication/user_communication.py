import os
import json
import time
from datetime import date, timedelta
import communication.db_communication as db
from dotenv import load_dotenv
from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for, jsonify
)

bp = Blueprint('user', __name__, url_prefix='/user')

@bp.route('/get-transaction', methods=['POST'])
def get_transaction():
    user_id = request.json['user_id']
    