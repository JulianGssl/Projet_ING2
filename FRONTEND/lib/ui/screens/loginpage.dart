import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'chatlistpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _errorMessage = '';

  IO.Socket? socket;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.blue),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label),
      obscureText: isPassword,
      keyboardType: keyboardType,
    );
  }

  Widget _buildLoginButton(String text) {
    return ElevatedButton(
      onPressed: () {
        _handleLoginButtonPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
      ),
      child: Text(text),
    );
  }

  Widget _buildSignOnButton(String text) {
    return ElevatedButton(
      onPressed: () {
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
      ),
      child: Text(text),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Message Application',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Authentication',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
              tabs: const [
                Tab(text: 'Create Account'),
                Tab(text: 'Log In'),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildTextField(_nameController, 'Your name'),
                        SizedBox(height: 16.0),
                        _buildTextField(_emailController, 'Email',
                            keyboardType: TextInputType.emailAddress),
                        SizedBox(height: 16.0),
                        _buildTextField(_passwordController, 'Password',
                            isPassword: true),
                        SizedBox(height: 24.0),
                        _buildSignOnButton('Get Started'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildTextField(_usernameController, 'Username'),
                        SizedBox(height: 16.0),
                        _buildTextField(_passwordController, 'Password',
                            isPassword: true),
                        SizedBox(height: 24.0),
                        _buildLoginButton('Sign In'),
                      ],
                    ),
                  ),
                ],
              ),
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
        _errorMessage = 'Identifiants invalides. Veuillez réessayer.';
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
