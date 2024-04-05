import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class User {
  final int id;
  final String username;
  final String password;
  final Uint8List salt;
  final SimplePublicKey publicKey;
  final SecretKey privateKey;

  User(
      {required this.id,
      required this.username,
      required this.password,
      required this.salt,
      required this.publicKey,
      required this.privateKey});

  @override
  String toString() {
    return jsonEncode({
      'id': id,
      'username': username,
      'password': password,
      'salt': base64.encode(salt),
      'public_key': base64.encode(publicKey.bytes),
      'private_key': privateKey.extract().toString(),
    });
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        salt: json['salt'],
        publicKey: json['public_key'],
        privateKey: json['private_key']);
  }
}
