import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import "profilpage.dart";

import '../../models/url.dart';


class EditProfilePage extends StatefulWidget {
  final String sessionToken;


  const EditProfilePage({super.key, required this.sessionToken});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true; // Ajout d'un indicateur de chargement
  String? _errorMessage; // Pour gérer les messages d'erreur

  Map<String, dynamic> _userData = {}; // Corrected type

  @override
  void initState() {
    super.initState();
    _fetchGetProfile();
  } 


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _fetchGetProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$url/get_profile'),
        headers: {'Authorization': 'Bearer ${widget.sessionToken}', 'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userData = data['user_data'];
        _nameController.text = _userData['username']; // Initialisation des contrôleurs ici
        _emailController.text = _userData['email'];
        setState(() {
          _isLoading = false; // Mise à jour de l'état de chargement
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }


void _fetchEditProfile(String currentPassword) async {
    final response = await http.post(
      Uri.parse('$url/edit_profile'),
      body: jsonEncode({
        'username': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'currentPassword': currentPassword
      }),
      headers: {'Authorization': 'Bearer ${widget.sessionToken}',
                'Content-Type': 'application/json',
              },
    );
    if (response.statusCode == 200) {
      // Redirection vers ChatListPage
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(sessionToken: widget.sessionToken)));
    } else if (response.statusCode == 404) {
      // Affichage d'un message d'erreur
      final data = jsonDecode(response.body);
      final String errorMessage = data['message'] ?? 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      // Gérer d'autres codes d'erreur éventuels de la même manière
      print('Unexpected error: ${response.statusCode}');
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hint),
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
    );
  }

  void _showPasswordDialog() {
  TextEditingController _passwordVerificationController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pour aligner le titre et le bouton de fermeture
          children: [
            Text('Verify Your Password'),
            IconButton(
              icon: Icon(Icons.close), // Icône de croix pour fermer la pop-up
              onPressed: () => Navigator.of(context).pop(), // Ferme la pop-up
            ),
          ],
        ),
        content: TextField(
          controller: _passwordVerificationController,
          decoration: _inputDecoration('Enter your password'),
          obscureText: true,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () {
                _fetchEditProfile(_passwordVerificationController.text);
                Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {

    if (_isLoading) {
      return Center(child: CircularProgressIndicator()); // Affichage d'un indicateur de chargement pendant la récupération des données
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!)); // Gestion des erreurs
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Edit Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            _buildTextField(_nameController..text = _userData['username'], 'Your name'),
            SizedBox(height: 16.0),
            _buildTextField(_emailController..text = _userData['email'], 'Email'),
            SizedBox(height: 16.0),
            _buildTextField(_passwordController, 'Password', isPassword: true),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _showPasswordDialog,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: Text('Modifier'),
            ),
          ],
        ),
      ),
    );
  }
}

