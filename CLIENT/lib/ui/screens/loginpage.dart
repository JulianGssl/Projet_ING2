import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/user.dart';
import '../../models/url.dart';
import '../../models/constants.dart';

import 'package:jwt_decode/jwt_decode.dart';

import 'chatlistpage.dart';
import 'validationpage.dart';
import '../../utils/key_generation.dart';

import '../../utils/crypto.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Chat',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white24,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
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
      labelStyle: TextStyle(color: Colors.white70, fontFamily: fontLufga),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade700),
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
      style: TextStyle(color: Colors.white, fontFamily: fontLufga),
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
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
          elevation: 5.0, // L'élévation donne l'effet d'ombre au bouton
          shadowColor: Colors.black54, // Couleur de l'ombre
        ),
        child: Text(text, style: TextStyle(fontFamily: fontLufga)),
      ),
      if (nbLoginTry > 3)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Too many connection attempts. Please try again in 30 seconds.',
            style: TextStyle(color: Colors.amber, fontFamily: fontLufga), // Adjusted to a warning color that stands out
          ),
        ),
      if (_errorMessage.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            _errorMessage,
            style: TextStyle(color: Colors.red, fontFamily: fontLufga),
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
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
          elevation: 5.0,
          shadowColor: Colors.black54, // Couleur de l'ombre
        ),
        child: Text(text, style: TextStyle(fontFamily: fontLufga)),
      ),
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red, fontFamily: fontLufga),
            ),
          ),
        if (_successSignUp.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _successSignUp, // Should be _successSignUp instead of _errorMessage
              style: TextStyle(color: Colors.green, fontFamily: fontLufga),
            ),
          ),
      ],
    );
  }
 
 
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C0F45),
            Color(0xFF6632C6),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                AppBar(
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                 
                ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('lib/assets/images/logo.png', width: 300),
                ),
              ),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Theme(
                          data: Theme.of(context).copyWith(
                            tabBarTheme: TabBarTheme(
                              // Définir pour les onglets sélectionnés
                              labelStyle: TextStyle(
                                fontFamily: fontLufga,
                                fontSize: 24  , // Augmente la taille du texte pour les onglets sélectionnés
                              ),
                              // Définir pour les onglets non sélectionnés
                              unselectedLabelStyle: TextStyle(
                                fontFamily: fontLufga,
                                fontSize: 16, // Augmente la taille du texte pour les onglets non sélectionnés
                              ),
                            ),
                          ),
                          child: TabBar(
                            tabs: const [
                              Tab(text: 'Sign Up'),
                              Tab(text: 'Log In'),
                            ],
                            indicatorColor: Colors.purple.shade200,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                          ),
                        ),
 
                        Expanded(
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    _buildTextField(_nameController, 'Username'),
                                    const SizedBox(height: 16.0),
                                    _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
                                    const SizedBox(height: 16.0),
                                    _buildTextField(_passwordControllerSignUp, 'Password', isPassword: true),
                                    const SizedBox(height: 40.0),
                                    _buildSignUpButton('Sign Up'),
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                padding: EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    _buildTextField(_usernameController, 'Username'),
                                    const SizedBox(height: 16.0),
                                    _buildTextField(_passwordController, 'Password', isPassword: true),
                                    const SizedBox(height: 40.0),
                                    _buildLoginButton('Log In'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
        if (responseData['access_token'] != null) {
          String sessionToken = responseData['access_token'];

          Map<String, dynamic> decodedToken = Jwt.parseJwt(sessionToken);

          int userId = decodedToken['idUser'];
          String username =
              '${_usernameController.text}#$userId'; // Concaténation du nom d'utilisateur avec l'ID
          // Création de l'objet User de l'utilisateur connecté
          String passwordUser = _passwordController.text;

          Uint8List salt =
              Uint8List.fromList(utf8.encode(decodedToken["salt"]));
          SimplePublicKey public_key =
              await simplePublickeyFromBase64(decodedToken["public_key"]);
          SecretKey private_key = await secretKeyFromBase64(
              await decryptPrivateKey(decodedToken["private_key_encrypted"],
                  passwordUser, salt, salt));

          User loggedUser = User(
              id: userId,
              username: username,
              password: passwordUser,
              salt: salt,
              publicKey: public_key,
              privateKey: private_key);
          print("User : $loggedUser");
          print("User : ${loggedUser.id} | ${loggedUser.username}");
          //SI le compte est validé on envoie vers chatlistpage sinon on envoie vers la page de verif

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListPage(
                sessionToken: sessionToken,
                currentUser:
                    loggedUser, // Passage de l'objet user à ChatListPage
              ),
            ),
          );
        } else {
          int idUser = responseData['idUser'];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ValidPage(
                idUser: idUser,
              ),
            ),
          );
        }
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
      final keys = await generateKeys();
      String salt = generateSalt();
      Uint8List salt_converted = Uint8List.fromList(utf8.encode(salt));
      var response = await http.post(
        Uri.parse('$url/signUp'),
        body: jsonEncode({
          'username': _nameController.text,
          'email': _emailController.text,
          'password': _passwordControllerSignUp.text,
          'publicKeyBase64':
              keys['publicKeyBase64'], // Ajout de la clé publique
          'privateKeyBase64': await encryptPrivateKey(keys['privateKeyBase64']!,
              _passwordControllerSignUp.text, salt_converted, salt_converted),
          'salt': salt
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print("Inscritpion successful, navigating to ValidPage");
        var responseData = json.decode(response.body);
        int idUser = responseData["idUser"];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ValidPage(
              idUser: idUser,
            ),
          ),
        );
      } else {
         var responseData = json.decode(response.body);
        String message = responseData["message"];
        _errorMessage = message;
        setState(() {}); 
      }
    } else {
      _errorMessage =
          'Please enter a password of at least 8 characters, with at least one number, one uppercase letter and one special character';
      setState(() {});
    }
  }
}
