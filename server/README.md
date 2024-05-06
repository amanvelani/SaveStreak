# SaveStreak Server
The server is built using Flask and is used to communicate with the Plaid API and the database. The server has API's to communicate with the Plaid API and the database. The server is used to get the transactions from the Plaid API and store them in the database. The server is also used to get the user data from the database and send it to the client.

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
The server has the following API's:
### Plaid communication
1. `/plaid/create-link-token` - This API is used to create a link token for the plaid link.
2. `/plaid/set-access-token` - This API gets the following information from the client and then saves the access token in the database:
    - public_token
    - user_id
3. `/plaid/transactions` - This API is used to get the transactions for the user. The API gets the following information from the client:
    - user_id

### User communication
1. `/user/register-user` - This API is used to register a user into the database. The API gets the following information from the client:
    - userId
    - email
    - name
    - age
    - sex

2. `/user/get-user-data` - This API is used to get the user data from the database. The API gets the following information from the client:
    - userId

3. `/user/get-category-spend-monthly` - This API is used to get the category spend for the user monthly from the database. The API gets the following information from the client:
    - userId

4. `/user/get-category-spend-custom-date-range` - This API is used to get the category spend for the user for a custom date range from the database. The API gets the following information from the client:
    - user_id
    - start_date
    - end_date

5. `/user/get-spending-trend` - This API is used to get the spending trend for the user from the database. The API gets the following information from the client:
    - user_id

6. `/user/get-custom-spending-trend` - This API is used to get the custom spending trend for the user from the database. The API gets the following information from the client:
    - user_id
    - start_date
    - end_date

7. `/user/get-user-accounts` - This API is used to get the user accounts from the database. The API gets the following information from the client:
    - user_id

8. `/user/set-streak-category` - This API is used to set the streak category for the user in the database. The API gets the following information from the client:
    - user_id
    - category
    - target

9. `/user/get-streak-category` - This API is used to get the streak category for the user from the database. The API gets the following information from the client:
    - user_id

10. `/user/get-streak-data` - This API is used to get the streak data for the user from the database. The API gets the following information from the client:
    - user_id

11. `/user/get-comparison-data` - This API is used to get the comparison data for the user from the database. The API gets the following information from the client:
    - user_id

### Database communication
 All the custom queries and aggreate functions that are used by plaids and user API's are stored in the [db_communication.py](./communication/db_communication.py) file.