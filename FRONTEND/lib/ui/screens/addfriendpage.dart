import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/url.dart';
import '../../models/user.dart';
import 'contactpage.dart';

class AddFriendPage extends StatefulWidget {
  final String sessionToken;
  final User currentUser;

  const AddFriendPage({super.key, required this.sessionToken,  required this.currentUser});

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
      Navigator.push(
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter des amis'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              fetchUsers(searchController.text);
            },
            child: Text('Rechercher'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(users[index]['username'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Appeler une fonction pour gérer l'ajout de l'utilisateur ici
                      addUser(users[index]['username'] ?? '',
                          users[index]["id"] ?? '');
                    },
                    child: Text('Ajouter'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
