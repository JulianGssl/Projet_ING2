from flask import Flask, render_template
from flask_socketio import SocketIO, emit, join_room, leave_room

socketio = SocketIO()

def init_socket_route(app):
    
    @socketio.on('connect', namespace='/chat')
    def handle_connect():
        print('Client connected')

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
        room = f'{sender}_{recipient}'
        emit('message', {'sender': sender, 'message': message}, room=room)
        
    @socketio.on('join', namespace='/chat')
    def on_join(data):
        username = data['username']
        room = data['room']
        print(f"Joining room: {room} with username: {username}")
        join_room(room)
        print(f"Rooms after join: {room()}")
        emit('message', f'{username} has entered the room.', to=room)


    @socketio.on('leave')
    def on_leave(data):
        username = data['username']
        room = data['room']
        leave_room(room)
        emit('message', f'{username} has left the room.', to=room)