import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';
import 'key_generation.dart' as KG;

final aesGcm = AesGcm.with256bits();


/// Chiffre la clé privée avec un mot de passe donné, un sel et un vecteur d'initialisation (IV) 
/// en utilisant l'algorithme AES avec le mode de chiffrement CFB64.
///
/// [privateKey] : La clé privée à chiffrer.
/// [password] : Le mot de passe utilisé pour dériver la clé de chiffrement.
/// [salt] : Le sel utilisé pour dériver la clé de chiffrement.
/// [iv] : Le vecteur d'initialisation utilisé pour le chiffrement AES.
///
/// Retourne une Future résolvant une chaîne encodée en base64 contenant la clé privée chiffrée.
Future<String> encryptPrivateKey(String privateKey, String password, Uint8List salt, Uint8List iv) {
  return deriveEncodingKey(password, salt).then((keyBytes) {
    final key = Key(Uint8List.fromList(keyBytes));
    final encrypter = Encrypter(AES(key, mode: AESMode.cfb64));

    final encrypted = encrypter.encrypt(privateKey, iv: IV(iv));
    return encrypted.base64;
  });
}


/// Déchiffre la clé privée chiffrée avec un mot de passe donné, un sel et un vecteur d'initialisation (IV) 
/// en utilisant l'algorithme AES avec le mode de chiffrement CFB64.
///
/// [encryptedPrivateKeyBase64] : La clé privée chiffrée encodée en base64.
/// [password] : Le mot de passe utilisé pour dériver la clé de chiffrement.
/// [salt] : Le sel utilisé pour dériver la clé de chiffrement.
/// [iv] : Le vecteur d'initialisation utilisé pour le chiffrement AES.
///
/// Retourne une Future résolvant une chaîne contenant la clé privée déchiffrée.
Future<String> decryptPrivateKey(String encryptedPrivateKeyBase64, String password, Uint8List salt, Uint8List iv) {
  return deriveEncodingKey(password, salt).then((keyBytes) {
    final key = Key(Uint8List.fromList(keyBytes));
    final encrypter = Encrypter(AES(key, mode: AESMode.cfb64));

    final decrypted = encrypter.decrypt64(encryptedPrivateKeyBase64, iv: IV(iv));
    return decrypted;
  });
}


/// Dérive une clé de chiffrement à partir d'un mot de passe donné et d'un sel 
/// en utilisant l'algorithme PBKDF2 avec HMAC-SHA256.
///
/// [password] : Le mot de passe utilisé pour dériver la clé de chiffrement.
/// [salt] : Le sel utilisé pour la dérivation de clé.
///
/// Retourne une Future résolvant une liste d'octets représentant la clé dérivée.
Future<Uint8List> deriveEncodingKey(String password, Uint8List salt) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac(Sha256()),
    iterations: 100000,
    bits: 256,
  );

  final sk = await pbkdf2.deriveKeyFromPassword(nonce: salt, password: password);
  final keyBytes = await sk.extractBytes();
  return Uint8List.fromList(keyBytes);
}


/// Génère une paire de clés à partir de clés encodées en base64.
///
/// [privateKeyBase64] : La clé privée encodée en base64.
/// [publicKeyBase64] : La clé publique encodée en base64.
///
/// Retourne une Future résolvant une paire de clés.
Future<KeyPair> keyPairFromBase64(String privateKeyBase64, String publicKeyBase64) async {
  final privateKey = await secretKeyFromBase64(privateKeyBase64);
  final publicKey = await simplePublickeyFromBase64(publicKeyBase64);
  return SimpleKeyPairData(await privateKey.extractBytes(), publicKey: publicKey, type: KeyPairType.x25519);
}

/// Génère une paire de clés à partir de clés SecretKey et SimplePublicKey.
///
/// [privateKey] : La clé privée au format SecretKey.
/// [publicKey] : La clé publique au format SimplePublicKey.
///
/// Retourne une Future résolvant une paire de clés.
Future<KeyPair> keyPairFromSecretKeyAndSimplePublicKey(SecretKey privateKey, SimplePublicKey publicKey) async {
  return SimpleKeyPairData(await privateKey.extractBytes(), publicKey: publicKey, type: KeyPairType.x25519);
}


/// Crée une clé publique à partir d'une clé encodée en base64.
///
/// [keyBase64] : La clé publique encodée en base64.
///
/// Retourne une Future résolvant une clé publique.
Future<SimplePublicKey> simplePublickeyFromBase64(String keyBase64) async {
  final publicKeyBytes = base64.decode(keyBase64);
  return SimplePublicKey(Uint8List.fromList(publicKeyBytes), type: KeyPairType.x25519);
}


/// Crée une clé secrète à partir d'une clé encodée en base64.
///
/// [keyBase64] : La clé secrète encodée en base64.
///
/// Retourne une Future résolvant une clé secrète.
Future<SecretKey> secretKeyFromBase64(String keyBase64) async {
  final publicKeyBytes = base64.decode(keyBase64);
  return SecretKey(Uint8List.fromList(publicKeyBytes));
}


/// Calcule la clé secrète partagée entre une paire de clés locales et une clé publique distante
/// en utilisant l'algorithme de Diffie-Hellman X25519.
///
/// [keyPair] : La paire de clés locale contenant la clé privée et la clé publique.
/// [publicKey] : La clé publique distante avec laquelle calculer la clé secrète partagée.
///
/// Retourne une Future résolvant une clé secrète partagée [SecretKey].
Future<SecretKey> calculateSharedSecretKey(KeyPair keyPair, PublicKey publicKey) async {
  final algorithm = X25519();
  final sharedSecretKey = await algorithm.sharedSecretKey(
    keyPair: keyPair,
    remotePublicKey: publicKey,
  );
  return sharedSecretKey;
}


Future<String> encryptString(String plaintext, SecretKey secretKey) async {
  final plainBytes = utf8.encode(plaintext); // Convertir la chaîne de caractères en une liste d'octets UTF-8
  final secretBox = await aesGcm.encrypt(plainBytes, secretKey: secretKey); // Chiffrer la liste d'octets avec la clé secrète
  return base64.encode(secretBox.concatenation()); // Renvoyer la représentation base64 de la SecretBox
}

// Fonction pour déchiffrer une chaîne de caractères chiffrée
Future<String> decryptString(String encryptedString, SecretKey secretKey) async {
  final encryptedBytes = base64.decode(encryptedString); // Convertir la chaîne de caractères chiffrée depuis base64 en une liste d'octets
  final newSecretBox = SecretBox.fromConcatenation( // Reconstituer la SecretBox à partir de la représentation binaire
    encryptedBytes,
    nonceLength: aesGcm.nonceLength,
    macLength: aesGcm.macAlgorithm.macLength,
    copy: true, // Ne pas copier les octets à moins que cela soit nécessaire
  );
  final clearBytes = await aesGcm.decrypt(newSecretBox, secretKey: secretKey); // Déchiffrer la SecretBox reconstituée avec la même clé secrète
  return utf8.decode(clearBytes);  // Convertir la liste d'octets déchiffrée en une chaîne de caractères UTF-8
}


void main() async {
  try {
    print("\n||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| R E L O A D |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||\n ");

    // Définir le sel et le vecteur d'initialisation (IV)
    // On les récupère depuis le fichier salt_iv.dart
    final salt = base64.decode("URA2/4uYg2OIlct6Pq9/ya4snpkpVMYmtXHHnsW1Qsc=");
    final iv = base64.decode("9zTTNe2bBYMNzKFGLxjd89UC1Nk2ZoGMFSK0FocJZI0=");

    print('Salt: $salt');
    print('IV: $iv');

    //TODO Faire une fonction qui récup les clés de la bdd et les stockées dans des variables homonymes. Adapter le code en fontcion.

    // Générer une paire de clés X25519 //! Les clés seront plus tard récupéré depuis la bdd - mais elles seront générés côté front
    final keysBase64 = await KG.generateKeys();
    final publicKeyBase64 = keysBase64['publicKeyBase64'];
    final privateKeyBase64 = keysBase64['privateKeyBase64'];

    // Mot de passe pour chiffrer la clé privée
    const password = '123test';

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    print("\n ----- Encryption / Decryption test ----- ");

    // Chiffrer la clé privée
    // La clé privée est chiffrée avec un mot de passe et un sel (on prépare son stockage dans la bdd - on la chiffre pour que le transport soit sécurisé)
    final encryptedPrivateKey = await encryptPrivateKey(privateKeyBase64!, password, salt, iv); 
    print('Encrypted private key: $encryptedPrivateKey');

    // Déchiffrer la clé privée
    // la clé privée est déchiffrée avec le mot de passe et le sel (on prépare sa récupération depuis la bdd)
    final decryptedPrivateKey = await decryptPrivateKey(encryptedPrivateKey, password, salt, iv);
    print('Decrypted private key: $decryptedPrivateKey');

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    print("\n ----- KeyPair generation ----- ");

    // On récupère les clés publiques/privées dans leurs formats respectifs
    //final privateKey = await secretKeyFromBase64(parsedKeys['privateKey']!); // Format : SecretKey
    final publicKey = await simplePublickeyFromBase64(publicKeyBase64!); // Format : SimplePublicKey

    // Générer un objet KeyPair à partir des clés en base64
    final keyPair = await keyPairFromBase64(privateKeyBase64, publicKeyBase64);
    print("   KeyPair : $keyPair");

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    print("\n ----- Shared secret key calculation ----- ");
    // Calculer la clé secrète partagée
    final sharedSecretKey = await calculateSharedSecretKey(keyPair, publicKey);
    print("   Shared Secret Key : ${base64.encode(await sharedSecretKey.extractBytes())}"); // Afficher la clé secrète partagée en base64


    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------

    print("\n ----- Message encryption test ----- ");

    // Message à chiffrer
    const message = 'Hello World!';
    print("Message à chiffer: $message");
    final plainText = utf8.encode(message);

    // Chiffrer le message
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final encryptedMessage = await algorithm.encrypt(plainText, secretKey: sharedSecretKey, nonce: nonce);

    // Afficher le message chiffré
    print('Message chiffré: ${base64.encode(encryptedMessage.cipherText)}');

    // Déchiffrer le message
    final decrypted = await algorithm.decrypt(encryptedMessage, secretKey: sharedSecretKey);

    // Afficher le message déchiffré
    print('Message déchiffré: ${utf8.decode(decrypted)}');


    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------
  
    print("\n ----- Simulating Exchange and Encryption of a Message ----- ");

    // Générer les clés pour les deux utilisateurs
    final keysUser1 = await KG.generateKeys();
    final keysUser2 = await KG.generateKeys();

    // Récupérer les clés publiques/privées des deux utilisateurs
    final publicKeyUser1 = await simplePublickeyFromBase64(keysUser1['publicKeyBase64']!);
    final privateKeyUser1 = await secretKeyFromBase64(keysUser1['privateKeyBase64']!);

    final publicKeyUser2 = await simplePublickeyFromBase64(keysUser2['publicKeyBase64']!);
    final privateKeyUser2 = await secretKeyFromBase64(keysUser2['privateKeyBase64']!);

    // Calculer la clé secrète partagée entre les deux utilisateurs
    final sharedSecretKeyUser1 = await calculateSharedSecretKey(SimpleKeyPairData(await privateKeyUser1.extractBytes(), publicKey: publicKeyUser1, type: KeyPairType.x25519), publicKeyUser2);
    final sharedSecretKeyUser2 = await calculateSharedSecretKey(SimpleKeyPairData(await privateKeyUser2.extractBytes(), publicKey: publicKeyUser2, type: KeyPairType.x25519), publicKeyUser1);

    // Message à chiffrer
    const messageSimulation = 'Bonjour, j\'espère que vous allez bien.';
    print('Message envoyé par l\'utilisateur 1 : $messageSimulation');

    // Chiffrer le message avec la clé secrète partagée par l'utilisateur 1
    final algorithmSimulation = AesGcm.with256bits();
    final nonceSimulation = algorithm.newNonce();
    final messageSimulationEncrypted = await algorithmSimulation.encrypt(
      utf8.encode(messageSimulation),
      secretKey: sharedSecretKeyUser1,
      nonce: nonceSimulation,
    );

    print("Message chiffré par l'utilisateur 1 : ${base64.encode(messageSimulationEncrypted.cipherText)}");

    // Déchiffrer le message reçu par l'utilisateur 2 avec la clé secrète partagée par l'utilisateur 2
    final decryptedMessage = await algorithm.decrypt(messageSimulationEncrypted, secretKey: sharedSecretKeyUser2);

    // Afficher le message déchiffré par l'utilisateur 2
    print('Message déchiffré par l\'utilisateur 2 : ${utf8.decode(decryptedMessage)}');


    print("-----------------------------------------------------------");

    final aesGcm = AesGcm.with256bits();
    final secretKey = await aesGcm.newSecretKey();

    // Message à chiffrer
    final plaintext = 'Hello, world!';

    // Chiffrer le message
    final encryptedBytes = await encryptString(plaintext, secretKey);
    print('Encrypted: $encryptedBytes');

    // Déchiffrer le message chiffré
    final decryptedText = await decryptString(encryptedBytes, secretKey);
    print('Decrypted: $decryptedText');




  } catch (e) {
    print(e); // Afficher les erreurs
  }
}


/*
Solution pour l'utilisation de fonction Future : lors de l'appel à la fonction ajouter le 
mot-clé await devant permet d'obtenir au final un objet non future
*/