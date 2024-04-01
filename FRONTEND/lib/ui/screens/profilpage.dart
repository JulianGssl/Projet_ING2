import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../models/url.dart';

import 'editprofilpage.dart';


class ProfilePage extends StatefulWidget {
  final String sessionToken;
  

  const ProfilePage({super.key, required this.sessionToken});


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
      return Center(child: CircularProgressIndicator()); // Affichage d'un indicateur de chargement pendant la récupération des données
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!)); // Gestion des erreurs
    }


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 36),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://picsum.photos/id/237/200/300'),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 16),
          Text(
            _userData['username'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _userData['email'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Divider(
            height: 20, // Espace total verticalement, y compris la ligne
            thickness: 2, // Épaisseur du trait
            indent: 50, // Espace de début du trait
            endIndent: 50, // Espace de fin du trait
            color: Colors.grey.shade300, // Couleur du trait
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
              child: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
            ),
          ),
          SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildThemeModeSwitch() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 56, // Hauteur fixe pour tous les éléments d'entrée
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 16),
            Icon(Icons.nightlight_round, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Transform.scale(
              scale: 0.9, // Ajustez la taille du switch si nécessaire
              child: CupertinoSwitch(
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                activeColor: Colors.black,
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
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(text),
          onTap: () {
            if (text == 'Edit Profile') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage(sessionToken: widget.sessionToken)),
              );
            }
            // Ajoutez d'autres conditions pour les autres options si nécessaire
          },
        ),
      ),
    );
  }

}
