import os
import flask
from dotenv import load_dotenv
from flask.json import jsonify
from flask_pymongo import PyMongo
from flask_cors import CORS
import communication.plaid_communication as plaid_communication
    
def create_app(test_config=None):
    load_dotenv()
    # create and configure the app
    app = flask.Flask(__name__, instance_relative_config=True)
    CORS(app)
    app.url_map.strict_slashes = False
    app.register_blueprint(plaid_communication.bp)

    # Setup MongoDB connection
    db_conn_string = f"mongodb+srv://{os.environ['DB_USERNAME']}:{os.environ['DB_PASSWORD']}@{os.environ['DB_HOSTNAME']}/{os.environ['DB_NAME']}?authSource=admin"
    app.config["MONGO_URI"] = db_conn_string
    mongo = PyMongo(app)
    app.db = mongo.db

    @app.route('/hello')
    def hello():
        return 'Hello, World!'
    
    @app.route('/health', methods=['GET'])
    def health():
        return jsonify({'status': 'healthy'})

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host='localhost', port=5000, debug=True)
