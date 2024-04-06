# Application de Messagerie Sécurisée avec Cryptographie Avancée: Cipher

<br><br>

<ins> Problème </ins> 
$${\color{red}Flask \ development \ web \ server \ does \ not \ have\ native\ support\ for\ websocket.\ Switching\ to\ a\ production\ server\ this\ problem\ will\ not\ occur.}$$
https://github.com/miguelgrinberg/flask-sock/issues/27


<ins>Solution </ins>

Pour lancer le backend avec le protocole socketio il faut :
- Installer 'eventlet' : ```pip install -U eventlet```
- Lancer le backend avec socketio.run :
```
if __name__ == '__main__':
    socketio.run(app, port=8000)
```

