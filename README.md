# Application de Messagerie Sécurisée avec Cryptographie Avancée: Whisper

<br><br>

<p align="center">
  <img src="whisper_logo.jpg"/>
</p>

<br><br>

Whisper est une application de messagerie sécurisée conçue avec une approche axée sur la confidentialité et la sécurité des communications. En combinant des techniques de cryptographie avancée avec une interface conviviale, Whisper garantit que chaque message échangé reste confidentiel, intègre et authentique.

En plongeant dans les principes fondamentaux de la cryptographie, notre équipe a développé Whisper pour offrir bien plus qu'une simple messagerie. C'est une solution innovante qui protège efficacement la vie privée des utilisateurs tout en assurant la sécurité de leurs échanges. Avec Whisper, vous pouvez communiquer en toute confiance, sachant que vos conversations sont protégées contre les regards indésirables et les interceptions.

## Installation:

Pour configurer votre environnement de travail vous pouvez suivre ce tutoriel : 
https://docs.flutter.dev/get-started/install
Sinon voici un détail des étapes:
- Installer de Visual Studio Code (VSCode)
- Installer l’extension Flutter sur VSCode
- Télécharger le SDK de Flutter (se référer à la procédure d’installation disponible sur leur site, voir lien ci-dessus)
- Pour créer un projet Flutter sur VSCode : CTRL + Shift + P 
- Taper ‘Flutter’ puis sélectionner les choix suivants : Flutter: New Project > Application
- Sélectionner un dossier pour créer votre projet

Configuration du projet:
- Extraire le dossier CLIENT 
- Copier le dossier lib de CLIENT dans le répertoire de votre projet nouvellement créé
- Copier le fichier pubspec.yaml de CLIENT dans le répertoire de votre projet 
- Pour installer les dépendances nécessaires : 
- Aller sur le fichier pubspec.yaml copié et faire CTRL + S
- Ouvrir un terminal sur VSCode et taper : flutter pub get
- Vous pouvez désormais vous rendre sur le fichier main.dart et lancer l’application avec Run au dessus de la ligne void main()
- Il vous demanderont de choisir un “device” , choisissez Google Chrome ou votre navigateur habituel

- Dans une nouvelle instance de VSCode, faites File > Open Folder et choisissez le dossier SERVEUR
- Une fois dans le dossier SERVEUR faites CTRL+SHIFT+P et rentrer : “Python:Create an Environment”
- Ensuite sélectionnez “Venv” puis votre version de Python, et finalement sélectionnez le fichier “requirements.txt” qui vous est proposé. ( Si jamais on ne vous le propose pas ouvrez un terminal dans dans
SERVEUR et tapez : pip install -r requirements.txt ). Ceci va installer toutes les dépendances pour le serveur
Configuration initiale du serveur et des services associés (bases de données, serveurs de messagerie, etc.)

- Récupérer le fichier bdd.sql présent dans le dossier BDD du projet, et exécuter dans un terminal la commande :
 mysql -u utilisateur -p mot_de_passe < chemin/bdd.sql
Si vous préférez vous pouvez exécuter le code dans MySQL Workbench
- Finalement rendez vous dans le fichier config.py de SERVEUR
et insérer votre nom d’utilisateur mysql à la place de “root” et votre le mot de passe à la place de “cytech0001” : 
SQLALCHEMY_DATABASE_URI = 'mysql://root:cytech0001@localhost/app_db'
Vous pouvez désormais vous rendre le fichier run.py et lancer le serveur avec la commande : python run.py

Lancement du projet:
Une fois la partie serveur et client lancées, dans le navigateur où se trouve l’application ouvrez un nouvel onglet et entrez: https://localhost:8000 . Cliquez sur “Paramètres avancés” puis sur “Continuer vers le site localhost” tout en bas. Cela permet de faire confiance à l’application car nous n’avons pas de certificat pour https.
C'est bon, vous pouvez maintenant utiliser l'application.


