import os
import flask
from dotenv import load_dotenv
#import flask_breadcrumbs
import flask_ipban
from flask_pymongo import PyMongo
from flask_cors import CORS

from . import endpoints
    


def create_app(test_config=None):

    load_dotenv()
    # ------------------------
    # create and configure the app
    # ------------------------
    app = flask.Flask(__name__, instance_relative_config=True)
    CORS(app)
    app.url_map.strict_slashes = False
    app.register_blueprint(endpoints.bp)
    db_conn_string = f"mongodb+srv://{os.environ.get('DB_USERNAME')}:{os.environ.get('DB_PASSWORD')}@{os.environ.get('DB_HOSTNAME')}/{os.environ.get('DB_NAME')}?authSource=admin"

    app.config["MONGO_URI"] = db_conn_string
    mongo = PyMongo(app)
    app.db = mongo.db

    @app.route('/hello')
    def hello():
        return 'Hello, World!'
    

    return app

