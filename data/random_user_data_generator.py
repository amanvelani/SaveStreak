import json
import random
from datetime import datetime, timedelta
from copy import deepcopy
from faker import Faker
import os

fake = Faker()

def random_date_between(start_date, end_date):
    """Generate a random date between two dates."""
    time_between_dates = end_date - start_date
    random_days = random.randrange(time_between_dates.days)
    return start_date + timedelta(days=random_days)

def generate_transaction_description():
    """Generate a realistic transaction description with a merchant name."""
    company = fake.company()
    identifier = ''.join([str(random.randint(0, 9)) for _ in range(8)])
    return f"{company} {identifier}. Merchant name: {company} {identifier}"

def random_account_number():
    """Generate a random bank account number."""
    return ''.join([str(random.randint(0, 9)) for _ in range(16)])

def random_routing_number():
    """Generate a random routing number."""
    return ''.join([str(random.randint(0, 9)) for _ in range(9)])

def generate_identity():
    """Generate a fake identity with realistic names and addresses."""
    return {
        'names': [fake.company()],
        'addresses': [{
            'primary': True,
            'data': {
                'country': 'US',
                'city': fake.city(),
                'street': fake.street_address(),
                'postal_code': fake.zipcode(),
                'region': fake.state_abbr()
            }
        }]
    }

def generate_bank_name():
    """Generate a fake bank name."""
    return fake.company() + " Bank"

def load_template_data(file_path):
    """Load JSON data from a file."""
    with open(file_path, "r") as file:
        return json.load(file)

# Load template data
template_data = load_template_data("./template_data.json")

# Define the date range for transactions
start_date = datetime.strptime('2024-02-15', '%Y-%m-%d')
end_date = datetime.strptime('2024-05-04', '%Y-%m-%d')

dir = f"./custom_user_data"
if not os.path.exists(dir):
    os.makedirs(dir)

# Generate fake data for 10 users
num_users = 50
for i in range(num_users):
    user_data = deepcopy(template_data)
    account = user_data['override_accounts'][0]

    # Randomize account details
    account['starting_balance'] = round(random.uniform(10000, 30000), 2)
    account['numbers']['account'] = random_account_number()
    account['numbers']['ach_routing'] = random_routing_number()
    account['meta']['name'] = generate_bank_name()
    account['meta']['official_name'] = account['meta']['name'] + " Checking"
    account['identity'] = generate_identity()

    # Update transactions with random and realistic data
    num_transactions = random.randint(100, 200)
    account['transactions'] = []
    for _ in range(num_transactions):
        trans_date = random_date_between(start_date, end_date)
        transaction = {
            'date_transacted': trans_date.strftime('%Y-%m-%d'),
            'date_posted': (trans_date + timedelta(days=1)).strftime('%Y-%m-%d'),
            'amount': round(random.uniform(-1000, 1000), 2),
            'description': generate_transaction_description(),
            'currency': 'USD'
        }
        account['transactions'].append(transaction)

    # Save the user data in the custom_user_data folder with format custom_user_data_{user_id}.json
    user_id = fake.uuid4()
    
    file_path = f"./custom_user_data/custom_user_data_{i}.json"
    with open(file_path, "w") as file:
        json.dump(user_data, file, indent=4)
    print(f"User data saved to {file_path}")

