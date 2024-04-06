# Application de Messagerie Sécurisée avec Cryptographie Avancée: Whisper

<br><br>

<p align="center">
  <img src="whisper_logo.jpg"/>
</p>

<br><br>

Whisper est une application de messagerie sécurisée conçue avec une approche axée sur la confidentialité et la sécurité des communications. En combinant des techniques de cryptographie avancée avec une interface conviviale, Whisper garantit que chaque message échangé reste confidentiel, intègre et authentique.

En plongeant dans les principes fondamentaux de la cryptographie, notre équipe a développé Whisper pour offrir bien plus qu'une simple messagerie. C'est une solution innovante qui protège efficacement la vie privée des utilisateurs tout en assurant la sécurité de leurs échanges. Avec Whisper, vous pouvez communiquer en toute confiance, sachant que vos conversations sont protégées contre les regards indésirables et les interceptions.

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

