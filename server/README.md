# SaveStreak Server

## Table of Contents
- [Installation](#installation)
- [Description of API's](#description-of-apis)

## Installation
To run the server follow the steps below:
1. Make an .env file in the api directory. An example of the .env file is provided in the [.env.example](./.env.example) file. Use the following command to create a .env file:
```bash
cp .env.example .env
```
2. Install the dependencies by running the following command:
```bash
pip3 install -r requirements.txt
```
3. Run the server by running the following command:
```bash
python3 flask_app.py
```

## Description of API's
The server provides the following API's:
1. `/health` - This API is used to check the health of the server.
2. `/plaid/create-link-token` - This API is used to create a link token for the plaid link.
3. `/plaid/set-access-token` - This API gets the following information from the client and then saves the access token in the database:
    - public_token
    - user_id
4. `/plaid/get-transactions` - This API is used to get the transactions for the user. The API gets the following information from the client:
    - user_id
