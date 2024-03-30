from flask import request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required
from models import db, User, Contact, TokenBlocklist, Conv, ConvMember, Message
from Crypto.Hash import SHA256
import os
from sqlalchemy import or_, and_
import base64

from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

from flask_mail import Message

def init_routes(app, mail):
    @app.route('/login', methods=['POST'])
    def login():
        # Récupère les données JSON envoyées dans le corps de la requête POST
        req_data = request.get_json()
        # Extrait le nom d'utilisateur du JSON reçu
        username = req_data['username']
        # Extrait le mot de passe du JSON reçu
        password = req_data['password']
        
        # Recherche dans la base de données un utilisateur ayant le nom d'utilisateur et le mot de passe fournis
       user = User.query.filter_by(username=username).first()
        if user:
            if user.is_validate==True:
                stored_salt = bytes.fromhex(user.salt) #On converti la chaine de caractère en byte
                stored_password_hash = user.password_hash

                #on compare le hash du mdp rentré et le mdp hashé dans la bdd
                hashed_password=hashPassword(password,stored_salt)
                if(stored_password_hash==hashed_password):
                    
                    private_key=decrypt_private_key(user.private_key, stored_salt, password).hex()
                    # Si l'utilisateur est authentifié, créer un token JWT
                    access_token = create_access_token(identity=user.idUser,additional_claims={"private_key" : private_key})
                
                    return jsonify({'access_token': access_token}), 200
            
        return jsonify({'message': 'Invalid credentials'}), 401
    
    @app.route('/signUp', methods=['POST'])
    def signUp():
        req_data = request.get_json()
        username = req_data['username']
        password = req_data['password']
        email= req_data["email"]
        
        #Salage et hachage du mdp
        salt = os.urandom(32)
        hashed_password = hashPassword(password, salt)
        public_key,private_key=generate_keys()
        
        private_key_secure=encrypt_private_key(private_key,password,salt)
        # Conversion de la clé privée chiffrée en base64
        private_key_base64 = base64.b64encode(private_key_secure).decode('utf-8')
        
        new_user = User(username=username, email=email, password_hash=hashed_password, salt=salt.hex(), public_key=public_key, private_key=private_key_base64)
        db.session.add(new_user)
        db.session.commit()
        user_id = new_user.idUser
        send_email(email,user_id) #Envoie du mail de confirmation
        
        if new_user:
            return jsonify({'message':"Your account is awaiting validation, you have just received an email" }), 200
        return jsonify({'message': 'Invalid credentials'}), 401
    
    @app.route('/send-email/<email_user>/<id_user>',methods=['GET'])
    def send_email(email_user, id_user):
        msg = Message("Confirmation of your account",
                    sender="whisper.confirm@gmail.com",
                    recipients=[email_user])
        msg.body = "Hello!\n\nHere is an email to confirm your Whisper's account, please click on this link: http://localhost:8000/emailConfirm?idUser=" + str(id_user)
        
        mail.send(msg)
        return "Email sent successfully!"

    
    @app.route('/emailConfirm', methods=['GET'])      
    def emailConfirm():
        idUser = request.args.get('idUser')
        user=db.session.query(User).filter(User.idUser == idUser).first()
        if user:
            user.is_validate=True
            db.session.commit()
            return jsonify({'message': 'Account validated'}), 200

    def generate_keys():
        # Générer une paire de clés RSA
        privateKey = rsa.generate_private_key(
            public_exponent=65537,  # Exposant public couramment utilisé
            key_size=2048,          # Taille de la clé en bits
            backend=default_backend()
        )
        # Obtenir la clé publique à partir de la clé privée
        publicKey = privateKey.public_key()
        # Sérialiser la clé publique au format PEM
        publicKey_pem = publicKey.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        
        privateKey_pem = privateKey.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
        ).decode()
        
        return publicKey_pem, privateKey_pem
    
    def derive_key(password, salt):
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
            backend=default_backend()
        )
        return kdf.derive(password.encode())

    def encrypt_private_key(private_key, password,salt):
        key = derive_key(password, salt)
        iv = os.urandom(16)
        cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
        encryptor = cipher.encryptor()
        encrypted_private_key = encryptor.update(private_key.encode()) + encryptor.finalize()
        return encrypted_private_key
    
    def decrypt_private_key(encrypted_private_key_base64, salt, password):
        encrypted_private_key = base64.b64decode(encrypted_private_key_base64)
        # Dérivation de la clé de chiffrement à partir du mot de passe et du sel
        key = derive_key(password, salt)
        # Générer un vecteur d'initialisation (IV) aléatoire
        iv = os.urandom(16)
        # Créer un objet Cipher avec l'algorithme AES en mode CFB
        cipher = Cipher(algorithms.AES(key), modes.CFB(iv), backend=default_backend())
        # Créer un objet decryptor pour déchiffrer les données
        decryptor = cipher.decryptor()
        # Déchiffrer la clé privée
        decrypted_private_key = decryptor.update(encrypted_private_key) + decryptor.finalize()
        # Retourner la clé privée déchiffrée
        return decrypted_private_key

    def hashPassword(password, salt):
        # Ajouter le sel au mot de passe
        salted_password = password.encode() + salt

        # Hacher le mot de passe avec le sel en utilisant SHA-256
        hash_object = SHA256.new(data=salted_password)
        hashed_password = hash_object.hexdigest()
        return hashed_password

  
    @app.route('/displayUserByName', methods=['POST'])
    @jwt_required()
    def displayUserByName():
        req_data = request.get_json()
        username = req_data['username']
        id_user = get_jwt_identity()
        
        users = User.query.filter(
        and_(
            ~User.idUser.in_(db.session.query(Contact.id_contact).filter_by(id_user=id_user)),
            User.username.like(f'%{username}%'),
            User.idUser != id_user
        )).limit(100)
        
        user_data = [{'id': user.idUser, 'username': user.username} for user in users]
        return jsonify({'users': user_data}), 200

    
    @app.route('/addFriend', methods=['POST'])
    @jwt_required()
    def addFriend():
        req_data = request.get_json()
        username = req_data['username']
        id_contact= req_data['id_contact']
        id_user = get_jwt_identity()
        
        new_contact = Contact(id_user=id_user, id_contact=id_contact)
        db.session.add(new_contact)
        db.session.commit()
        
        if new_contact:
            access_token = create_access_token(identity=id_user)
            return jsonify({'message': 'Contact added successfully', 'access_token': access_token}), 200
        else:
            return jsonify({'message': 'Error adding contact'}), 500

    # Route protégée nécessitant un token JWT valide
    @app.route('/protected', methods=['GET'])
    @jwt_required()
    def protected_route():
        current_user = get_jwt_identity()
        return jsonify({'message': 'Login successful', 'user': current_user}), 200

    @app.route('/contacts', methods=['GET'])
    @jwt_required()
    def get_contacts():
        id_user = get_jwt_identity()
        user_contacts = (
            db.session.query(User.idUser, User.username)
            .join(Contact, User.idUser == Contact.id_contact)
            .filter(Contact.id_user == id_user)
            .all()
        )
        contacts_list = [{'id': contact[0], 'username': contact[1]} for contact in user_contacts]
        return jsonify({'contacts': contacts_list}), 200

    # Endpoint pour révoquer le token JWT actuel
    @app.route("/logout", methods=["POST"])
    @jwt_required()
    def logout():
        jti = get_jwt()["jti"]
        token = TokenBlocklist(jti=jti)
        DBAPISet.session.add(token)
        db.session.commit()
        return jsonify(message="Token revoked"), 200

    @app.route("/recent_messages", methods=["GET"])
    @jwt_required()
    def recent_messages():
        id_user = get_jwt_identity()

        # Sous-requête pour trouver le dernier message de chaque conversation
        subq = db.session.query(
            Message.id_conv,
            db.func.max(Message.idMessage).label('max_id')
        ).join(ConvMember, Message.id_conv == ConvMember.idConv)\
        .filter(ConvMember.idUser == id_user)\
        .group_by(Message.id_conv).subquery('latest_message')

        # Requête principale pour obtenir les détails du dernier message de chaque conversation
        last_messages = db.session.query(Message, Conv.name, Conv.type)\
            .join(subq, Message.idMessage == subq.c.max_id)\
            .join(Conv, Conv.idConv == Message.id_conv)\
            .all()

        # Formatage des résultats pour la réponse JSON
        results = [
            {
                'conv_id': message[0].id_conv,
                'conv_name': message[1],
                'conv_type': message[2],
                'last_message_id': message[0].idMessage,
                'last_message_content': message[0].content,
                'last_message_date': message[0].date.isoformat(),
                'last_message_sender_id': message[0].id_sender
            } for message in last_messages
        ]

        print(results)

        return jsonify({'recent_messages': results}), 200
        
    @app.route("/messages", methods=["POST"])
    @jwt_required()
    def messages():
        print("TEST TEST TEST")
        id_user = get_jwt_identity()
        req_data = request.get_json()
        id_conv = req_data['id_conv']
        print(id_conv)

        if not id_conv:
            return jsonify({"error : Conversation ID is required"}), 400
        
        messages = db.session.query(Message.idMessage, Message.content, Message.date, Message.id_sender, User.username, User.email, Conv.idConv, Conv.name, Conv.type)\
            .join(User, Message.id_sender == User.idUser)\
            .join(Conv, Message.id_conv == Conv.idConv)\
            .filter(Message.id_conv == id_conv)\
            .order_by(Message.date.asc())\
            .all()

        # Format the messages for JSON response
        messages_list = [{
            'idMessage': message.idMessage,
            'content': message.content,
            'date': message.date.isoformat(),
            'id_sender': message.id_sender,
            'username': message.username,
            'email': message.email,
            'idConv': message.idConv,
            'convName': message.name,
            'convType': message.type,
            'current_user': True if message.id_sender == id_user else False,  
        } for message in messages]

        print(messages_list)

        return jsonify({"messages" : messages_list}), 200
    
    @app.route("/get_profile", methods=["GET"])
    @jwt_required()
    def get_profile():
        id_user = get_jwt_identity()
        user = User.query.filter_by(idUser=id_user).first()

        if user:
            user_data = {
                "username": user.username,
                "email": user.email,
            }
            return jsonify({"user_data": user_data}), 200

        return jsonify({"message": "User not found"}), 404



    @app.route("/edit_profile", methods=["POST"])
    @jwt_required()
    def edit_profile():
        id_user = jwt_required()
        id_user = get_jwt_identity()
        req_data = request.get_json()
        print(req_data)
        username = req_data['username']
        email = req_data['email']
        password = req_data['password']
        current_password = req_data['currentPassword']

        user = User.query.filter_by(idUser=id_user).first()


        stored_salt = bytes.fromhex(user.salt) #On converti la chaine de caractère en byte
        stored_password_hash = user.password_hash
        #on compare le hash du mdp rentré et le mdp hashé dans la bdd
        hashed_password=hashPassword(current_password,stored_salt)

        if(stored_password_hash==hashed_password):
            user.username = username
            user.email = email
            user.password_hash = hashPassword(password, stored_salt)

            db.session.commit()

            return jsonify({"message": "User update successfully"}), 200


        return jsonify({"message": "User not found"}), 404



# Callback pour vérifier si le token est révoqué
"""
@jwt.token_in_blocklist_loader
def check_if_token_revoked(jwt_header, jwt_payload):
    jti = jwt_payload["jti"]
    token = TokenBlocklist.query.filter_by(jti=jti).first()
    return token is not None

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
"""
