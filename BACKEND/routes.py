from flask import request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required
from models import db, User, Contact, TokenBlocklist, Conv, ConvMember, Message
from Crypto.Hash import SHA256
import os
from sqlalchemy import or_, and_

def init_routes(app):
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
            stored_salt = bytes.fromhex(user.salt) #On converti la chaine de caractère en byte
            stored_password_hash = user.password_hash
            #on compare le hash du mdp rentré et le mdp hashé dans la bdd
            hashed_password=hashPassword(password,stored_salt)
            if(stored_password_hash==hashed_password):
                # Crée un token d'accès JWT (JSON Web Token) pour cet utilisateur. L'identité du token est définie sur l'ID de l'utilisateur dans la base de données
                access_token = create_access_token(identity=user.idUser)
                # Renvoie le token d'accès JWT dans une réponse JSON avec le code d'état HTTP 200 (OK)
                return jsonify({'access_token': access_token, 'idUser':user.idUser}), 200
        
        # Si l'utilisateur n'est pas trouvé dans la base de données ou si les informations d'identification sont incorrectes, renvoie un message d'erreur JSON avec le code d'état HTTP 401 (Unauthorized)
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
        
        new_user = User(username=username, email=email, password_hash=hashed_password, salt=salt.hex())
        db.session.add(new_user)
        db.session.commit()
        user_id = new_user.idUser
        if new_user:
            access_token = create_access_token(identity=user_id)
            return jsonify({'access_token': access_token}), 200
        return jsonify({'message': 'Invalid credentials'}), 401


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
