import secrets
from flask_session import Session
from datetime import timedelta

class Config:
    SECRET_KEY = secrets.token_hex(32)
    JWT_SECRET_KEY = secrets.token_hex(32)
    SQLALCHEMY_DATABASE_URI = 'mysql://root:Cytech0001$@localhost/chatApp' # Modifier le mdp et le nom de la bdd accordement
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    DEBUG = True
    SESSION_COOKIE_NAME = 'custom_session_cookie'
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_SAMESITE = 'None'
    PERMANENT_SESSION_LIFETIME = timedelta(minutes=30)
    MAIL_SERVER = 'smtp.gmail.com'
    MAIL_PORT = 587
    MAIL_USE_TLS = True
    MAIL_USERNAME = 'whisper.confirm@gmail.com'
    MAIL_PASSWORD = 'iuho gdls inkg omeg'
