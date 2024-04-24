
from flask import current_app as app

def get_custom_location_data():
    try:
       result = app.db.custom_location_data.find({}, {"_id": 0})
       return list(result)
    except Exception as e:
        print(e)
        return []