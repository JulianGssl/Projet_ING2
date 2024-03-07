import dbm
from flask import Flask, redirect, url_for
from flask import request, jsonify, session
##from signal_protocol_dart import SignalProtocolStore, SignalCipher, SignalKeyHelper
from flask_session import Session
from pymysql import DBAPISet
from redis import Redis
import logging
from Crypto.PublicKey import ECC
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from base64 import b64encode, b64decode
from flask_login import LoginManager
from Crypto.PublicKey import ECC
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from OpenSSL import crypto, SSL
import time
from flask_cors import CORS
import logging
from logging.handlers import RotatingFileHandler

from datetime import timedelta
import secrets
from flask_jwt_extended import JWTManager, create_access_token, get_jwt, get_jwt_identity, jwt_required

from flask import jsonify
from datetime import datetime, timezone
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required, jwt_manager
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from datetime import timedelta
from datetime import timezone

app =  Flask(__name__)
##app.session_interface = MySessionInterface()
##app.config['SESSION_TYPE'] = 'filesystem'  
app.config['SECRET_KEY'] =secrets.token_hex(32)
app.config['JWT_SECRET_KEY'] =secrets.token_hex(32)
jwt = JWTManager(app)
# Liste noire des tokens révoqués
blacklisted_tokens = set()
app.config['SESSION_COOKIE_NAME'] = 'custom_session_cookie'  # Nom du cookie de session
app.config['SESSION_COOKIE_HTTPONLY'] = True  # Marquer le cookie de session comme étant accessible uniquement via HTTP
app.config['SESSION_COOKIE_SECURE'] = True  # Marquer le cookie de session comme sécurisé (utilisation de HTTPS)
app.config['SESSION_COOKIE_SAMESITE'] = 'None'  # Définir la politique SameSite pour le cookie de session
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)

app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///your_database.db"  # Chemin de votre base de données SQLite
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
db = SQLAlchemy(app)

# app.config['SESSION_TYPE'] = 'redis'
# app.config['SESSION_REDIS'] = Redis(host='localhost', port=6379)

# app.config['JWT_SECRET_KEY'] = b'_5#y2#y2L"F4Q8L"\xec]F4Q"F4Q88z\n\xec]/'
# jwt = JWTManager(app)

# secret_key2 = secrets.token_hex(32)
# app.config['SECRET_KEY'] = b'_5#y2L"F4Q8z\n\xec]/'


##app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
##app.secret_key = secret_key2

Session(app)
CORS(app)

# Initialize Flask-Login
login_manager = LoginManager()
login_manager.init_app(app)



from flask_login import UserMixin
from flask_login import login_user, logout_user, login_required




contacts=[
    {
        'Pseudo1':'Alice',
        'Pseudo2':'Bob',
    }
]

users=[
    {
        'Pseudo':'Alice',
        'Password':'123test',
    },
    {
        'Pseudo':'Bob',
        'Password':'123test',
    }
]

messages=[
    {
        'Sender':'Alice',
        'Receiver':'Bob',
        'Content': 'this is the message from Alice'
    }
]





# app.config['SESSION_TYPE'] = 'redis'
# app.config['SESSION_REDIS'] = Redis(host='localhost', port=6379)
# Session(app)
@app.route('/login', methods=['POST'])
def login():
    req_data = request.get_json()
    username = req_data['username']
    password = req_data['password']
    
    for user in users:
        if user['Pseudo'] == username and user['Password'] == password:
            # Si l'utilisateur est authentifié, créer un token JWT
            access_token = create_access_token(identity=username)
            return jsonify({'access_token': access_token}), 200
    
    return jsonify({'message': 'Invalid credentials'}), 401

# Route protégée nécessitant un token JWT valide
@app.route('/protected', methods=['GET'])
@jwt_required()
def protected_route():
    current_user = get_jwt_identity()
    return jsonify({'message': 'Login successful', 'user': current_user}), 200




@app.route('/contacts', methods=['GET'])
@jwt_required()
def get_contacts():
    username = get_jwt_identity()
    user_contacts = [contact['Pseudo2'] if contact['Pseudo1'] == username else contact['Pseudo1'] for contact in contacts if username in contact.values()]
    return jsonify({'contacts': user_contacts}), 200


# Créez une table pour stocker les tokens révoqués
class TokenBlocklist(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(36), nullable=False, unique=True)
    created_at = db.Column(dbm.DateTime, nullable=False, default=datetime.now)

# Callback pour vérifier si le token est révoqué
@jwt_manager.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    jti = jwt_payload["jti"]
    token = TokenBlocklist.query.filter_by(jti=jti).first()
    return token is not None

# Endpoint pour révoquer le token JWT actuel
@app.route("/logout", methods=["POST"])
@jwt_required()
def logout():
    jti = get_jwt()["jti"]
    token = TokenBlocklist(jti=jti)
    DBAPISet.session.add(token)
    db.session.commit()
    return jsonify(message="Token revoked"), 200

@app.route('/messages', methods=['GET'])
def get_messages():
    if 'username' in session:
        username = session['username']
        user_messages = [msg for msg in messages if msg['Sender'] == username or msg['Receiver'] == username]
        return jsonify({'messages': user_messages}), 200
    else:
        return jsonify({'message': 'Unauthorized access'}), 401

@app.route('/send_message', methods=['POST'])
def send_message():
    if 'username' in session:
        req_data = request.get_json()
        sender = session['username']
        receiver = req_data['receiver']
        content = req_data['content']
        messages.append({'Sender': sender, 'Receiver': receiver, 'Content': content})
        return jsonify({'message': 'Message sent successfully'}), 200
    else:
        return jsonify({'message': 'Unauthorized access'}), 401



handler = RotatingFileHandler('app.log', maxBytes=10000, backupCount=1)
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)

if __name__ == '__main__':
    ##logging.basicConfig(level=logging.DEBUG)
    ##certificat SSL/TLS pour activer HTTPS            ,ssl_context=('path/to/cert.pem', 'path/to/key.pem')   ,ssl_context=('cert_path/server.pem', 'key_path/server.pem')
    ## Penser à faire un certificat auto-signer    ,ssl_context=('cert_path/server.crt', 'key_path/server.key')
    app.run(host='0.0.0.0',debug=True,port=8000,ssl_context="adhoc")