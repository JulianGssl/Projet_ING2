from datetime import datetime
from flask import request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required, get_jwt
from models import db, User, Contact, TokenBlocklist, Message, Conv, ConvMember
from Crypto.Hash import SHA256
import os
import flask_mail
from pymysql import DBAPISet
import base64
from sqlalchemy.orm import aliased  
from sqlalchemy import and_, distinct

from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes

import logging
from logging.handlers import RotatingFileHandler
# from flask_wtf.csrf import CSRFProtect
import itsdangerous
import random

def init_routes(app, mail,csrf,limiter):

    ## Configuration de la journalisation
    app.logger.setLevel(logging.DEBUG)
    current_directory = os.path.dirname(os.path.abspath(__file__))
    log_file_path = os.path.join(current_directory, 'app.log')

    handler = RotatingFileHandler(log_file_path, maxBytes=10000, backupCount=1)
    handler.setLevel(logging.INFO)
    app.logger.addHandler(handler)
    


        
    @app.route('/login', methods=['POST']) # TODO CHANGER LA RECUPERATION DU SEL DANS LA BDD PAR LA RECUPERATION DU SEL DEPUIS LE FRONT
    @csrf.exempt
    @limiter.limit("3/minute")
    def login():
        # Récupère les données JSON envoyées dans le corps de la requête POST
        req_data = request.get_json()
        # Extrait le nom d'utilisateur du JSON reçu
        username = req_data['username']
        # Extrait le mot de passe du JSON reçu
        password = req_data['password']

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        
        # Recherche dans la base de données un utilisateur ayant le nom d'utilisateur et le mot de passe fournis #TODO REGROUPER LA COMPARAISON DE L'USERNAME ET DU MDP 
        user = User.query.filter_by(username=username).first()
        if user:
            if user.is_validate==True:
                stored_salt = user.salt #On converti la chaine de caractère en byte
                stored_password_hash = user.password_hash

                #on compare le hash du mdp rentré et le mdp hashé dans la bdd
                hashed_password=hashPassword(password,stored_salt)
                if(stored_password_hash==hashed_password):

                    # Si l'utilisateur est authentifié, créer un token JWT
                    access_token = create_access_token(identity=user.idUser,additional_claims={"idUser" : user.idUser, "public_key": user.public_key, "private_key_encrypted" : user.private_key, "salt": user.salt})
                    app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")

                    return jsonify({'access_token': access_token}), 200
            else:
                return jsonify({'idUser': user.idUser}), 200

        app.logger.warning(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -401")
        return jsonify({'message': 'Invalid credentials'}), 401

    @app.route('/displayUserByName', methods=['POST'])
    @jwt_required()
    @csrf.exempt
    def displayUserByName():
        req_data = request.get_json()
        username = req_data['username']
        id_user = get_jwt_identity()

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        # Vérifiez le jeton CSRF inclus dans la demande
        if 'X-CSRF-TOKEN' not in request.headers or not is_valid_csrf_token(request.headers['X-CSRF-TOKEN'],2):
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -403")
            return jsonify({'error': 'Invalid CSRF token'}), 403
        
        users = User.query.filter(
        and_(
            ~User.idUser.in_(db.session.query(Contact.id_contact).filter_by(id_user=id_user)),
            User.username.like(f'%{username}%'),
            User.idUser != id_user
            )
        ).limit(100)
        
        user_data = [{'id': user.idUser, 'username': user.username} for user in users]
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify({'users': user_data}), 200

    
    @app.route('/addFriend', methods=['POST'])
    @jwt_required()
    @csrf.exempt
    def addFriend():
        req_data = request.get_json()
        contact_username = req_data['username']
        id_contact= req_data['id_contact']
        
        id_user = get_jwt_identity()
        user = User.query.filter_by(idUser=id_user).first()
        username=user.username
        
        new_contact = Contact(id_user=id_user, id_contact=id_contact)
        new_contact2= Contact(id_user=id_contact,id_contact=id_user)
        conv_name="_".join(sorted([username+"#"+str(id_user),contact_username+"#"+str(id_contact)]))
        new_conv= Conv(name=conv_name,type="private")
        db.session.add(new_conv)
        db.session.add(new_contact)
        db.session.add(new_contact2)
        db.session.commit()
        
        new_conv_id=new_conv.idConv
        new_conv_member1=ConvMember(idConv=new_conv_id,idUser=id_user)
        new_conv_member2=ConvMember(idConv=new_conv_id,idUser=id_contact)
        db.session.add(new_conv_member1)
        db.session.add(new_conv_member2)
        db.session.commit()
        
        
        if new_contact:
            access_token = create_access_token(identity=id_user)
            return jsonify({'message': 'Contact added successfully', 'access_token': access_token}), 200
        else:
            return jsonify({'message': 'Error adding contact'}), 500

    @app.route('/signUp', methods=['POST'])
    @csrf.exempt
    def signUp():
        req_data = request.get_json()
        username = req_data['username']
        password = req_data['password']
        email= req_data["email"]

        private_key=req_data["privateKeyBase64"]
        public_key=req_data["publicKeyBase64"]
        salt=req_data["salt"]

         # Vérification si l'email existe déjà
        existing_email_user = User.query.filter_by(email=email).first()
        if existing_email_user:
            return jsonify({'message': 'Email already exists'}), 409  # Utiliser le code 409 pour indiquer un conflit
        
        # Vérification si le nom d'utilisateur existe déjà
        existing_username_user = User.query.filter_by(username=username).first()
        if existing_username_user:
            return jsonify({'message': 'Username already exists'}), 409  # Utiliser le code 409 pour indiquer un conflit
        
        #Génération code de validation de compte:
        random_number = random.randint(0, 999999)
        valid_code = f"{random_number:06}"

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        
        #Salage et hachage du mdp
        hashed_password = hashPassword(password, salt)
        
        new_user = User(username=username, email=email, valid_code=valid_code, password_hash=hashed_password, salt=salt, public_key=public_key, private_key=private_key)
        
        db.session.add(new_user)
        db.session.commit()
        user_id = new_user.idUser
        send_email(email, valid_code)
        
        if new_user:
            return jsonify({'idUser': user_id}), 200
            
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -401")
        return jsonify({'message': 'Invalid credentials'}), 401

    def hashPassword(password, salt):
        # Ajouter le sel au mot de passe
        salted_password = password.encode() + salt.encode()

        # Hacher le mot de passe avec le sel en utilisant SHA-256
        hash_object = SHA256.new(data=salted_password)
        hashed_password = hash_object.hexdigest()
        return hashed_password
    
    # Route protégée nécessitant un token JWT valide
    @app.route('/protected', methods=['GET'])
    @csrf.exempt
    @jwt_required()
    def protected_route():
        current_user = get_jwt_identity()
        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify({'message': 'Login successful', 'user': current_user}), 200

    @app.route('/contacts', methods=['GET'])
    @csrf.exempt
    @jwt_required()
    def get_contacts():
        id_user = get_jwt_identity()

        # Alias pour les tables
        cm_alias = aliased(ConvMember)
        user_alias = aliased(User)
        conv_alias = aliased(Conv)
        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        # Sous-requête pour sélectionner distinctement les valeurs de idConv
        subquery = db.session.query(distinct(cm_alias.idConv)).filter(cm_alias.idUser == id_user).subquery()

        # Requête pour récupérer les contacts de l'utilisateur
        contacts_query = db.session.query(
            cm_alias.idUser.label('other_user_id'),
            user_alias.username.label('other_user_name'),
            conv_alias.idConv.label('conversation_id'),
            conv_alias.name.label('conversation_name')
        ).join(
            user_alias, cm_alias.idUser == user_alias.idUser
        ).join(
            conv_alias, conv_alias.idConv == cm_alias.idConv
        ).filter(
            cm_alias.idUser != id_user,
            cm_alias.idConv.in_(subquery),
            conv_alias.type == 'private'
        ).distinct()

        # Récupération des résultats de la requête
        contacts = contacts_query.all()

        # Création du résultat à renvoyer
        result = [
            {
                'other_user_id': contact.other_user_id,
                'other_user_name': contact.other_user_name,
                'conversation_id': contact.conversation_id,
                'conversation_name': contact.conversation_name
            }
            for contact in contacts
        ]

        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify({"contacts": result}), 200
        
    # Endpoint pour révoquer le token JWT actuel
    @app.route("/logout", methods=["POST"])
    @csrf.exempt
    @jwt_required()
    def logout():
        jti = get_jwt()["jti"]
        token = TokenBlocklist(jti=jti)
        DBAPISet.session.add(token)
        db.session.commit()

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify(message="Token revoked"), 200
    
    @app.route("/recent_messages", methods=["GET"])
    @csrf.exempt
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
    
    @app.route("/get_profile", methods=["GET"])
    @csrf.exempt
    @jwt_required()
    def get_profile():
        id_user = get_jwt_identity()
        user = User.query.filter_by(idUser=id_user).first()

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        if user:
            user_data = {
                "username": user.username,
                "email": user.email,
            }
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
            return jsonify({"user_data": user_data}), 200
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -404")
        return jsonify({"message": "User not found"}), 404
    
    @app.route("/edit_profile", methods=["POST"])
    @csrf.exempt
    @jwt_required()
    def edit_profile():
    

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        # Vérifiez le jeton CSRF inclus dans la demande
        if 'X-CSRF-TOKEN' not in request.headers or not is_valid_csrf_token(request.headers['X-CSRF-TOKEN'],1):
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -403")
            return jsonify({'error': 'Invalid CSRF token'}), 403
        
        id_user = get_jwt_identity()
        print(id_user)
        req_data = request.get_json()
        print(req_data)
        username = req_data['username']
        email = req_data['email']
        password = req_data['password']
        current_password = req_data['currentPassword']                
        password = req_data['password'] if req_data['password'] != '' else current_password


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
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
            return jsonify({"message": "User update successfully"}), 200

        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -404")
        return jsonify({"message": "User not found"}), 404

    @app.route('/private_message', methods=['POST'])
    @csrf.exempt
    @jwt_required()
    def send_message():

        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        # Vérifiez le jeton CSRF inclus dans la demande
        if 'X-CSRF-TOKEN' not in request.headers or not is_valid_csrf_token(request.headers['X-CSRF-TOKEN'],3):
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -403")
            return jsonify({'error': 'Invalid CSRF token'}), 403
        
        print("Trying to send message in database..")
        # Récupérer les données JSON envoyées dans le corps de la requête POST
        message_data = request.get_json()

        # Extraire les données du message
        id_conv = message_data.get('id_conv')
        id_sender = message_data.get('id_sender')
        content = message_data.get('content')
        date = message_data.get('date')
        is_read = message_data.get('is_read')

        

        # Vérifier si toutes les données nécessaires sont présentes
        if id_conv is None or id_sender is None or content is None or date is None or is_read is None:
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -400")
            return jsonify({'error': 'Missing data'}), 400

        # Créer un nouvel objet Message
        new_message = Message(id_conv=id_conv, id_sender=id_sender, content=content, date=date, is_read=is_read)

        # Ajouter le message à la base de données
        db.session.add(new_message)
        db.session.commit()
        
        print("Message sent successfully in database")

        # Renvoyer une réponse JSON indiquant que le message a été envoyé avec succès
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify({'message': 'Message sent successfully'}), 200
    
    @app.route('/conversation_id', methods=['POST'])
    @csrf.exempt
    def get_conversation_id():
        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        # Vérifiez le jeton CSRF inclus dans la demande
        if 'X-CSRF-TOKEN' not in request.headers or not is_valid_csrf_token(request.headers['X-CSRF-TOKEN'],4):
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -403")
            return jsonify({'error': 'Invalid CSRF token'}), 403
        print("Trying to get conversation id..")
        req_data = request.get_json()
        user1 = req_data['user1']
        user2 = req_data['user2']

        print("Users: {} and {}".format(user1, user2))

        try:
            # Concaténer et trier les noms d'utilisateurs pour obtenir le nom de la conversation
            conversation_name = '_'.join(sorted([user1, user2]))
            print("Conversation name: "+conversation_name)

            # Rechercher la conversation dans la base de données en fonction de son nom
            conversation = Conv.query.filter_by(name=conversation_name).first()
            if conversation:
                # Si la conversation est trouvée, renvoyer son ID
                print("Conversation found: "+str(conversation.idConv))
                return jsonify({'conversationId': conversation.idConv}), 200
            else:
                # Si la conversation n'est pas trouvée, renvoyer une erreur 404 (non trouvé)
                print("Conversation not found for: "+str(conversation_name))
                return jsonify({'message': 'Conversation not found'}), 404
        except Exception as e:
            # En cas d'erreur, renvoyer une erreur 500 (erreur interne du serveur) avec le message d'erreur
            print("Error: "+str(e))
            return jsonify({'error': str(e)}), 500

    @app.route('/getmessages', methods=['POST'])
    @csrf.exempt
    def get_conversation_messages():
        print("/getmessages - Trying to get conversation messages..")
        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        try:
            req_data = request.get_json()
            conversation_id = req_data['conversation_id']
            id_sender= req_data["id_sender"]
            print("Conversation ID:", conversation_id)

            # Recherche des messages de la conversation dans la base de données
            conversation_messages = Message.query.filter_by(id_conv=conversation_id).all()
            
            if conversation_messages:
                print("Messages found for conversation ID:", conversation_id)
                #Mettre is_read à 1 pr chaque message
                for message in conversation_messages:
                    if(message.id_sender!=id_sender):
                        message.is_read = True
                        db.session.commit()
                
                # Préparation des données de réponse au format JSON
                response_data = [{'id_conv': message.id_conv,
                                'id_sender': message.id_sender,
                                'content': message.content,
                                'date': message.date.isoformat(),
                                'is_read': message.is_read} for message in conversation_messages]
                app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
                return jsonify(response_data), 200
            else:
                print("No messages found for conversation ID:", conversation_id)
                app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -404")
                return jsonify({'message': 'No messages found for conversation ID'}), 404
        except Exception as e:
            print("Error:", e)
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -500")
            return jsonify({'error': str(e)}), 500

    @app.route("/conversation_users", methods=["GET"])
    @csrf.exempt
    @jwt_required()
    def get_conversation_users():
        conv_id = request.args.get('convId')
        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url

        # Requête pour récupérer les utilisateurs présents dans la conversation avec l'identifiant conv_id
        users_query = (db.session.query(User)
            .join(ConvMember, ConvMember.idUser == User.idUser)
            .filter(ConvMember.idConv == conv_id)
            .all())
        # Sérialisation des utilisateurs en format JSON
        users_json = [user.serialize() for user in users_query]
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify(users_json), 200
    
    @app.route('/fetchuser/<string:user_id>', methods=['GET'])
    @csrf.exempt
    @jwt_required()
    def fetch_user(user_id):
        try:
            print("Fetching user with ID:", user_id)
            # Recherche de l'utilisateur dans la base de données en fonction de son identifiant
            user = User.query.filter_by(idUser=user_id).first()

            ## Informations pour les log
            client_ip = request.remote_addr
            http_method = request.method
            requested_url = request.url

            if user:
                # Si l'utilisateur est trouvé, retournez ses informations au format JSON
                user_data = {
                    "idUser": user.idUser,
                    "username": user.username,
                }
                app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
                return jsonify(user_data), 200
            else:
                # Si l'utilisateur n'est pas trouvé, renvoyez une erreur 404 (non trouvé)
                app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -404")
                return jsonify({"message": "User not found"}), 404
        except Exception as e:
            # En cas d'erreur, renvoyer une erreur 500 (erreur interne du serveur) avec le message d'erreur
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -500")
            return jsonify({"error": str(e)}), 500

    @app.route('/send-email/<email_user>',methods=['GET'])
    @csrf.exempt
    def send_email(email_user, code):
        msg = flask_mail.Message("Confirmation of your account",
                    sender="whisper.confirm@gmail.com",
                    recipients=[email_user])
        msg.html = f"<p>Hello!</p><p>Here is an email to confirm your Whisper's account, please enter this code : <strong>{code}</strong> to validate your account !</p>"
        mail.send(msg)
        return "Email sent successfully!"


    @app.route('/emailConfirm', methods=['POST'])  
    @csrf.exempt    
    def emailConfirm():
        req_data = request.get_json()
        idUser = req_data['idUser']
        input_code=req_data['code']
        
        user=db.session.query(User).filter(User.idUser == idUser).first()
        ## Informations pour les log
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        if user:
            if(user.valid_code==input_code):
                user.is_validate=True
                db.session.commit()
                return jsonify({'message': 'Account validated'}), 200
            app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        
   
    # @app.route('/get_CSRF', methods=['GET'])
    # @csrf.exempt
    # @jwt_required()
    # def get_csrf_token():
    #     # Générez et renvoyez le jeton CSRF ici
    #     csrf_token = generate_csrf_token()  
    #     ## Informations pour les log
    #     client_ip = request.remote_addr
    #     http_method = request.method
    #     requested_url = request.url
    #     print(f"Token Csrf obtenu : {csrf_token}")
    #     app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
    #     return jsonify({'csrf_token': csrf_token}), 200
        

    
    ##@app.route('/get_CSRF/private_message/<int:form_id>', methods=['GET'])
    ## @app.route('/get_CSRF/conversation_id/<int:form_id>', methods=['GET'])

    @app.route('/get_CSRF/edit_profile/<int:form_id>', methods=['GET'])
    # @app.route('/get_CSRF/displayUserByName/<int:form_id>', methods=['GET'])
    # @app.route('/get_CSRF/private_message/<int:form_id>', methods=['GET'])
    # @csrf.exempt
    # @jwt_required()
    # def get_csrf_token(form_id):
    #     # Générez et renvoyez le jeton CSRF ici en utilisant form_id si nécessaire
    #     csrf_token = generate_csrf_token(form_id)
        
    #     ## Informations pour les log
    #     client_ip = request.remote_addr
    #     http_method = request.method
    #     requested_url = request.url
    #     print(f"Token Csrf obtenu : {csrf_token}")
    #     app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
    #     return jsonify({'csrf_token': csrf_token}), 200
    @app.route('/get_CSRF/displayUserByName/<int:form_id>', methods=['GET'])
    @app.route('/get_CSRF/private_message/<int:form_id>', methods=['GET'])
    @csrf.exempt
    @jwt_required()
    def get_csrf_token(form_id):
        # Générez et renvoyez le jeton CSRF ici en utilisant form_id si nécessaire
        csrf_token = generate_csrf_token(form_id)
        
        ## Informations pour les logs
        client_ip = request.remote_addr
        http_method = request.method
        requested_url = request.url
        print(f"Token Csrf obtenu : {csrf_token}")
        app.logger.info(f"{client_ip} - - [{datetime.now().strftime('%d/%b/%Y %H:%M:%S')}] \"{http_method} {requested_url} HTTP/1.1\"  -200")
        return jsonify({'csrf_token': csrf_token}), 200

            
######################################################################################################



    ## Fonctions pour CSRF


    # Créez un sérialiseur avec une clé secrète
    csrf_serializer = itsdangerous.URLSafeTimedSerializer(app.config['SECRET_KEY'])

    # Générer un jeton CSRF pour un formulaire spécifique
    def generate_csrf_token(form_id):
        return csrf_serializer.dumps({'csrf': True, 'form_id': form_id})

    # Vérifier le jeton CSRF en tenant compte de l'identifiant du formulaire
    def is_valid_csrf_token(csrf_token, form_id):
        try:
            data = csrf_serializer.loads(csrf_token, max_age=600)  
            return data.get('csrf') == True and data.get('form_id') == form_id
        except itsdangerous.BadData:
            return False


######################################################################################################

        






