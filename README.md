# Application de Messagerie Sécurisée : App_Name
Refactorisation du code de 'main.dart' de la branche main dans plusieurs fichiers pour une meilleure organisation et lisibilité.

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


<br><br>

<ins> Problème </ins> 

Erreur lors de l'emit côté serveur et socket.on côté client : flask & socket io problème ?

Client: emit - Serveur: socket.on [OK]

Serveur: emit - Client: socket.on [X]
