## Crypto.dart
Ce fichier contient les fonctions nécessaires pour chiffrer et déchiffrer des messages, générer des clés de chiffrement, calculer des clés secrètes partagées, et effectuer des opérations de chiffrement et de déchiffrement avec AES en mode GCM. Voici un bref aperçu des fonctions présentes dans ce fichier :

- `encryptPrivateKey`: Cette fonction chiffre une clé privée à l'aide d'un mot de passe, d'un sel et d'un vecteur d'initialisation (IV) en utilisant l'algorithme AES avec le mode de chiffrement CFB64.
- `decryptPrivateKey`: Cette fonction déchiffre une clé privée chiffrée avec un mot de passe, un sel et un IV en utilisant l'algorithme AES avec le mode de chiffrement CFB64.
- `deriveEncodingKey`: Cette fonction dérive une clé de chiffrement à partir d'un mot de passe et d'un sel en utilisant l'algorithme PBKDF2 avec HMAC-SHA256.
- `keyPairFromBase64`: Cette fonction génère un objet 'KeyPair' à partir de clés encodées en base64.
- `simplePublicKeyFromBase64`: Cette fonction crée un objet 'SimpleKeyPair' à partir d'une clé encodée en base64.
- `secretKeyFromBase64`: Cette fonction crée un objet 'SecretKey' à partir d'une clé encodée en base64.
- `calculateSharedSecret`: Cette fonction calcule la clé secrète partagée entre une paire de clés locales et une clé publique distante en utilisant l'algorithme de Diffie-Hellman X25519.
- `encryptMessage`: Cette fonction chiffre un message avec une clé secrète donnée en utilisant l'algorithme AES avec le mode de chiffrement GCM.
- `decryptMessage`: Cette fonction déchiffre un message chiffré avec une clé secrète donnée en utilisant l'algorithme AES avec le mode de chiffrement GCM.

## key_generation.dart
Ce fichier contient une fonction permettant de générer une paire de clés X25519 et d'encoder les clés en base64. Voici un aperçu de la fonction présente dans ce fichier :

- `generateKeys`: Cette fonction génère une paire de clés X25519, encode les clés en base64. Elle retourne un objet Map contenant les clés privée et publique.

## salt_iv.dart
Ce fichier contient deux constantes, `salt` et `iv`, qui représentent respectivement le sel et le vecteur d'initialisation (IV) utilisés pour le chiffrement.


NB : Peut-être merge le fichier crypto et key_generation
