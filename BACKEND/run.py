from flask import Flask
from flask_session import Session
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from datetime import timedelta
import secrets
from models import db
from routes import init_routes
from config import Config

app = Flask(__name__)
app.config.from_object(Config) 

# Initialiser les extensions
db.init_app(app)
jwt = JWTManager(app)
Session(app)
CORS(app)

# Initialiser les routes
init_routes(app)
# Ajouter d'autres blueprints au besoin

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
