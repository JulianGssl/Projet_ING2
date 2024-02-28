from flask import Flask
from flask import request, jsonify, session
##from signal_protocol_dart import SignalProtocolStore, SignalCipher, SignalKeyHelper
from flask_session import Session
from redis import Redis
import logging


from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from base64 import b64encode, b64decode
##import 'package:encrypt/encrypt.dart';

# from flask_limiter import Limiter
# from flask_limiter.util import get_remote_address

# from axolotl import axolotl_curve


from Crypto.PublicKey import ECC
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes


from OpenSSL import crypto, SSL
import time


from flask_cors import CORS


app =  Flask(__name__)
app.config['SESSION_TYPE'] = 'filesystem'  
app.config['SESSION_COOKIE_NAME'] = 'custom_session_cookie'  # Nom du cookie de session
app.config['SESSION_COOKIE_HTTPONLY'] = True  # Marquer le cookie de session comme étant accessible uniquement via HTTP
app.config['SESSION_COOKIE_SECURE'] = True  # Marquer le cookie de session comme sécurisé (utilisation de HTTPS)
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'  # Définir la politique SameSite pour le cookie de session
Session(app)
CORS(app)

# tasks=[
#     {
#         'title': 'Faire les courses',
#         'description' : 'lait, Pain, Fruits, Viandes, Légumes',
#     },
#     {
#         'title': 'Sabbonner',
#         'description' : 'blabla',
#     }
# ]

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


# @app.route('/tasks',methods=['POST', 'GET'])
# def our_task():
#     if request.method == 'POST':
#         req_data= request.get_json()
#         title= req_data['title']
#         description = req_data['description']
#         tasks.append({'title':title,'description':description})
#         return jsonify({'tasks':tasks})
#     else:
#         return jsonify({'tasks':tasks})
    


# @app.route('/tasks/<title>',methods=['DELETE'])
# def delete(title):
#     for task in tasks:
#         if task['title']==title :
#             tasks.remove(task)
#             break
#     return {}
        



####################################################################
## Signal
# # Exemple de stockage de clés côté serveur
# signal_store = SignalProtocolStore()

# @app.route('/login', methods=['POST'])
# def login():
#     # Authentification initiale (simplifiée)
#     username = request.json.get('username')
#     password = request.json.get('password')

#     # Validez les informations d'identification et générez un token d'authentification (non sécurisé dans cet exemple)
#     auth_token = generate_auth_token(username)

#     return jsonify({'auth_token': auth_token})

# @app.route('/exchange-keys', methods=['POST'])
# def exchange_keys():
#     # Obtenez les clés publiques et privées du client
#     client_public_key = request.json.get('public_key')
#     client_private_key = request.json.get('private_key')

#     # Stockez les clés côté serveur
#     signal_store.store_identity_key_pair(client_public_key, client_private_key)

#     # Répondez avec les clés publiques du serveur
#     server_public_key = SignalKeyHelper.generate_identity_key_pair()[0]
#     return jsonify({'server_public_key': server_public_key})

# @app.route('/send-message', methods=['POST'])
# def send_message():
#     # Obtenez les données chiffrées du message depuis le client
#     encrypted_data = request.json.get('encrypted_data')

#     # Déchiffrez le message en utilisant le protocole Signal
#     decrypted_message = SignalCipher.decrypt(encrypted_data, signal_store)

#     # Traitement du message déchiffré (exemple)
#     print(f"Message reçu : {decrypted_message}")

#     return jsonify({'status': 'Message reçu avec succès'})




####################################################################

from Crypto.PublicKey import ECC
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'


# app.config['SESSION_TYPE'] = 'redis'
# app.config['SESSION_REDIS'] = Redis(host='localhost', port=6379)
# Session(app)

@app.route('/login', methods=['POST'])
def login():
    req_data = request.get_json()
    username = req_data['username']
    password = req_data['password']
    print("Début fonction login")
    
    for user in users:
        if user['Pseudo'] == username and user['Password'] == password:
            print("Utilisateur trouvé")
            session['username'] = username
            return jsonify({'message': 'Login successful'}), 200
    
    return jsonify({'message': 'Invalid credentials'}), 401


@app.route('/contacts', methods=['GET'])
def get_contacts():
    if 'username' in session:
        username = session['username']
        user_contacts = [contact['Pseudo2'] if contact['Pseudo1'] == username else contact['Pseudo1'] for contact in contacts if username in contact.values()]
        return jsonify({'contacts': user_contacts}), 200
    else:
        return jsonify({'message': 'Unauthorized access'}), 401


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




if __name__ == '__main__':
    ##logging.basicConfig(level=logging.DEBUG)
    ##certificat SSL/TLS pour activer HTTPS            ,ssl_context=('path/to/cert.pem', 'path/to/key.pem')   ,ssl_context=('cert_path/server.pem', 'key_path/server.pem')
    ## Penser à faire un certificat auto-signer    ,ssl_context=('cert_path/server.crt', 'key_path/server.key')
    app.run(host='0.0.0.0',debug=True,port=8000)