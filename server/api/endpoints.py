from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for, jsonify
)
from .db_communication import get_custom_location_data

bp = Blueprint('user', __name__, url_prefix='/user')


@bp.route('/health-check', methods=['GET'])
def health_check():
    return jsonify ({"connected": True})   

@bp.route('/custom-locations', methods=['GET'])
def get_custom_location():
    data = get_custom_location_data()
    return jsonify({"data": data})