import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'chatlistpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  IO.Socket? socket;
  // - IO.Socket? socket : Déclare une variable de type IO.Socket pouvant être null.
  // - late IO.Socket socket : Déclare une variable de type IO.Socket qui doit être initialisée avant utilisation. Déclenche une erreur si non initialisée.


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _handleLoginButtonPressed,
              child: const Text('Login'),
            ),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLoginButtonPressed() async {
    print("Trying to login...");
    var response = await http.post(
      Uri.parse('$url/login'),
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print("Login successful, navigating to ChatListPage");
      // Navigation vers la page ChatListPage
      var responseData = json.decode(response.body);
      String sessionToken = responseData['access_token'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatListPage(
            sessionToken: sessionToken,
            username: _usernameController.text,
            socket: socket!,
          ),
        ),
      );
      // Initialisation de la connexion Socket.IO
      print("/loginpage - calling _initSocketIO");
      _initSocketIO();
    } else {
      print("Invalid credentials received, updating error message");
      setState(() {
        _errorMessage =
            'Identifiants invalides. Veuillez réessayer.';
      });
    }
  }

  void _initSocketIO() {
    // Initialisation de la connexion Socket.IO
    socket = IO.io('http://localhost:8000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // Connexion au serveur Socket.IO
    socket?.connect();
    socket?.on('connectResponse', (data) {
      print('Connected to the server');
      print('Received message: $data');
    });
  }
}
