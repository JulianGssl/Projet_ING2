from flask import request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required    
from models import db, User, Contact, TokenBlocklist, Message, Conv, ConvMember

def init_routes(app):
    @app.route('/login', methods=['POST'])
    def login():
        req_data = request.get_json()
        username = req_data['username']
        password = req_data['password']
        
        user = User.query.filter_by(username=username, password_hash=password).first()
        if user:
            # Si l'utilisateur est authentifié, créer un token JWT
            access_token = create_access_token(identity=user.idUser)
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
        id_user = get_jwt_identity()
        

        # Alias for convmember and user tables
        cm1_alias = aliased(ConvMember)
        cm2_alias = aliased(ConvMember)
        user_alias = aliased(User)

        contacts_query = db.session.query(
            cm1_alias.idConv,
            cm2_alias.idUser.label('other_user_id'),
            user_alias.username.label('other_user_name')
        ).join(
            cm2_alias, cm1_alias.idConv == cm2_alias.idConv
        ).filter(
            cm1_alias.idUser != cm2_alias.idUser
        ).join(
            Conv, cm1_alias.idConv == Conv.idConv
        ).filter(
            Conv.type == 'prive'
        ).join(
            user_alias, cm2_alias.idUser == user_alias.idUser
        ).filter(
            cm1_alias.idUser == id_user
        ).distinct()

        contacts = contacts_query.all()
        result = [
            {'conversation_id': contact.idConv, 'other_user_id': contact.other_user_id, 'other_user_name': contact.other_user_name}
            for contact in contacts
        ]

        return jsonify({"contacts": result}), 200

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
