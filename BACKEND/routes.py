from flask import request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required
from models import db, User, Contact, TokenBlocklist

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
        user_contacts = (
            db.session.query(User.username)
            .join(Contact, User.idUser == Contact.id_contact)
            .filter(Contact.id_user == id_user)
            .all()
        )
        contacts_list = [contact[0] for contact in user_contacts]
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