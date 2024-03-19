from flask import Flask
from flask_session import Session
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from datetime import timedelta
import secrets
from models import db
from routes import init_routes
from config import Config
from flask_socketio import SocketIO, emit, join_room, leave_room
from socketioRoutes import init_socket_route

app = Flask(__name__)
app.config.from_object(Config) 

# Initialiser les extensions    
db.init_app(app)
jwt = JWTManager(app)
Session(app)
CORS(app)

socketio = SocketIO(app, cors_allowed_origins="*")
# ----------------- SocketIO Routes -----------------
@socketio.on('connect')
def handle_connect():
    print('Client connected, emitting response')
    emit('connectResponse', 'Serverside OK')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')
    
@socketio.on('message')
def handle_message(msg):
    print('Received message:', msg)
    emit('message', msg, broadcast=True)

@socketio.on('private_message')
def handle_private_message(data):
    print("Received private message: ", data)
    sender = data['sender']
    recipient = data['recipient']
    message = data['message']
    # Création du nom de la room avec les noms des utilisateurs triés en ordre alphabétique
    users = sorted([sender, recipient])    
    room_name = '_'.join(users)        
    #emit('message_ack', {'success': True})
    print("Emitting new_message event with sender: "+sender+" and message: "+message+" to room: "+room_name)
    emit('new_message', {'sender': sender, 'message': message}, room=room_name)
    
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
    print("Création d'un canal de communication entre "+data['user1']+" et "+data['user2'])
    user1 = data['user1']
    user2 = data['user2']    
    # Trier les noms d'utilisateur en ordre alphabétique
    users = sorted([user1, user2])    
    # Concaténer les noms d'utilisateur pour former le nom de la salle de discussion
    room_name = '_'.join(users)    
    # Rejoindre la salle de discussion
    join_room(room_name)    
    # Émettre l'événement pour indiquer que la conversation a commencé avec le nom de la salle de discussion
    print("Emitting chatStarted event with room name: "+room_name)
    socketio.emit('chatStarted', room_name)

    
# ----------------- SocketIO Routes -----------------
        
# Initialiser les routes
init_routes(app)

init_socket_route(app)


if __name__ == '__main__':
    socketio.run(app, port=8000)
    #app.run(host='0.0.0.0', port=8000)

# For production server    
#if __name__ == "__main__":
#    from waitress import serve
#    serve(app, host="0.0.0.0", port=8000)