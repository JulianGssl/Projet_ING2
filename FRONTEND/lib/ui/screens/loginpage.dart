import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'chatlistpage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                print("Trying to login...");
                var response = await http.post(
                  Uri.parse('$url/login'),
                  body: jsonEncode({
                    'username': _usernameController.text,
                    'password': _passwordController.text
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
                //var response2 = await http.get( Uri.parse('$url/test'));
                print("Received response: ${response.statusCode}");
                print("Response body: ${response.body}");
                if (response.statusCode == 200) {
                  print("Login successful, navigating to ChatListPage");
                  var responseData = json.decode(response.body);
                  String sessionToken = responseData['access_token'];
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatListPage(sessionToken)),
                  );
                } else {
                  print("Invalid credentials received, updating error message");
                  setState(() {
                    _errorMessage = 'Identifiants invalides. Veuillez réessayer.';
                  });
                }
              },
              child: Text('Login'),
            ),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}