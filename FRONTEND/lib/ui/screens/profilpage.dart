import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_github_version/ui/screens/chatlistpage.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/url.dart';
import '../../models/user.dart';
import '../../models/constants.dart';


import 'editprofilpage.dart';


class ProfilePage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;
  

  const ProfilePage({super.key, required this.sessionToken, required this.currentUser});


  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false; // This should be connected to your theme state management.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true; // Ajout d'un indicateur de chargement
  String? _errorMessage; // Pour gérer les messages d'erreur

  Map<String, dynamic> _userData = {}; // Corrected type

  @override
  void initState() {
    super.initState();
    _fetchGetProfile();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator()); // Displaying a loading indicator while fetching data
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: TextStyle(fontFamily: fontLufga),)); // Error handling
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C0F45), Color(0xFF6632C6)], // Purple gradient
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => ChatListPage(currentUser: widget.currentUser, sessionToken: widget.sessionToken))
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text('Profile', style: TextStyle(fontFamily: fontLufga, color: Colors.white)),
          centerTitle: true,
        ),
        backgroundColor: Colors.transparent, // Important for the gradient to be visible
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 36),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.account_circle,
                size: 100, // This size should be adjusted based on the radius of the CircleAvatar
                color: Colors.white,
              ),
            ),

            SizedBox(height: 16),
            Text(
              _userData['username'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: fontLufga,
                color: Colors.white
              ),
            ),
            Text(
              _userData['email'],
              style: TextStyle(
                fontSize: 16,
                fontFamily: fontLufga,
                color: Colors.white
              ),
            ),
            SizedBox(height: 16),
            Divider(
              height: 20,
              thickness: 2,
              indent: 50,
              endIndent: 50,
              color: Colors.grey.shade300,
            ),
            _buildThemeModeSwitch(),
            _buildOption(context, Icons.edit, 'Edit Profile'),
            _buildOption(context, Icons.settings, 'Account Settings'),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Add logout logic
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: fontLufga, // Use the same font family as the login button
                    color: Colors.white, // Text color is set to white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Background color set to deep purple
                  foregroundColor: Colors.white, // Foreground color set to white
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners with a 30.0 radius
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0), // Symmetric padding
                  elevation: 5.0, // Elevation to create a shadow effect
                  shadowColor: Colors.black54, // Shadow color set to a semi-transparent black
                ),
              ),
            ),

            SizedBox(height: 36),
          ],
        ),
      ),
    );
  }


  Widget _buildThemeModeSwitch() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      height: 56, // Fixed height for all input elements
      decoration: BoxDecoration(
        color: Colors.deepPurple, // Set the background color to deep purple
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black54, // Shadow color
            blurRadius: 5.0, // Blur radius for the shadow
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 16),
          Icon(Icons.nightlight_round, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Dark Mode',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white, // Set text color to white
              fontFamily: fontLufga, // Set the font family to Lufga
            ),
          ),
          Spacer(),
          Transform.scale(
            scale: 0.9, // Adjust the switch size if necessary
            child: CupertinoSwitch(
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              activeColor: Colors.white, // Set active color to white
              trackColor: Colors.grey.shade400,
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
    ),
  );
}


  Widget _buildOption(BuildContext context, IconData icon, String text) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.deepPurple, // Set the background color to deep purple
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black54, // Shadow color
            blurRadius: 5.0, // Blur radius for the shadow
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: TextStyle(
            fontFamily: fontLufga, // Set the font family to Lufga
            color: Colors.white, // Set text color to white
          ),
        ),
        onTap: () {
          if (text == 'Edit Profile') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage(currentUser: widget.currentUser, sessionToken: widget.sessionToken)),
            );
          }
          // Add other conditions for other options if necessary
        },
      ),
    ),
  );
}


}
