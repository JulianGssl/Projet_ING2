import 'dart:convert';
import 'package:cryptography/cryptography.dart';

/// Génère une paire de clés X25519, puis les encode en base64 et les formate au format PEM.
///
/// Cette fonction utilise l'algorithme X25519 pour générer une paire de clés, puis encode la clé privée et la clé publique en base64.
/// Ensuite, elle formate ces clés au format PEM.
///
/// Retourne une Future résolvant une carte contenant les clés privée et publique au format PEM.
Future<Map<String, String>> generateKeys() async {
  // Générer une paire de clés X25519
  final algorithm = X25519();

  // Générer une paire de clés
  final keyPair = await algorithm.newKeyPair();

  // Encoder les clés en base64
  final extractedPublicKey = await keyPair.extractPublicKey();

  final privateKeyBase64 = base64.encode(await keyPair.extractPrivateKeyBytes());
  final publicKeyBase64 = base64.encode(extractedPublicKey.bytes);

  return {
    'publicKeyBase64': publicKeyBase64,
    'privateKeyBase64': privateKeyBase64,
  };
}

void main() async {
  final keys = await generateKeys();
  print('Public key PEM: ${keys['publicKeyPem']}');
  print('Private key PEM: ${keys['privateKeyPem']}');
}