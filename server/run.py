from flask import Flask
from flask_session import Session
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from datetime import timedelta, datetime
import secrets 
from models import db
from routes import init_routes
from config import Config
from flask_socketio import SocketIO, emit, join_room, leave_room
from flask_mail import Mail

import eventlet
import eventlet.wsgi
from eventlet import wsgi
from eventlet import wrap_ssl

from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import os
from flask import Flask, jsonify, request
from flask_wtf.csrf import CSRFProtect
import itsdangerous
import logging
from logging.handlers import RotatingFileHandler


app = Flask(__name__)
app.config.from_object(Config) 


## Configuration du limiteur de requête
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://",
)
# Limiter toutes les routes à 100 requêtes par minute pour chaque adresse IP
limiter.limit("100/minute")



# Initialiser les extensions    
db.init_app(app)
jwt = JWTManager(app)
mail = Mail(app)
Session(app)
CORS(app)
# csrf = CSRFProtect(app)
csrf = CSRFProtect()
## Durée de vie jeton csrf
app.config['WTF_CSRF_TIME_LIMIT'] = 600 # 600 secondes (10 minutes)
# custom_csrf_header = 'X-MON-CSRF-TOKEN'
csrf.init_app(app)


socketio = SocketIO(app, cors_allowed_origins="*")
# ----------------- SocketIO Routes -----------------  
@socketio.on('connect')
def handle_connect():
    print("--SOCKETIO ROUTE: handle_connect")
    print("     Calling 'connect' event handler")
    print('     Client connected, response emitted')
    emit('connectResponse', 'SERVERSIDE OK')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')
    
@socketio.on('message')
def handle_message(msg):
    print('Received message:', msg)
    emit('message', msg, broadcast=True)

@socketio.on('private_message')
def handle_private_message(data):
    sender_name = data['sender_name']
    sender_id = data['id_sender']
    recipient = data['recipient']
    content = data['content']
    id_conv = data['id_conv']
    date = datetime.now().isoformat()
    is_read = data['is_read'] == 1
    emit('new_message', { # ! PROBLEME D'ENVOIE DE L'EVENEMENT 'new_message' AU CLIENT
        'id_conv': id_conv,
        'id_sender': sender_id,
        'content': content,
        'date': date,
        'is_read': is_read
    }, room=recipient) #? PROBLEME RESOLU : ATTENTION A LA ROOM DANS LAQUELLE ON ENVOIE LE MESSAGE SINON IL NE S'ENVOIE PAS
    
@socketio.on('join')
def on_join(data):
    username = data['username']
    room = data['room']
    print(f"Joining room: {room} with username: {username}")
    join_room(room)
    print(f"Rooms after join: {room()}")
    socketio.emit('message', f'{username} has entered the room.', to=room)

@socketio.on('leave')
def on_leave(data):
    username = data['username']
    room = data['room']
    leave_room(room)
    emit('message', f'{username} has left the room.', to=room)
        
@socketio.on('start_chat')
def start_chat(data):
    print(" --SOCKETIO ROUTE: start_chatUPDATED")
    print("Création d'un canal de communication pour le groupe " + data['groupName'])
    room_name = data['groupName']  
    join_room(room_name)    
    # Émettre l'événement pour indiquer que la conversation a commencé avec le nom de la salle de discussion
    print("Emitting chatStarted event with room name: "+room_name)
    socketio.emit('chatStarted', room_name)









######################################################################################################




    
# ----------------- SocketIO Routes -----------------
        
# Initialiser les routes
init_routes(app,mail,csrf,limiter)


if __name__ == '__main__':
    # Ancienne façon de lancer le backend avec les routes (à garder pour l'instant)
    #socketio.run(app, port=8000)
    #app.run(host='0.0.0.0', port=8000, ssl_context="adhoc")

    ########################################################################
    # Nouvelle façon de lancer le backend avec https
    cert_path = 'cert_path/server.pem'
    key_path = 'key_path/server.pem'
    # Créer un serveur SSL avec wrap_ssl()  
    ssl_sock = wrap_ssl(eventlet.listen(('localhost', 8000)), certfile=cert_path, keyfile=key_path, server_side=True) # remplacez localhost par 192.168.1.28 (l'adresse IP de votre de l'ordi) pour host le serveur en local
    # Exécuter l'application Flask avec le serveur SSL
    wsgi.server(ssl_sock, app)
