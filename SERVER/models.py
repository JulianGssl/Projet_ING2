from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# Initialisation de l'extension SQLAlchemy
db = SQLAlchemy()

# Définir vos modèles SQLAlchemy ici

class User(db.Model):
    idUser = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(45), nullable=True, unique=True)
    email = db.Column(db.String(45), nullable=True, unique=True)
    is_validate=db.Column(db.Boolean, default=False)
    valid_code=db.Column(db.String(6),nullable=True)
    password_hash = db.Column(db.String(255), nullable=True)
    salt = db.Column(db.String(255),nullable=True)
    public_key = db.Column(db.String(4096),nullable=True)
    private_key=db.Column(db.String(4096),nullable=True)

class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    id_user = db.Column(db.Integer, db.ForeignKey('user.idUser'), nullable=True)
    id_contact = db.Column(db.Integer, nullable=True)
    user = db.relationship('User', foreign_keys=[id_user], backref=db.backref('contacts', lazy=True))

class Conv(db.Model):
    idConv = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(45), nullable=True)
    type = db.Column(db.String(45), nullable=True)
    creation_date= db.Column(db.DateTime, nullable=True, default=datetime.now)

class ConvMember(db.Model):
    __tablename__ = 'convmember'
    idconvMember = db.Column(db.Integer, primary_key=True, autoincrement=True)
    idConv = db.Column(db.Integer, db.ForeignKey('conv.idConv'), nullable=True)
    idUser = db.Column(db.Integer, db.ForeignKey('user.idUser'), nullable=True)
    role = db.Column(db.String(45), nullable=True)
    conv = db.relationship('Conv', foreign_keys=[idConv], backref=db.backref('members', lazy=True))
    user = db.relationship('User', foreign_keys=[idUser], backref=db.backref('conv_members', lazy=True))

class Message(db.Model):
    idMessage = db.Column(db.Integer, primary_key=True, autoincrement=True)
    id_conv = db.Column(db.Integer, db.ForeignKey('conv.idConv'), nullable=True)
    id_sender = db.Column(db.Integer, db.ForeignKey('user.idUser'), nullable=True)
    content = db.Column(db.String(4000), nullable=True)
    date = db.Column(db.DateTime, nullable=True,default=datetime.now)
    is_read = db.Column(db.Boolean, nullable=True, default=False)
    conv = db.relationship('Conv', foreign_keys=[id_conv], backref=db.backref('messages', lazy=True))
    sender = db.relationship('User', foreign_keys=[id_sender], backref=db.backref('sent_messages', lazy=True))

class TokenBlocklist(db.Model):
    __tablename__ = 'tokenblocklist'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    jti = db.Column(db.String(36), nullable=False, unique=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
