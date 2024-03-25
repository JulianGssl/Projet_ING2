from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# Initialisation de l'extension SQLAlchemy
db = SQLAlchemy()

# Définir vos modèles SQLAlchemy ici

class User(db.Model):
    idUser = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(45), nullable=True)
    email = db.Column(db.String(45), nullable=True)
    password_hash = db.Column(db.String(45), nullable=True)

class Contact(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    id_user = db.Column(db.Integer, db.ForeignKey('user.idUser'), nullable=True)
    id_contact = db.Column(db.Integer, nullable=True)
    user = db.relationship('User', foreign_keys=[id_user], backref=db.backref('contacts', lazy=True))

class Conv(db.Model):
    idConv = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(45), nullable=True)
    type = db.Column(db.String(45), nullable=True)

class ConvMember(db.Model):
    __tablename__ = 'convmember'
    idconvMember = db.Column(db.Integer, primary_key=True)
    idConv = db.Column(db.Integer, db.ForeignKey('conv.idConv'), nullable=True)
    idUser = db.Column(db.Integer, db.ForeignKey('user.idUser'), nullable=True)
    role = db.Column(db.String(45), nullable=True)
    conv = db.relationship('Conv', foreign_keys=[idConv], backref=db.backref('members', lazy=True))
    user = db.relationship('User', foreign_keys=[idUser], backref=db.backref('conv_members', lazy=True))

class Message(db.Model):
    idMessage = db.Column(db.Integer, primary_key=True)
    id_conv = db.Column(db.Integer, db.ForeignKey('conv.idConv'), nullable=True)
    id_sender = db.Column(db.Integer, db.ForeignKey('user.idUser'), nullable=True)
    content = db.Column(db.String(300), nullable=True)
    date = db.Column(db.DateTime, nullable=True,default=datetime.now)
    conv = db.relationship('Conv', foreign_keys=[id_conv], backref=db.backref('messages', lazy=True))
    sender = db.relationship('User', foreign_keys=[id_sender], backref=db.backref('sent_messages', lazy=True))

class TokenBlocklist(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    jti = db.Column(db.String(36), nullable=False, unique=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
