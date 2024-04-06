import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import "profilpage.dart";

import '../../models/url.dart';
import '../../models/user.dart';
import '../../models/constants.dart';


class EditProfilePage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;


  const EditProfilePage({super.key, required this.sessionToken, required this.currentUser});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true; // Ajout d'un indicateur de chargement
  String? _errorMessage; // Pour gérer les messages d'erreur
  late String _csrfToken;

  Map<String, dynamic> _userData = {}; // Corrected type

  @override
  void initState() {
    super.initState();
    _fetchCSRFToken('get_CSRF/edit_profile/1');
    _fetchGetProfile();
  } 


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


//   Future<String> _fetchCSRFToken() async {
//   final response = await http.get(
//         Uri.parse('$url/get_CSRF'),
//         headers: {'Authorization': 'Bearer ${widget.sessionToken}', 'Content-Type': 'application/json'},
//       );
//   if (response.statusCode == 200) {
//     var responseData=json.decode(response.body);
//     String csrfToken = responseData['csrf_token'];
//     setState(() {
//         _csrfToken = csrfToken;
//       });
//     return response.body;
//   } else {
//     throw Exception('Failed to load CSRF token');
//   }
// }

Future<String> _fetchCSRFToken(String formRoute) async {
  // FormRoute représente la route spécifique pour obtenir le jeton CSRF
  final response = await http.get(
    Uri.parse('$url/$formRoute'), // Utilisez la route spécifique passée en paramètre
    headers: {
      'Authorization': 'Bearer ${widget.sessionToken}',
      'Content-Type': 'application/json'
    },
  );
  if (response.statusCode == 200) {
    var responseData = json.decode(response.body);
    String csrfToken = responseData['csrf_token'];
    setState(() {
      _csrfToken = csrfToken;
    });
    return response.body;
  } else {
    throw Exception('Failed to load CSRF token');
  }
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
                'X-CSRF-TOKEN': _csrfToken,
                'Content-Type': 'application/json',
              },
    );
    print(_csrfToken);
    if (response.statusCode == 200) {
      // Redirection vers ChatListPage
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage(currentUser: widget.currentUser, sessionToken: widget.sessionToken)));
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
      labelText: hint,
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

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hint),
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      style: TextStyle(
        color: Colors.white,
        fontFamily: fontLufga
      ),
    );
  }

  void _showPasswordDialog() {
  TextEditingController _passwordVerificationController = TextEditingController();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.deepPurple.shade100, // Set light purple background
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align title and close button
          children: [
            Text('Verify Your Password', style: TextStyle(color: Colors.white, fontFamily: fontLufga),),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white), // Cross icon to close the popup
              onPressed: () => Navigator.of(context).pop(), // Close the popup
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
      return Center(child: CircularProgressIndicator()); // Displaying a loading indicator while fetching data
    }
 
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!)); // Error handling
    }
 
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1C0F45), // Dark purple
            Color(0xFF6632C6), // Light purple
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('Edit Profile', style: TextStyle(color: Colors.white, fontFamily: fontLufga)),
          iconTheme: IconThemeData(color: Colors.white), // Set the color of the back arrow
        ),
 
        backgroundColor: Colors.transparent, // Important to see the gradient
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
                  backgroundColor: Colors.deepPurple, // Set the background color to deep purple
                  foregroundColor: Colors.white, // Set the text color to white
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0), // Adjust the padding
                  elevation: 5.0, // Add elevation for shadow effect
                  shadowColor: Colors.black54, // Set the shadow color
                ),
                child: Text(
                  'Modifier',
                  style: TextStyle(fontFamily: fontLufga), // Set the font family to Lufga
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
 
}
 


