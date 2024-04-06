import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/url.dart';
import '../../models/constants.dart';

import 'customebottomnavbar.dart';
import '../../models/user.dart';
import 'chatlistpage.dart';
import 'contactpage.dart';


class AddFriendPage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;

  const AddFriendPage({super.key, required this.sessionToken, required this.currentUser});

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  List<Map<String, String>> users =
      []; // Liste de maps pour stocker les utilisateurs (nom d'utilisateur et ID)

  TextEditingController searchController = TextEditingController();
  late String _csrfToken;

  @override
  void initState() {
    _fetchCSRFToken('get_CSRF/displayUserByName/2');
    super.initState();
  }

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


  // Fonction pour récupérer les utilisateurs depuis le backend Flask
  Future<void> fetchUsers(String username) async {
    final response = await http.post(Uri.parse('$url/displayUserByName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.sessionToken}',
          'X-CSRF-TOKEN': _csrfToken,
        },
        body: json.encode({'username': username}));

    if (response.statusCode == 200) {
      // Si la requête est réussie
      final jsonResponse = json.decode(response.body);
      setState(() {
        List<dynamic> userList = jsonResponse['users'];
        users = userList.map<Map<String, String>>((user) {
          return {'id': user['id'].toString(), 'username': user['username']};
        }).toList();
      });
    } else {
      // En cas d'échec de la requête
      throw Exception('Failed to load users');
    }
  }

  Future<void> addUser(String username, String userId) async {
    final response = await http.post(
      Uri.parse('$url/addFriend'), // Endpoint pour ajouter un utilisateur
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.sessionToken}'
      },
      body: json.encode({'username': username, 'id_contact': userId}),
    );

    if (response.statusCode == 200) {
      // Si l'ajout est réussi
      // Afficher un message à l'utilisateur ou effectuer une autre action
      print('Utilisateur ajouté avec succès');
      Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContactPage(
                            sessionToken: widget.sessionToken,
                            currentUser: widget.currentUser)));
    } else {
      // En cas d'échec de l'ajout
      throw Exception('Failed to add user');
    }
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
         appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ChatListPage(
                  currentUser: widget.currentUser,
                  sessionToken: widget.sessionToken,
                ),
              ));
            },
          ),
          title: Text('Add Friend', style: TextStyle(fontFamily: 'fontLufga', color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white, fontFamily: 'fontLufga'),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur',
                  hintStyle: TextStyle(fontFamily: 'fontLufga', color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                fetchUsers(searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
                elevation: 5.0,
                shadowColor: Colors.black54,
              ),
              child: Text(
                'Rechercher',
                style: TextStyle(fontFamily: 'fontLufga', color: Colors.white),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 100.0), // donnez de l'espace pour le bouton
                        child: ListTile(
                          title: Text(
                            users[index]['username'] ?? '',
                            style: TextStyle(fontFamily: 'fontLufga', color: Colors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16.0, // pour positionner le bouton à droite
                        child: ElevatedButton(
                          onPressed: () {
                            addUser(users[index]['username'] ?? '', users[index]["id"] ?? '');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple, // Couleur de fond
                            foregroundColor: Colors.white, // Couleur du texte
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Bords arrondis
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 32.0), // Padding ajusté pour le bouton
                            elevation: 5.0, // Élévation pour l'effet d'ombre
                            shadowColor: Colors.black54, // Couleur de l'ombre
                          ),
                          child: Text(
                            'Ajouter',
                            style: TextStyle(fontFamily: fontLufga), // Style du texte sans spécifier la taille
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomAppBar(currentUser: widget.currentUser, sessionToken: widget.sessionToken, activeIndex: 2,),
      ),
    );
  }


}