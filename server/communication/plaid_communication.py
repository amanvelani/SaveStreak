import os
import json
import time
from datetime import date, timedelta
import communication.db_communication as db
from dotenv import load_dotenv
from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for, jsonify
)
import plaid
from plaid.model.payment_amount import PaymentAmount
from plaid.model.payment_amount_currency import PaymentAmountCurrency
from plaid.model.products import Products
from plaid.model.country_code import CountryCode
from plaid.model.recipient_bacs_nullable import RecipientBACSNullable
from plaid.model.payment_initiation_address import PaymentInitiationAddress
from plaid.model.payment_initiation_recipient_create_request import PaymentInitiationRecipientCreateRequest
from plaid.model.payment_initiation_payment_create_request import PaymentInitiationPaymentCreateRequest
from plaid.model.payment_initiation_payment_get_request import PaymentInitiationPaymentGetRequest
from plaid.model.link_token_create_request_payment_initiation import LinkTokenCreateRequestPaymentInitiation
from plaid.model.item_public_token_exchange_request import ItemPublicTokenExchangeRequest
from plaid.model.link_token_create_request import LinkTokenCreateRequest
from plaid.model.link_token_create_request_user import LinkTokenCreateRequestUser
from plaid.model.asset_report_create_request import AssetReportCreateRequest
from plaid.model.asset_report_create_request_options import AssetReportCreateRequestOptions
from plaid.model.asset_report_user import AssetReportUser
from plaid.model.asset_report_get_request import AssetReportGetRequest
from plaid.model.asset_report_pdf_get_request import AssetReportPDFGetRequest
from plaid.model.auth_get_request import AuthGetRequest
from plaid.model.transactions_sync_request import TransactionsSyncRequest
from plaid.model.identity_get_request import IdentityGetRequest
from plaid.model.investments_transactions_get_request_options import InvestmentsTransactionsGetRequestOptions
from plaid.model.investments_transactions_get_request import InvestmentsTransactionsGetRequest
from plaid.model.accounts_balance_get_request import AccountsBalanceGetRequest
from plaid.model.accounts_get_request import AccountsGetRequest
from plaid.model.investments_holdings_get_request import InvestmentsHoldingsGetRequest
from plaid.model.item_get_request import ItemGetRequest
from plaid.model.institutions_get_by_id_request import InstitutionsGetByIdRequest
from plaid.model.transfer_authorization_create_request import TransferAuthorizationCreateRequest
from plaid.model.transfer_create_request import TransferCreateRequest
from plaid.model.transfer_get_request import TransferGetRequest
from plaid.model.transfer_network import TransferNetwork
from plaid.model.transfer_type import TransferType
from plaid.model.transfer_authorization_user_in_request import TransferAuthorizationUserInRequest
from plaid.model.ach_class import ACHClass
from plaid.model.transfer_create_idempotency_key import TransferCreateIdempotencyKey
from plaid.model.transfer_user_address_in_request import TransferUserAddressInRequest
from plaid.model.signal_evaluate_request import SignalEvaluateRequest
from plaid.model.statements_list_request import StatementsListRequest
from plaid.model.link_token_create_request_statements import LinkTokenCreateRequestStatements
from plaid.model.statements_download_request import StatementsDownloadRequest
from plaid.api import plaid_api


bp = Blueprint('plaid', __name__, url_prefix='/plaid')


load_dotenv()


PLAID_CLIENT_ID = os.getenv('PLAID_CLIENT_ID')
PLAID_SECRET = os.getenv('PLAID_CLIENT_SECRET')
PLAID_ENV = os.getenv('PLAID_ENV', 'sandbox')
PLAID_PRODUCTS = os.getenv('PLAID_PRODUCTS', 'transactions').split(',')
PLAID_COUNTRY_CODES = os.getenv('PLAID_COUNTRY_CODES', 'US').split(',')

def empty_to_none(field):
    value = os.getenv(field)
    if value is None or len(value) == 0:
        return None
    return value

host = plaid.Environment.Sandbox

if PLAID_ENV == 'sandbox':
    host = plaid.Environment.Sandbox

if PLAID_ENV == 'development':
    host = plaid.Environment.Development

if PLAID_ENV == 'production':
    host = plaid.Environment.Production

# Parameters used for the OAuth redirect Link flow.
# Set PLAID_REDIRECT_URI to 'http://localhost:3000/'
# The OAuth redirect flow requires an endpoint on the developer's website
# that the bank website should redirect to. You will need to configure
# this redirect URI for your client ID through the Plaid developer dashboard
# at https://dashboard.plaid.com/team/api.
PLAID_REDIRECT_URI = empty_to_none('PLAID_REDIRECT_URI')

configuration = plaid.Configuration(
    host=host,
    api_key={
        'clientId': PLAID_CLIENT_ID,
        'secret': PLAID_SECRET,
        'plaidVersion': '2020-09-14'
    }
)

api_client = plaid.ApiClient(configuration)
client = plaid_api.PlaidApi(api_client)

products = []
for product in PLAID_PRODUCTS:
    products.append(Products(product))

@bp.route('/create-link-token', methods=['GET'])
def create_link_token():
    try:
        request = LinkTokenCreateRequest(
            products=products,
            client_name="Save Streak",
            country_codes=list(map(lambda x: CountryCode(x), PLAID_COUNTRY_CODES)),
            language='en',
            user=LinkTokenCreateRequestUser(
                client_user_id=str(time.time())
            )
        )
        if PLAID_REDIRECT_URI!=None:
            request['redirect_uri']=PLAID_REDIRECT_URI
        if Products('statements') in products:
            statements=LinkTokenCreateRequestStatements(
                end_date=date.today(),
                start_date=date.today()-timedelta(days=30)
            )
            request['statements']=statements
        response = client.link_token_create(request)
        print(response)
        return jsonify(response.to_dict())
    except plaid.ApiException as e:
        print(e)
        return json.loads(e.body)
    
@bp.route('/set-access-token', methods=['POST'])
def get_access_token():
    public_token = request.json['public_token']
    user_id = request.json['user_id']
    try:
        exchange_request = ItemPublicTokenExchangeRequest(
            public_token=public_token)
        exchange_response = client.item_public_token_exchange(exchange_request)
        access_token = exchange_response['access_token']
        item_id = exchange_response['item_id']
        bank_info = get_accounts(access_token)
        db.save_user_info(user_id, access_token, item_id, bank_info)
        get_transactions()
        return jsonify({'Status': 'Success'})
    except plaid.ApiException as e:
       return jsonify({'Status': 'Error', 'Error': e.body})

def get_accounts(access_token):
    try:
        request = AccountsGetRequest(access_token)
        response = client.accounts_get(request)
        bank_info = []
        for response in response['accounts']:
            bank_info.append({
                'account_id': response['account_id'],
                'account_name': response['name'],
                'account_type': response['type'],
                'account_balance': response['balances']['current']
            })
            
        return bank_info
    except plaid.ApiException as e:
        return json.loads(e.body)

@bp.route('/transactions', methods=['POST'])
def get_transactions():
    try:
        user_id = request.json['user_id']
        access_token = (str) (db.get_user_access_token(user_id))
        cursor = db.is_user_transaction_data_available(user_id)
        added = []
        modified = []
        removed = []
        has_more = True
        # Iterate through each page of new transaction updates for item
        while has_more:
            request_transaction = TransactionsSyncRequest(
                access_token=access_token,
                cursor=cursor,
                count=500
            )
            response = client.transactions_sync(request_transaction).to_dict() 
            
            def convert_dates_to_string(data):
                if isinstance(data, dict):
                    for key, value in data.items():
                        data[key] = convert_dates_to_string(value)
                elif isinstance(data, list):
                    data = [convert_dates_to_string(item) for item in data]
                elif isinstance(data, date):
                    return data.isoformat()
                return data
            
            for transaction in response['added']:
                custom_location_data, merchant_name = db.get_custom_location_data()
                category, category_id = db.get_custom_category_data()
                transaction['location'] = custom_location_data
                transaction['category'] = category
                transaction['category_id'] = category_id
                transaction['merchant_name'] = merchant_name
                    
            response = convert_dates_to_string(response)
            added.extend(response['added'])
            modified.extend(response['modified'])
            removed.extend(response['removed'])
            has_more = response['has_more']
            cursor = response['next_cursor']

        latest_transactions = sorted(added, key=lambda t: t['date'])
        db.save_user_transaction_data(user_id, latest_transactions, cursor)
        
        return jsonify({
            'latest_transactions': latest_transactions})

    except plaid.ApiException as e:
        error_response = print(e)
        return jsonify(error_response)
    except Exception as e:
        print(e)
        return jsonify({'error': str(e)})