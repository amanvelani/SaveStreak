# Plaid Sandbox Transaction Data
To run the script, you will need to have an .env file in the data directory. An example of the .env file is provided in the [.env.example](./.env.example) file. Use the following command to create a .env file:

```bash
cp .env.example .env
```

## Table of Contents
- [Custom User Data](#custom-user-data)
- [Custom Location Data](#custom-location-data)
- [Custom Category Data](#custom-category-data)

## Custom User Data
The custom user data is stored in the `data/custom_user_data` directory. This data is used to create custom users for the sandbox environment. The custom user data is stored in a JSON file format. To create custom users, we are using [template_data.json](template_data.json) file. We have also created a [script](./random_user_data_generator.py) to generate custom user data. To generate custom user data, run the following command:

```bash
python3 random_user_data_generator.py
```

The script will generate custom user data and store it in the `data/custom_user_data` directory.

## Custom Location Data
The custom location is necessary because the sandbox environment in plaid does not provide location data for the transactions. The custom location data will be stored in the MongoDB database. The custom location data is stored in a JSON file format. We have created a [script](./random_location_data_generator.py) to generate custom location data. To generate custom location data, run the following command:

```bash
python3 random_location_data_generator.py
```

This data will be used by the server at runtime to provide location data for the transactions.

## Custom Category Data
The categoies data for the sandbox environment was very skewed. To provide a more realistic experience, we have used plaid's api to get the categories data. The categories data is stored [here](./categories.json). This is the command to get the categories data from plaid's api:

```bash
curl -X POST https://sandbox.plaid.com/categories/get \
  -H 'Content-Type: application/json' \
  -d '{}'  > categories.json
```
Then using the [script](./save_categories.py) we have saved the categories in the MongoDB database. The categories data will be used by the server at runtime to provide categories data for the transactions.