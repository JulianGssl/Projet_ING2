èimport 'package:flutter/material.dart';
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
  final TextEditingController _passwordControllerSignUp =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _errorMessage = '';
  String _successSignUp = '';

  IO.Socket? socket;
  int nbLoginTry = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordControllerSignUp.dispose();
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
    return Column(
      children: [
        ElevatedButton(
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
        ),
        if (nbLoginTry > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Too many connection attempts. Please try again in 30 seconds.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildSignUpButton(String text) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _handleSignUpButtonPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
          ),
          child: Text(text),
        ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (_successSignUp.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.green),
            ),
          ),
      ],
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
                        _buildTextField(_nameController, 'Username'),
                        SizedBox(height: 16.0),
                        _buildTextField(_emailController, 'Email',
                            keyboardType: TextInputType.emailAddress),
                        SizedBox(height: 16.0),
                        _buildTextField(_passwordControllerSignUp, 'Password',
                            isPassword: true),
                        SizedBox(height: 24.0),
                        _buildSignUpButton('Get Started'),
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
    nbLoginTry++;
    if (nbLoginTry <= 3) {
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
        int userId = responseData['idUser']; // Récupération de l'ID de l'utilisateur
        String username = '${_usernameController.text}#$userId'; // Concaténation du nom d'utilisateur avec l'ID
        // Création de l'objet User de l'utilisateur connecté
        User loggedUser = User(id: userId, username: username);
        print("User : ${loggedUser.id} | ${loggedUser.username}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListPage(
              sessionToken: sessionToken,
              currentUser: loggedUser, // Passage de l'objet user à ChatListPage
            ),
          ),
        );
    } else {
        print("Invalid credentials received");
        setState(() {
          _errorMessage = 'Invalid credentials. Please try again.';
          _usernameController.text =
              ''; // Vide le champ de saisie du nom d'utilisateur
          _passwordController.text = '';
        });
        setState(() {});
      }
    } else {
      setState(() {
        _usernameController.text =
            ''; // Vide le champ de saisie du nom d'utilisateur
        _passwordController.text = '';
      });
      await Future.delayed(Duration(seconds: 30));
      // Réinitialiser le nombre de tentatives de connexion
      nbLoginTry = 0;
      setState(() {});
    }
  }

  bool verifPassword(String password) {
    if (password.length < 12) {
      return false;
    }
    final RegExp majusculeRegex = RegExp(r'[A-Z]');
    final RegExp numberRegex = RegExp(r'\d');
    final RegExp caractereSpecialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!majusculeRegex.hasMatch(password)) {
      return false;
    }
    if (!numberRegex.hasMatch(password)) {
      return false;
    }

    // Vérifie la présence d'un caractère spécial
    if (!caractereSpecialRegex.hasMatch(password)) {
      return false;
    }

    return true;
  }

  void _handleSignUpButtonPressed() async {
    if (verifPassword(_passwordControllerSignUp.text)) {
      var response = await http.post(
        Uri.parse('$url/signUp'),
        body: jsonEncode({
          'username': _nameController.text,
          'email': _emailController.text,
          'password': _passwordControllerSignUp.text
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print("Inscritpion successful, navigating to ChatListPage");
        // Navigation vers la page ChatListPage
        var responseData = json.decode(response.body);
        _successSignUp = responseData['message'];
        setState(() {
          _nameController.text =
              ''; // Vide le champ de saisie du nom d'utilisateur
          _emailController.text = '';
          _passwordControllerSignUp.text = '';
        });
        setState(() {});
      } else {
        print("Invalid credentials received, updating error message");
      }
    } else {
      _errorMessage =
          'Please enter a password of at least 12 characters, with at least one number, one uppercase letter and one special character';
      setState(() {});
    }
  }
}
